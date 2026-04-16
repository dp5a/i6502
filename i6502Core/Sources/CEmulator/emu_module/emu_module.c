#include "emulator.h"
#include "emu_module.h"
#include "bus_module.h"
#include "cpu_module.h"

#include <stdint.h>
#include <stdlib.h>
#include <time.h>

/* MARK: - Emulator initializer & deinitializer */

EmulatorState * emu_create() {
    EmulatorState *state = malloc(sizeof(EmulatorState));
    if (!state) { return NULL; }

    srand((unsigned)time(NULL));

    state->bus = bus_create();
    state->cpu = cpu_create();

    if (!state->bus || !state->cpu) {
        if (state->cpu) { cpu_destroy(state->cpu); }
        if (state->bus) { bus_destroy(state->bus); }
        free(state);
    }

    state->cpu->bus = state->bus;

    state->cpu_cycles = (CpuCycles){ .count = 0 };
    state->cpu_cycles_index = 0;

    return state;
}

void emu_destroy(EmulatorState *state) {
    cpu_destroy(state->cpu);
    bus_destroy(state->bus);

    free(state);
}

/* MARK: - Emulator actions */

void emu_reset(EmulatorState *state) {
    state->cpu_cycles = cpu_reset(state->cpu);
    state->cpu_cycles_index = 0;
}

void emu_cycle(EmulatorState *state) {
    if (state->cpu_cycles_index < state->cpu_cycles.count) {
        CpuAction cpu_action = state->cpu_cycles.actions[state->cpu_cycles_index];

        cpu_action(state->cpu);
        state->cpu_cycles_index++;
    } else {
        /* TODO: nmi and irq goes here */

        state->cpu_cycles = cpu_decode(state->cpu);
        state->cpu_cycles_index = 0;
    }
}

/* MARK: - Emulator exposed logic */

uint8_t emu_read(EmulatorState *state, uint16_t address) {
    return bus_read(state->bus, address);
}

void emu_write(EmulatorState *state, uint16_t address, uint8_t value) {
    bus_write(state->bus, address, value);
}
