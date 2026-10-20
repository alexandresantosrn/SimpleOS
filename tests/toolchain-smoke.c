/*
 * Smoke test de toolchain da Fase 0.
 *
 * Este arquivo NÃO faz parte do kernel e não possui ponto de entrada.
 * Ele existe apenas para verificar que o compilador instalado consegue
 * produzir um objeto ELF64 x86-64 freestanding com as flags do projeto.
 */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

volatile uint64_t simpleos_smoke_value;

uint64_t simpleos_smoke_add(uint64_t left, uint64_t right)
{
    return left + right;
}

size_t simpleos_smoke_pointer_size(void)
{
    return sizeof(void *);
}

bool simpleos_smoke_is_64_bit(void)
{
    return sizeof(void *) == 8;
}
