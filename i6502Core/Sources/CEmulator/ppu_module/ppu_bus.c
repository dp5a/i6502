#include "ppu_bus.h"
#include "ppu_module.h"

#include <stdbool.h>
#include <stdint.h>

static uint16_t mirror_nametable(uint16_t address, bool is_vertical) {
    address &= 0x0FFF;
    if (is_vertical) {
        return address & 0x07FF;
    }
    if (address < 0x0800) {
        return address & 0x03FF;
    }
    return 0x0400 + (address & 0x03FF);
}

static uint8_t mirror_palette(uint8_t index) {
    index &= 0b00011111;
    if (index == 0x10 || index == 0x14 || index == 0x18 || index == 0x1C) {
        index -= 0x10;
    }
    return index;
}

void ppu_bus_write(PpuState *state, uint16_t address, uint8_t value) {
    address &= 0x3FFF;
    if (address < 0x2000) {
        cart_ppu_write(state->cart, address, value);
    } else if (address < 0x3F00) {
        uint16_t offset = mirror_nametable(address, state->mirror_mode);
        state->nametable_ram[offset] = value;
    } else {
        state->palette[mirror_palette(address)] = value;
    }
}

uint8_t ppu_bus_read(PpuState *state, uint16_t address) {
    address &= 0x3FFF;
    if (address < 0x2000) {
        return cart_ppu_read(state->cart, address);
    } else if (address < 0x3F00) {
        uint16_t offset = mirror_nametable(address, state->mirror_mode);
        return state->nametable_ram[offset];
    }
    return state->palette[mirror_palette(address)];
}
