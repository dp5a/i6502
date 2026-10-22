#include "bus_module.h"
#include "ppu_module.h"
#include "cart_module.h"

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

/* MARK: - Bus initializer & deinitializer */

BusState * bus_create() {
    BusState *state = calloc(1, sizeof(BusState));
    if (!state) { return NULL; }
    state->ppu = NULL;

    for (size_t i = 0; i < 2048; ++i) {
        state->ram[i] = rand();
    }
    return state;
}

void bus_destroy(BusState *state) {
    free(state);
}

uint8_t bus_read(BusState *state, uint16_t address) {
    if (address < 0x2000) {
        return state->ram[address & 0x07FF];
    } else if (address < 0x4000) {
        return ppu_read(state->ppu, address);
    } else if (address == 0x4016 || address == 0x4017) {
        uint8_t index = address & 1;
        if (state->controller_strobe) {
            return state->controller_state[index] & 1;
        }
        uint8_t bit = state->controller_shift[index] & 1;
        state->controller_shift[index] >>= 1;
        state->controller_shift[index] |= 0x80;
        return bit;
    } else if (address < 0x4020) {
        /* TODO: $4001-$4013: APU registers (read only) */
        /* TODO: $4014: OAM DMA (read only) */
        /* TODO: $4015: APU status */
        return 0;
    }
    return cart_cpu_read(state->cart, address);
}

void bus_write(BusState *state, uint16_t address, uint8_t value) {
    if (address < 0x2000) {
        state->ram[address & 0x07FF] = value;
    } else if (address < 0x4000) {
        ppu_write(state->ppu, address, value);
    } else if (address == 0x4014) {
        state->dma_page = value;
        state->dma_pending = true;
    } else if (address == 0x4016) {
        bool new_strobe = value & 1;
        if (state->controller_strobe && !new_strobe) {
            state->controller_shift[0] = state->controller_state[0];
            state->controller_shift[1] = state->controller_state[1];
        }
        state->controller_strobe = new_strobe;
    } else if (address < 0x4020) {
    }
    return cart_cpu_write(state->cart, address, value);
}

