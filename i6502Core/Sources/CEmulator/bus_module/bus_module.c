#include "bus_module.h"

#include <stdint.h>
#include <stdlib.h>

/* MARK: - Bus initializer & deinitializer */

BusState * bus_create() {
    BusState *state = malloc(sizeof(BusState));
    if (!state) { return NULL; }

    for (size_t i = 0; i < 65536; ++i) {
        state->ram[i] = rand();
    }
    return state;
}

void bus_destroy(BusState *state) {
    free(state);
}

/* MARK: - Bus actions */

uint8_t bus_read(BusState *state, uint16_t address) {
    return state->ram[address];
}

void bus_write(BusState *state, uint16_t address, uint8_t value) {
    state->ram[address] = value;
}
