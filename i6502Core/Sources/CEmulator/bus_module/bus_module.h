#ifndef __bus_module_h_
#define __bus_module_h_

#include <stdint.h>

/* Memory bus state */
typedef struct {
    uint8_t ram[65536];
} BusState;

/* Bus initializer & deinitializer */
BusState * bus_create();
void bus_destroy(BusState *state);

/* Bus actions */
static inline __attribute__((always_inline))
uint8_t bus_read(BusState *state, uint16_t address) {
    return state->ram[address];
}
static inline __attribute__((always_inline))
void bus_write(BusState *state, uint16_t address, uint8_t value) {
    state->ram[address] = value;
}

#endif /* __bus_module_h_ */
