#ifndef __ppu_module_h_
#define __ppu_module_h_

#include "cart_module.h"
#include <stdint.h>
#include <stdbool.h>

/* 2C02 state */
typedef struct PpuState {
    uint8_t ppuctrl;   /* PPUCTRL   register ($2000 write) */
    uint8_t ppumask;   /* PPUMASK   register ($2001 write) */
    uint8_t ppustatus; /* PPUSTATUS register ($2002 read) */
    uint8_t oamaddr;   /* OAMADDR   register ($2003 write) */
    uint8_t ppudata;   /* PPUDATA   register ($2007 read) */

    uint16_t register_v; /* VRAM address */
    uint16_t register_t; /* tmp VRAM address */
    uint8_t register_x;  /* X scroll */
    bool register_w;     /* double-write latch */

    uint8_t data_bus_latch; /* last bus value */

    uint8_t oam[256];
    uint8_t secondary_oam[32];

    uint8_t palette[32];
    uint8_t nametable_ram[2048];

    uint16_t bg_shift_pattern_lo;
    uint16_t bg_shift_pattern_hi;
    uint16_t bg_shift_attr_lo;
    uint16_t bg_shift_attr_hi;

    uint8_t bg_next_tile_id;
    uint8_t bg_next_tile_attr;
    uint8_t bg_next_tile_lo;
    uint8_t bg_next_tile_hi;

    /* Sprite rendering state */
    uint8_t sprite_count;         /* sprites found on this scanline (max 8) */
    uint8_t sprite_pattern_lo[8]; /* low pattern byte per sprite */
    uint8_t sprite_pattern_hi[8]; /* high pattern byte per sprite */
    uint8_t sprite_attr[8];       /* attribute byte per sprite */
    uint8_t sprite_x_counter[8];  /* X position counter per sprite */
    bool sprite_zero_on_line;     /* sprite 0 is among the sprites on this line */

    CartState *cart;
    int scanline;
    int dot;
    bool prev_nmi;
    bool nmi_pending;
    bool odd_frame;
    bool mirror_mode;
} PpuState;


/* 2C02 initializer & deinitializer */
PpuState * ppu_create();
void ppu_destroy(PpuState *state);

/* 2C02 register dispatchers */
uint8_t ppu_read(PpuState *state, uint16_t address);
void ppu_write(PpuState *state, uint16_t address, uint8_t value);
void ppu_tick(PpuState *state, uint32_t *framebuffer);

#endif /* __ppu_module_h_ */
