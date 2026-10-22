#include "cart_module.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Reads cartridge dump in iNES fileformat */
CartState * cart_create(const uint8_t *rom_data, uint32_t rom_size) {
    if (rom_size < 16) { return NULL; }
    if (rom_data[0] != 'N' || rom_data[1] != 'E' || rom_data[2] != 'S') { return NULL; }
    if (rom_data[3] != 0x1A) { return NULL; }

    CartState *state = malloc(sizeof(CartState));
    if (!state) return NULL;

    uint8_t prg_banks = rom_data[4];
    uint8_t chr_banks = rom_data[5];
    uint8_t flags6 = rom_data[6];
    uint8_t flags7 = rom_data[7];

    state->mirror_mode = flags6 & 0x01;
    state->mapper = (flags6 >> 4) | (flags7 & 0xF0);

    bool has_trainer = flags6 & 0x04;
    uint32_t offset = 16 + (has_trainer ? 512 : 0);

    state->prg_size = prg_banks * 16384;
    state->prg_rom = malloc(state->prg_size);
    memcpy(state->prg_rom, rom_data + offset, state->prg_size);
    offset += state->prg_size;

    state->chr_size = chr_banks * 8192;
    if (state->chr_size > 0) {
        state->chr_rom = malloc(state->chr_size);
        memcpy(state->chr_rom, rom_data + offset, state->chr_size);
    } else {
        state->chr_rom = NULL;
        memset(state->chr_ram, 0, 8192);
    }
    return state;
}

void cart_destroy(CartState *state) {
    free(state->prg_rom);
    if (state->chr_rom) free(state->chr_rom);
    free(state);
}

uint8_t cart_cpu_read(CartState *state, uint16_t address) {
    if (address >= 0x8000) {
        return state->prg_rom[(address - 0x8000) % state->prg_size];
    }
    return 0;
}

void cart_cpu_write(CartState *state, uint16_t address, uint8_t value) {}

uint8_t cart_ppu_read(CartState *state, uint16_t address) {
    if (address < 0x2000) {
        if (state->chr_rom != NULL) {
            return state->chr_rom[address];
        }
        return state->chr_ram[address];
    }
    return 0;
}

void cart_ppu_write(CartState *state, uint16_t address, uint8_t value) {
    if (address < 0x2000 && !state->chr_rom) {
        state->chr_ram[address] = value;
    }
}
