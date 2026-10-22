#include "emulator.h"
#include "emu_module.h"
#include "bus_module.h"
#include "cpu_module.h"
#include "ppu_module.h"
#include "actions/cpu_actions_utils.h"

#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <stdio.h>

/* MARK: - Emulator initializer & deinitializer */

EmulatorState * emu_create(uint8_t *rom_data, uint32_t rom_size) {
    EmulatorState *state = malloc(sizeof(EmulatorState));
    if (!state) { return NULL; }

    /* TODO: idk do something about potential framebuffer size mismatch */
    state->framebuffer = malloc(sizeof(uint32_t) * 256 * 240);
    if (!state->framebuffer) { return NULL; }

    /* TODO: pass seed from Swift(?) */
    srand((unsigned)time(NULL));

    state->nmi_pending = false;
    state->irq_pending = false;

    state->cart = cart_create(rom_data, rom_size);
    state->bus = bus_create();
    state->cpu = cpu_create();
    state->ppu = ppu_create();

    if (!state->bus || !state->cpu || !state->ppu) {
        if (state->ppu) { ppu_destroy(state->ppu); }
        if (state->cpu) { cpu_destroy(state->cpu); }
        if (state->bus) { bus_destroy(state->bus); }
        free(state);
        return NULL;
    }

    /* ONE simple trick that made Swift's ARC TERRIFIED /j */
    state->ppu->cart = state->cart;
    state->bus->cart = state->cart;
    state->ppu->mirror_mode = state->cart->mirror_mode;
    state->cpu->bus = state->bus;
    state->bus->ppu = state->ppu;

    state->cpu_cycles = (CpuCycles){ .count = 0 };
    state->cpu_cycles_index = 0;
    state->dma_stall = 0;

    return state;
}

void emu_destroy(EmulatorState *state) {
    ppu_destroy(state->ppu);
    cpu_destroy(state->cpu);
    bus_destroy(state->bus);
    cart_destroy(state->cart);

    free(state->framebuffer);
    free(state);
}

/* MARK: - Emulator actions */

void emu_reset(EmulatorState *state) {
    state->cpu_cycles = cpu_reset(state->cpu);
    state->cpu_cycles_index = 0;
}

void emu_set_controller(EmulatorState *state, uint8_t controller, uint8_t buttons) {
    state->bus->controller_state[controller & 1] = buttons;
}

void emu_cycle(EmulatorState *state) {
    if (state->bus->dma_pending) { /* Check for pending OAM DMA */
        state->bus->dma_pending = false;

        uint16_t base = (uint16_t)state->bus->dma_page << 8;
        for (int i = 0; i < 256; i++) {
            state->ppu->oam[(state->ppu->oamaddr + i) & 0xFF]
                = bus_read(state->bus, base + i);
        }

        state->dma_stall = 514;
    }

    if (state->dma_stall > 0) {
        state->dma_stall--;
    } else if (state->cpu_cycles_index < state->cpu_cycles.count || state->cpu->page_crossed) {
        CpuAction cpu_action = state->cpu_cycles.actions[state->cpu_cycles_index];

        state->cpu->page_crossed = false;
        cpu_action(state->cpu);
        state->cpu_cycles_index++;
    } else {
        if (state->nmi_pending) {
            state->nmi_pending = false;
            state->cpu_cycles = cpu_nmi(state->cpu);
            state->cpu_cycles_index = 0;

            CpuAction cpu_action = state->cpu_cycles.actions[state->cpu_cycles_index];
            cpu_action(state->cpu);
            state->cpu_cycles_index++;
        } else if (state->irq_pending && !(state->cpu->register_ps & I_MASK)) {
            state->cpu_cycles = cpu_irq(state->cpu);
            state->cpu_cycles_index = 0;

            CpuAction cpu_action = state->cpu_cycles.actions[state->cpu_cycles_index];
            cpu_action(state->cpu);
            state->cpu_cycles_index++;

        } else {
            state->cpu_cycles = cpu_decode(state->cpu);
            state->cpu_cycles_index = 0;
        }
    }
    ppu_tick(state->ppu, state->framebuffer);
    ppu_tick(state->ppu, state->framebuffer);
    ppu_tick(state->ppu, state->framebuffer);

    if (state->ppu->nmi_pending) {
        state->ppu->nmi_pending = false;
        state->nmi_pending = true;
    }
}

/* MARK: - Emulator exposed logic */

uint8_t emu_read(EmulatorState *state, uint16_t address) {
    return bus_read(state->bus, address);
}

void emu_write(EmulatorState *state, uint16_t address, uint8_t value) {
    bus_write(state->bus, address, value);
}

void emu_set_pc(EmulatorState *state, uint16_t address) {
    state->cpu->register_pc = address;
}

void emu_irq_line(EmulatorState *state, bool is_on) {
    state->irq_pending = is_on;
}

void emu_nmi_line(EmulatorState *state, bool is_on) {
    state->nmi_pending = is_on;
}

uint32_t * emu_framebuffer(EmulatorState *state) {
    return state->framebuffer;
}
