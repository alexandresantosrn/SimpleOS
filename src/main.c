#include <stddef.h>
#include <stdint.h>
#include <limine.h>

#include "serial.h"

__attribute__((used, section(".limine_requests_start_marker")))
static volatile uint64_t limine_requests_start_marker[] =
    LIMINE_REQUESTS_START_MARKER;

__attribute__((used, section(".limine_requests")))
static volatile uint64_t limine_base_revision[] = LIMINE_BASE_REVISION(6);

__attribute__((used, section(".limine_requests")))
static volatile struct limine_bootloader_info_request bootloader_info_request = {
    .id = LIMINE_BOOTLOADER_INFO_REQUEST_ID,
    .revision = 0,
    .response = NULL,
};

__attribute__((used, section(".limine_requests")))
static volatile struct limine_firmware_type_request firmware_type_request = {
    .id = LIMINE_FIRMWARE_TYPE_REQUEST_ID,
    .revision = 0,
    .response = NULL,
};

__attribute__((used, section(".limine_requests_end_marker")))
static volatile uint64_t limine_requests_end_marker[] =
    LIMINE_REQUESTS_END_MARKER;

static const char *firmware_name(uint64_t firmware_type) {
    switch (firmware_type) {
        case LIMINE_FIRMWARE_TYPE_X86BIOS:
            return "BIOS";
        case LIMINE_FIRMWARE_TYPE_EFI32:
            return "UEFI32";
        case LIMINE_FIRMWARE_TYPE_EFI64:
            return "UEFI";
        default:
            return "desconhecido";
    }
}

static const char *safe_string(const char *text) {
    return text != NULL ? text : "(indisponivel)";
}

__attribute__((noreturn))
static void halt_forever(void) {
    for (;;) {
        __asm__ volatile("cli; hlt");
    }
}

__attribute__((noreturn))
void kernel_main(void) {
    serial_init();
    serial_write_line("[simpleos] SimpleOS Phase 1");

    if (!LIMINE_BASE_REVISION_SUPPORTED(limine_base_revision)) {
        serial_write_line("[simpleos] base revision: nao suportada");
        serial_write_line("[simpleos] SIMPLEOS_PHASE1_FAIL");
        halt_forever();
    }

    serial_write_line("[simpleos] base revision: 6");

    if (bootloader_info_request.response != NULL) {
        serial_write("[simpleos] Limine: ");
        serial_write(safe_string(bootloader_info_request.response->name));
        serial_write(" ");
        serial_write(safe_string(bootloader_info_request.response->version));
        serial_write("\n");
    } else {
        serial_write_line("[simpleos] Limine: informacao indisponivel");
    }

    if (firmware_type_request.response != NULL) {
        serial_write("[simpleos] Firmware: ");
        serial_write(firmware_name(firmware_type_request.response->firmware_type));
        serial_write("\n");
    } else {
        serial_write_line("[simpleos] Firmware: desconhecido");
    }

    serial_write_line("[simpleos] SIMPLEOS_PHASE1_OK");
    halt_forever();
}
