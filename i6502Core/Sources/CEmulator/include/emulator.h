#ifndef __emulator_h_
#define __emulator_h_

#include <stdint.h>
#include <stdbool.h>

/* Opaque emulator state handle */
typedef struct EmuState EmulatorState;

/* Emulator initializer & deinitializer */
EmulatorState * emu_create();
void emu_destroy(EmulatorState *state);

/* Emulator actions */
void emu_reset(EmulatorState *state);
void emu_cycle(EmulatorState *state);

/* Emulator exposed logic */
uint8_t emu_read(EmulatorState *state, uint16_t address);
void emu_write(EmulatorState *state, uint16_t address, uint8_t value);
void emu_irq_line(EmulatorState *state, bool is_on);
void emu_nmi_line(EmulatorState *state, bool is_on);

#endif /* __emulator_h_ */
