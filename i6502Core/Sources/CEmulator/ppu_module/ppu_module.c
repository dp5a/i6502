#include "ppu_module.h"

#include "ppu_bus.h"
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

/* VBlank NMI enable in PPUCTRL bit mask */
#define PPUCTRL_NMI_ENABLE 0b10000000
#define PPUSTATUS_VBLANK   0b10000000

/* MARK: - 2C02 initializer & deinitializer */

PpuState * ppu_create() {
    PpuState *state = calloc(1, sizeof(PpuState));
    return state;
}

void ppu_destroy(PpuState *state) {
    free(state);
}

/* MARK: - 2C02 register dispatchers */

static void ppu_ctrl_write(PpuState *state, uint8_t value) {
    uint8_t previous_nmi = state->ppuctrl & PPUCTRL_NMI_ENABLE;
    uint8_t current_nmi = value & PPUCTRL_NMI_ENABLE;

    state->ppuctrl = value;
    state->register_t = (state->register_t & ~0x0C00) | ((value & 0x03) << 10);
    if (!previous_nmi && current_nmi && (state->ppustatus & PPUSTATUS_VBLANK)) {
        state->nmi_pending = true;
    }
}

static void ppu_mask_write(PpuState *state, uint8_t value) {
    state->ppumask = value;
}

static void ppu_oamaddr_write(PpuState *state, uint8_t value) {
    state->oamaddr = value;
}

static void ppu_oamdata_write(PpuState *state, uint8_t value) {
    state->oam[state->oamaddr++] = value;
}

static void ppu_scroll_write(PpuState *state, uint8_t value) {
    if (!state->register_w) {
        state->register_t = (state->register_t & 0xFFE0) | (value >> 3);
        state->register_x = value & 0b111;
        state->register_w = true;
    } else {
        state->register_t = (state->register_t & 0x8C1F)
            | ((uint16_t)(value & 0b111) << 12)
            | ((uint16_t)(value >> 3) << 5);
        state->register_w = false;
    }
}

static void ppu_addr_write(PpuState *state, uint8_t value) {
    if (!state->register_w) {
        state->register_t = (state->register_t & 0x00FF) | ((uint16_t)(value & 0x3F) << 8);
        state->register_w = true;
    } else {
        state->register_t = (state->register_t & 0xFF00) | value;
        state->register_v = state->register_t;
        state->register_w = false;
    }
}

static void ppu_data_write(PpuState *state, uint8_t value) {
    ppu_bus_write(state, state->register_v, value);
    state->register_v += (state->ppuctrl & 0b100) ? 32 : 1;
}

static uint8_t ppu_status_read(PpuState *state) {
    uint8_t result = (state->ppustatus & 0b11100000) | (state->data_bus_latch & 0b00011111);

    state->ppustatus &= ~PPUSTATUS_VBLANK;
    state->register_w = false;
    return result;
}

static uint8_t ppu_oamdata_read(PpuState *state) {
    uint8_t value = state->oam[state->oamaddr];

    if ((state->oamaddr & 0b11) == 0b10) {
        return value & 0b11100011;
    }
    return value;
}

static uint8_t ppu_data_read(PpuState *state) {
    uint8_t result;
    uint16_t addr = state->register_v;

    if ((addr & 0x3FFF) >= 0x3F00) {
        result = ppu_bus_read(state, addr);
        state->ppudata = ppu_bus_read(state, addr - 0x1000);
    } else {
        result = state->ppudata;
        state->ppudata = ppu_bus_read(state, addr);
    }
    state->register_v += (state->ppuctrl & 0b100) ? 32 : 1;
    return result;
}

uint8_t ppu_read(PpuState *state, uint16_t address) {
    switch (address & 0x07) {
        case 0: return state->data_bus_latch;
        case 1: return state->data_bus_latch;
        case 2: return ppu_status_read(state);
        case 3: return state->data_bus_latch;
        case 4: return ppu_oamdata_read(state);
        case 5: return state->data_bus_latch;
        case 6: return state->data_bus_latch;
        case 7: return ppu_data_read(state);
        default: __builtin_unreachable();
    }
}

void ppu_write(PpuState *state, uint16_t address, uint8_t value) {
    state->data_bus_latch = value;

    switch (address & 0x07) {
        case 0: ppu_ctrl_write(state, value); break;
        case 1: ppu_mask_write(state, value); break;
        case 2: /* read-only */ break;
        case 3: ppu_oamaddr_write(state, value); break;
        case 4: ppu_oamdata_write(state, value); break;
        case 5: ppu_scroll_write(state, value); break;
        case 6: ppu_addr_write(state, value); break;
        case 7: ppu_data_write(state, value); break;
        default: __builtin_unreachable();
    }
}

/* TODO: refactor this mess... */
void ppu_tick(PpuState *state, uint32_t *framebuffer) {
    static const uint32_t nes_rgb[64] = {
        0xFF666666, 0xFF882A00, 0xFFA71214, 0xFFA4003B,
        0xFF7E005C, 0xFF40006E, 0xFF00066C, 0xFF001D56,
        0xFF003533, 0xFF00480B, 0xFF005200, 0xFF084F00,
        0xFF4D4000, 0xFF000000, 0xFF000000, 0xFF000000,
        0xFFADADAD, 0xFFD95F15, 0xFFFF4042, 0xFFFE2775,
        0xFFCC1AA0, 0xFF7B1EB7, 0xFF2031B5, 0xFF004E99,
        0xFF006D6B, 0xFF008738, 0xFF00930C, 0xFF328F00,
        0xFF8D7C00, 0xFF000000, 0xFF000000, 0xFF000000,
        0xFFFFFEFF, 0xFFFFB064, 0xFFFF9092, 0xFFFF76C6,
        0xFFFF6AF3, 0xFFCC6EFE, 0xFF7081FE, 0xFF229EEA,
        0xFF00BEBC, 0xFF00D888, 0xFF30E45C, 0xFF82E045,
        0xFFDECD48, 0xFF4F4F4F, 0xFF000000, 0xFF000000,
        0xFFFFFEFF, 0xFFFFDFC0, 0xFFFFD2D3, 0xFFFFC8E8,
        0xFFFFC2FB, 0xFFEAC4FE, 0xFFC5CCFE, 0xFFA5D8F7,
        0xFF94E5E4, 0xFF96EFCF, 0xFFABF4BD, 0xFFCCF3B3,
        0xFFF2EBB5, 0xFFB8B8B8, 0xFF000000, 0xFF000000,
    };

    bool rendering_enabled = state->ppumask & 0x18;
    bool show_bg  = state->ppumask & 0x08;
    bool show_spr = state->ppumask & 0x10;
    bool visible_scanline = state->scanline < 240;
    bool prerender_scanline = state->scanline == 261;
    bool render_scanline = visible_scanline || prerender_scanline;
    bool visible_dot = state->dot >= 1 && state->dot <= 256;
    bool fetch_dot = (state->dot >= 1 && state->dot <= 256)
                   || (state->dot >= 321 && state->dot <= 336);

    if (rendering_enabled && render_scanline) {
        if (visible_scanline && visible_dot) {
            /* Background */
            uint8_t bg_pixel = 0;
            uint8_t bg_palette = 0;
            if (show_bg && (state->dot > 8 || (state->ppumask & 0x02))) {
                uint16_t mux = 0x8000 >> state->register_x;
                bg_pixel = ((state->bg_shift_pattern_lo & mux) ? 1 : 0)
                    | ((state->bg_shift_pattern_hi & mux) ? 2 : 0);
                bg_palette = ((state->bg_shift_attr_lo & mux) ? 1 : 0)
                    | ((state->bg_shift_attr_hi & mux) ? 2 : 0);
            }

            /* Sprite */
            uint8_t spr_pixel = 0;
            uint8_t spr_palette = 0;
            bool spr_priority = false;
            bool spr_is_zero = false;

            if (show_spr && (state->dot > 8 || (state->ppumask & 0x04))) {
                for (int i = 0; i < state->sprite_count; i++) {
                    int offset = (state->dot - 1) - state->sprite_x_counter[i];
                    if (offset < 0 || offset > 7) { continue; }

                    uint8_t bit = 7 - offset;
                    uint8_t pixel = ((state->sprite_pattern_lo[i] >> bit) & 1)
                        | (((state->sprite_pattern_hi[i] >> bit) & 1) << 1);
                    if (pixel == 0) { continue; }

                    spr_pixel = pixel;
                    spr_palette = (state->sprite_attr[i] & 0x03) + 4;
                    spr_priority = state->sprite_attr[i] & 0x20;
                    spr_is_zero = (i == 0) && state->sprite_zero_on_line;
                    break;
                }
            }

            /* Sprite 0 hit detection */
            if (spr_is_zero && bg_pixel != 0 && spr_pixel != 0
                && state->dot != 256 && !(state->ppustatus & 0x40)
            ) {
                state->ppustatus |= 0x40;
            }

            uint8_t color_index;
            if (bg_pixel == 0 && spr_pixel == 0) {
                color_index = state->palette[0];
            } else if (bg_pixel == 0 && spr_pixel != 0) {
                color_index = state->palette[spr_palette * 4 + spr_pixel];
            } else if (bg_pixel != 0 && spr_pixel == 0) {
                color_index = state->palette[bg_palette * 4 + bg_pixel];
            } else {
                if (spr_priority) {
                    color_index = state->palette[bg_palette * 4 + bg_pixel];
                } else {
                    color_index = state->palette[spr_palette * 4 + spr_pixel];
                }
            }

            int x = state->dot - 1;
            int y = state->scanline;
            framebuffer[y * 256 + x] = nes_rgb[color_index & 0x3F];
        }

        if (fetch_dot) {
            state->bg_shift_pattern_lo <<= 1;
            state->bg_shift_pattern_hi <<= 1;
            state->bg_shift_attr_lo <<= 1;
            state->bg_shift_attr_hi <<= 1;
        }

        if (fetch_dot) {
            switch (state->dot & 0x07) {
                case 1: {
                    uint16_t nt_addr = 0x2000 | (state->register_v & 0x0FFF);
                    state->bg_next_tile_id = ppu_bus_read(state, nt_addr);
                    break;
                }
                case 3: {
                    uint16_t attr_addr = 0x23C0
                        | (state->register_v & 0x0C00)
                        | ((state->register_v >> 4) & 0x38)
                        | ((state->register_v >> 2) & 0x07);
                    uint8_t attr_byte = ppu_bus_read(state, attr_addr);
                    if (state->register_v & 0x0002) attr_byte >>= 2;
                    if (state->register_v & 0x0040) attr_byte >>= 4;
                    state->bg_next_tile_attr = attr_byte & 0x03;
                    break;
                }
                case 5: {
                    uint16_t pattern_addr = ((state->ppuctrl & 0x10) ? 0x1000 : 0x0000)
                        + (uint16_t)state->bg_next_tile_id * 16
                        + ((state->register_v >> 12) & 0x07);
                    state->bg_next_tile_lo = ppu_bus_read(state, pattern_addr);
                    break;
                }
                case 7: {
                    uint16_t pattern_addr = ((state->ppuctrl & 0x10) ? 0x1000 : 0x0000)
                        + (uint16_t)state->bg_next_tile_id * 16
                        + ((state->register_v >> 12) & 0x07)
                        + 8;
                    state->bg_next_tile_hi = ppu_bus_read(state, pattern_addr);
                    break;
                }
                case 0: {
                    state->bg_shift_pattern_lo = (state->bg_shift_pattern_lo & 0xFF00)
                        | state->bg_next_tile_lo;
                    state->bg_shift_pattern_hi = (state->bg_shift_pattern_hi & 0xFF00)
                        | state->bg_next_tile_hi;
                    state->bg_shift_attr_lo = (state->bg_shift_attr_lo & 0xFF00)
                        | ((state->bg_next_tile_attr & 1) ? 0xFF : 0x00);
                    state->bg_shift_attr_hi = (state->bg_shift_attr_hi & 0xFF00)
                        | ((state->bg_next_tile_attr & 2) ? 0xFF : 0x00);

                    if ((state->register_v & 0x001F) == 31) {
                        state->register_v &= ~0x001F;
                        state->register_v ^= 0x0400;
                    } else {
                        state->register_v++;
                    }
                    break;
                }
            }
        }

        if (state->dot == 256) {
            if ((state->register_v & 0x7000) != 0x7000) {
                state->register_v += 0x1000;
            } else {
                state->register_v &= ~0x7000;
                int coarse_y = (state->register_v & 0x03E0) >> 5;
                if (coarse_y == 29) {
                    coarse_y = 0;
                    state->register_v ^= 0x0800;
                } else if (coarse_y == 31) {
                    coarse_y = 0;
                } else {
                    coarse_y++;
                }
                state->register_v = (state->register_v & ~0x03E0) | (coarse_y << 5);
            }
        }

        if (state->dot == 257) {
            state->register_v = (state->register_v & ~0x041F)
                              | (state->register_t & 0x041F);

            state->sprite_count = 0;
            state->sprite_zero_on_line = false;

            uint8_t sprite_height = (state->ppuctrl & 0x20) ? 16 : 8;

            for (int i = 0; i < 64 && state->sprite_count < 8; i++) {
                uint8_t sy = state->oam[i * 4 + 0];
                int row = state->scanline - sy;

                if (row < 0 || row >= sprite_height) continue;

                if (i == 0) state->sprite_zero_on_line = true;

                uint8_t tile_index = state->oam[i * 4 + 1];
                uint8_t attr       = state->oam[i * 4 + 2];
                uint8_t sx         = state->oam[i * 4 + 3];

                if (attr & 0x80) {
                    row = (sprite_height - 1) - row;
                }

                uint16_t pattern_addr;
                if (sprite_height == 8) {
                    uint16_t base = (state->ppuctrl & 0x08) ? 0x1000 : 0x0000;
                    pattern_addr = base + (uint16_t)tile_index * 16 + row;
                } else {
                    uint16_t base = (tile_index & 1) ? 0x1000 : 0x0000;
                    tile_index &= 0xFE;
                    if (row >= 8) {
                        tile_index++;
                        row -= 8;
                    }
                    pattern_addr = base + (uint16_t)tile_index * 16 + row;
                }

                uint8_t lo = ppu_bus_read(state, pattern_addr);
                uint8_t hi = ppu_bus_read(state, pattern_addr + 8);

                if (attr & 0x40) {
                    lo = ((lo & 0x01) << 7) | ((lo & 0x02) << 5) | ((lo & 0x04) << 3) | ((lo & 0x08) << 1)
                       | ((lo & 0x10) >> 1) | ((lo & 0x20) >> 3) | ((lo & 0x40) >> 5) | ((lo & 0x80) >> 7);
                    hi = ((hi & 0x01) << 7) | ((hi & 0x02) << 5) | ((hi & 0x04) << 3) | ((hi & 0x08) << 1)
                       | ((hi & 0x10) >> 1) | ((hi & 0x20) >> 3) | ((hi & 0x40) >> 5) | ((hi & 0x80) >> 7);
                }

                uint8_t n = state->sprite_count;
                state->sprite_pattern_lo[n] = lo;
                state->sprite_pattern_hi[n] = hi;
                state->sprite_attr[n] = attr;
                state->sprite_x_counter[n] = sx;
                state->sprite_count++;
            }
        }

        if (prerender_scanline && state->dot >= 280 && state->dot <= 304) {
            state->register_v = (state->register_v & ~0x7BE0)
                              | (state->register_t & 0x7BE0);
        }
    }

    if (state->scanline == 241 && state->dot == 1) {
         state->ppustatus |= 0x80;
     }

     if (prerender_scanline && state->dot == 1) {
         state->ppustatus &= ~0xE0;
     }

    bool nmi_now = (state->ppuctrl & 0x80) && (state->ppustatus & 0x80);
     if (nmi_now && !state->prev_nmi) {
         state->nmi_pending = true;
     }
     state->prev_nmi = nmi_now;

    state->dot++;
     if (state->dot > 340) {
         state->dot = 0;
         state->scanline++;
         if (state->scanline > 261) {
             state->scanline = 0;
             state->odd_frame = !state->odd_frame;
         }
     }

    if (prerender_scanline && state->dot == 339
         && state->odd_frame && rendering_enabled) {
         state->dot = 0;
         state->scanline = 0;
         state->odd_frame = !state->odd_frame;
     }
}
