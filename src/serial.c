#include "serial.h"

#define COM1_PORT 0x3F8

static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t value;

    __asm__ volatile("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

void serial_init(void) {
    /* 115200 baud, 8 data bits, no parity, 1 stop bit. */
    outb(COM1_PORT + 1, 0x00);
    outb(COM1_PORT + 3, 0x80);
    outb(COM1_PORT + 0, 0x01);
    outb(COM1_PORT + 1, 0x00);
    outb(COM1_PORT + 3, 0x03);
    outb(COM1_PORT + 2, 0xC7);
    outb(COM1_PORT + 4, 0x0B);
}

static void serial_putc(char character) {
    while ((inb(COM1_PORT + 5) & 0x20) == 0) {
        /* Wait for the transmitter holding register to become empty. */
    }

    outb(COM1_PORT, (uint8_t)character);
}

void serial_write(const char *text) {
    if (text == 0) {
        return;
    }

    while (*text != '\0') {
        if (*text == '\n') {
            serial_putc('\r');
        }
        serial_putc(*text);
        text++;
    }
}

void serial_write_line(const char *text) {
    serial_write(text);
    serial_write("\n");
}
