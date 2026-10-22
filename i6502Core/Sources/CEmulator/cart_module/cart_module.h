#ifndef __cart_module_h_
#define __cart_module_h_

#include <stdint.h>
#include <stdbool.h>

typedef struct {
    uint8_t *prg_rom;       /* PRG ROM data */
    uint32_t prg_size;      /* 16384 or 32768 bytes */
    uint8_t *chr_rom;       /* CHR ROM data */
    uint32_t chr_size;      /* 8192 or 0 bytes (CHR RAM) */
    uint8_t mirror_mode;    /* 0 = horizontal, 1 = vertical */
    uint8_t mapper;         /* mapper index */

    uint8_t chr_ram[8192];  /* CHR RAM */
} CartState;

CartState * cart_create(const uint8_t *rom_data, uint32_t rom_size);
void cart_destroy(CartState *state);

uint8_t cart_cpu_read(CartState *state, uint16_t address);
void cart_cpu_write(CartState *state, uint16_t address, uint8_t value);
uint8_t cart_ppu_read(CartState *state, uint16_t address);
void cart_ppu_write(CartState *state, uint16_t address, uint8_t value);

#endif /* __cart_module_h_ */
