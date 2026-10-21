SHELL := /bin/sh

.DEFAULT_GOAL := all
.SUFFIXES:
.DELETE_ON_ERROR:

# ---------------------------------------------------------------------------
# Configuração do projeto
# ---------------------------------------------------------------------------

ARCH := x86_64
CC := gcc
LD := ld

BUILD_DIR := build
SMOKE_DIR := $(BUILD_DIR)/smoke
SMOKE_OBJ := $(SMOKE_DIR)/toolchain-smoke.o

LIMINE_VERSION := 12.9.4
LIMINE_SHA256 := 847334bc4bc142de996fbd132806b89ed73ac9ab34dbc1e90cfebf1fcc68c2b1
LIMINE_TARBALL := $(BUILD_DIR)/downloads/limine-binary-$(LIMINE_VERSION).tar.gz
LIMINE_DIR := $(BUILD_DIR)/limine-binary
LIMINE_TOOL := $(LIMINE_DIR)/limine

SRC_DIR := src
CONFIG_DIR := config
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
KERNEL_MAP := $(BUILD_DIR)/kernel.map
KERNEL_OBJ_DIR := $(BUILD_DIR)/obj
KERNEL_SRCS := $(SRC_DIR)/main.c $(SRC_DIR)/serial.c
KERNEL_OBJS := $(patsubst $(SRC_DIR)/%.c,$(KERNEL_OBJ_DIR)/%.o,$(KERNEL_SRCS))
LINKER_SCRIPT := $(SRC_DIR)/linker.ld
LIMINE_CONF := $(CONFIG_DIR)/limine.conf
ISO := $(BUILD_DIR)/simpleos.iso
ISO_ROOT := $(BUILD_DIR)/iso_root
NEGATIVE_DIR := $(BUILD_DIR)/negative
NEGATIVE_ISO := $(NEGATIVE_DIR)/simpleos-negative.iso

XORRISO := xorriso
QEMU := qemu-system-x86_64
QEMU_MACHINE := q35
QEMU_MEMORY := 2G
QEMU_ACCEL ?= $(shell if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then printf kvm; else printf tcg; fi)
QEMU_CPU ?= $(if $(filter kvm,$(QEMU_ACCEL)),host,max)
QEMU_TIMEOUT ?= 15
OVMF_CODE := /usr/share/OVMF/OVMF_CODE.fd
OVMF_VARS := /usr/share/OVMF/OVMF_VARS.fd
OVMF_VARS_BUILD := $(BUILD_DIR)/OVMF_VARS.fd

GCC_INCLUDE := $(shell $(CC) -print-file-name=include)

# Flags de compilação freestanding usadas pelo kernel e pelo smoke test.
CFLAGS := -std=gnu11 -O2 -g -Wall -Wextra \
          -ffreestanding -fno-stack-protector -fno-stack-clash-protection \
          -fno-common -fno-PIC -fno-pie \
          -ffunction-sections -fdata-sections \
          -m64 -march=x86-64 -mno-red-zone -mcmodel=kernel \
          -mno-mmx -mno-sse -mno-80387 -fcf-protection=none

CPPFLAGS := -nostdinc -isystem $(GCC_INCLUDE) \
            -I$(SRC_DIR) -Ithird_party/limine-protocol/include

KERNEL_LDFLAGS := -nostdlib -static -no-pie -m elf_x86_64 \
                  -z max-page-size=0x1000 -z noexecstack \
                  --build-id=none -T $(LINKER_SCRIPT) -Map $(KERNEL_MAP)

# ---------------------------------------------------------------------------
# Alvos da Fase 0
# ---------------------------------------------------------------------------

.PHONY: all
all: check-env smoke

.PHONY: help
help:
	@printf '%s\n' \
	  'SimpleOS — alvos disponíveis:' \
	  '' \
	  '  make                  Verifica o ambiente e compila o smoke test (Fase 0).' \
	  '  make check-env        Verifica toolchain, Git, QEMU e ferramentas básicas.' \
	  '  make check-image-tools Verifica ferramentas exigidas para gerar a ISO.' \
	  '  make limine           Baixa, verifica e compila o Limine fixado.' \
	  '  make smoke            Compila o objeto freestanding de teste.' \
	  '  make test             Executa os testes da Fase 0.' \
	  '  make kernel           Compila e valida build/kernel.elf.' \
	  '  make iso              Gera e valida build/simpleos.iso.' \
	  '  make run              Executa a ISO no QEMU via BIOS.' \
	  '  make run-uefi         Executa a ISO no QEMU via UEFI/OVMF.' \
	  '  make debug            Inicia o QEMU parado para depuração com GDB.' \
	  '  make test-phase1      Executa os testes da Fase 0 e da Fase 1.' \
	  '  make test-boot-bios   Testa o boot BIOS e procura o marcador.' \
	  '  make test-boot-uefi   Testa o boot UEFI e procura o marcador.' \
	  '  make test-boot-negative Testa a falha com caminho de kernel inválido.' \
	  '  make clean            Remove artefatos gerados, preservando downloads.' \
	  '  make distclean        Remove todo o diretório build/.' \
	  '  make print-config     Mostra as variáveis de build.'

.PHONY: check-env
check-env:
	@./tools/check-env.sh

.PHONY: check-image-tools
check-image-tools:
	@./tools/check-env.sh --image

.PHONY: limine
limine:
	@./tools/fetch-limine.sh

$(SMOKE_DIR):
	@mkdir -p $@

$(SMOKE_OBJ): tests/toolchain-smoke.c Makefile | $(SMOKE_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

.PHONY: smoke
smoke: $(SMOKE_OBJ)
	@printf '\nSmoke test: %s\n' "$(SMOKE_OBJ)"
	@file "$(SMOKE_OBJ)"
	@LC_ALL=C readelf -h "$(SMOKE_OBJ)" | grep -E 'Class:|Machine:|Type:'
	@if nm -u "$(SMOKE_OBJ)" | grep -q .; then \
	  echo "ERRO: o objeto contém símbolos indefinidos:"; \
	  nm -u "$(SMOKE_OBJ)"; \
	  exit 1; \
	else \
	  echo "OK: nenhum símbolo indefinido no objeto de teste."; \
	fi

.PHONY: test
test: check-env smoke

.PHONY: print-config
print-config:
	@printf 'ARCH=%s\n' "$(ARCH)"
	@printf 'CC=%s\n' "$(CC)"
	@printf 'LD=%s\n' "$(LD)"
	@printf 'GCC_INCLUDE=%s\n' "$(GCC_INCLUDE)"
	@printf 'LIMINE_VERSION=%s\n' "$(LIMINE_VERSION)"
	@printf 'LIMINE_SHA256=%s\n' "$(LIMINE_SHA256)"
	@printf 'KERNEL_ELF=%s\n' "$(KERNEL_ELF)"
	@printf 'LINKER_SCRIPT=%s\n' "$(LINKER_SCRIPT)"
	@printf 'LIMINE_CONF=%s\n' "$(LIMINE_CONF)"
	@printf 'ISO=%s\n' "$(ISO)"
	@printf 'QEMU=%s\n' "$(QEMU)"
	@printf 'QEMU_MACHINE=%s\n' "$(QEMU_MACHINE)"
	@printf 'QEMU_MEMORY=%s\n' "$(QEMU_MEMORY)"
	@printf 'QEMU_ACCEL=%s\n' "$(QEMU_ACCEL)"
	@printf 'QEMU_CPU=%s\n' "$(QEMU_CPU)"
	@printf 'CFLAGS=%s\n' "$(CFLAGS)"
	@printf 'CPPFLAGS=%s\n' "$(CPPFLAGS)"
	@printf 'KERNEL_LDFLAGS=%s\n' "$(KERNEL_LDFLAGS)"

# ---------------------------------------------------------------------------
# Fase 1 — kernel, ISO, QEMU e testes de boot
# ---------------------------------------------------------------------------

$(KERNEL_OBJ_DIR):
	@mkdir -p $@

$(KERNEL_OBJ_DIR)/%.o: $(SRC_DIR)/%.c Makefile | $(KERNEL_OBJ_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(KERNEL_ELF): $(KERNEL_OBJS) $(LINKER_SCRIPT) Makefile
	$(LD) $(KERNEL_LDFLAGS) -o $@ $(KERNEL_OBJS)

.PHONY: kernel
kernel: $(KERNEL_ELF)
	@printf '\nKernel: %s\n' "$(KERNEL_ELF)"
	@file "$(KERNEL_ELF)"
	@LC_ALL=C readelf -h "$(KERNEL_ELF)" | grep -E 'Class:|Machine:|Type:|Entry point'
	@LC_ALL=C readelf -h "$(KERNEL_ELF)" | grep -q 'Type:[[:space:]]*EXEC' || { \
	  echo "ERRO: o kernel não é um executável ET_EXEC."; exit 1; \
	}
	@LC_ALL=C readelf -h "$(KERNEL_ELF)" | grep -Eq 'Entry point address:[[:space:]]+0xffffffff8[0-9a-f]+' || { \
	  echo "ERRO: ponto de entrada fora da metade superior esperada."; exit 1; \
	}
	@LC_ALL=C readelf -S "$(KERNEL_ELF)" | grep -q '\.limine_requests' || { \
	  echo "ERRO: seção .limine_requests ausente."; exit 1; \
	}
	@if nm -u "$(KERNEL_ELF)" | grep -q .; then \
	  echo "ERRO: o kernel contém símbolos indefinidos:"; \
	  nm -u "$(KERNEL_ELF)"; \
	  exit 1; \
	else \
	  echo "OK: nenhum símbolo indefinido no kernel."; \
	fi

.PHONY: iso
iso: $(ISO)

$(ISO): $(KERNEL_ELF) $(LIMINE_CONF) Makefile
	@if [ ! -x "$(LIMINE_TOOL)" ] || [ ! -f "$(LIMINE_DIR)/limine-bios.sys" ]; then \
	  $(MAKE) limine; \
	fi
	@rm -rf "$(ISO_ROOT)"
	@mkdir -p "$(ISO_ROOT)/boot/limine" "$(ISO_ROOT)/EFI/BOOT"
	@cp "$(KERNEL_ELF)" "$(ISO_ROOT)/boot/limine/kernel.elf"
	@cp "$(LIMINE_CONF)" "$(ISO_ROOT)/boot/limine/limine.conf"
	@cp "$(LIMINE_DIR)/limine-bios.sys" "$(ISO_ROOT)/boot/limine/limine-bios.sys"
	@cp "$(LIMINE_DIR)/limine-bios-cd.bin" "$(ISO_ROOT)/boot/limine/limine-bios-cd.bin"
	@cp "$(LIMINE_DIR)/limine-uefi-cd.bin" "$(ISO_ROOT)/boot/limine/limine-uefi-cd.bin"
	@cp "$(LIMINE_DIR)/BOOTX64.EFI" "$(ISO_ROOT)/EFI/BOOT/BOOTX64.EFI"
	$(XORRISO) -as mkisofs -R -r -J \
	  -b boot/limine/limine-bios-cd.bin -no-emul-boot \
	  -boot-load-size 4 -boot-info-table \
	  -hfsplus -apm-block-size 2048 \
	  --efi-boot boot/limine/limine-uefi-cd.bin \
	  -efi-boot-part --efi-boot-image --protective-msdos-label \
	  "$(ISO_ROOT)" -o "$(ISO)"
	@$(LIMINE_TOOL) bios-install "$(ISO)"
	@$(XORRISO) -indev "$(ISO)" -find / -type f -exec lsdl > "$(BUILD_DIR)/iso-files.txt"
	@for required in \
	  /boot/limine/kernel.elf \
	  /boot/limine/limine.conf \
	  /boot/limine/limine-bios.sys \
	  /boot/limine/limine-bios-cd.bin \
	  /boot/limine/limine-uefi-cd.bin \
	  /EFI/BOOT/BOOTX64.EFI; do \
	  grep -q "$$required" "$(BUILD_DIR)/iso-files.txt" || { \
	    echo "ERRO: arquivo ausente na ISO: $$required"; exit 1; \
	  }; \
	done
	@printf 'ISO: %s\n' "$(ISO)"
	@file "$(ISO)"

$(OVMF_VARS_BUILD): $(OVMF_VARS) Makefile
	@mkdir -p "$(BUILD_DIR)"
	@cp "$<" "$@"

.PHONY: run
run: $(ISO)
	$(QEMU) -M $(QEMU_MACHINE) -m $(QEMU_MEMORY) -smp 1 \
	  -accel $(QEMU_ACCEL) -cpu $(QEMU_CPU) -net none -no-reboot \
	  -cdrom "$(ISO)" -boot d -display none -monitor none -serial stdio

.PHONY: run-uefi
run-uefi: $(ISO) $(OVMF_VARS_BUILD)
	$(QEMU) -M $(QEMU_MACHINE) -m $(QEMU_MEMORY) -smp 1 \
	  -accel $(QEMU_ACCEL) -cpu $(QEMU_CPU) -net none -no-reboot \
	  -drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_CODE) \
	  -drive if=pflash,format=raw,unit=1,file=$(OVMF_VARS_BUILD) \
	  -cdrom "$(ISO)" -boot d -display none -monitor none -serial stdio

.PHONY: debug
debug: $(ISO)
	$(QEMU) -M $(QEMU_MACHINE) -m $(QEMU_MEMORY) -smp 1 \
	  -accel $(QEMU_ACCEL) -cpu $(QEMU_CPU) -net none -no-reboot \
	  -cdrom "$(ISO)" -boot d -display none -monitor none \
	  -serial stdio -s -S

.PHONY: test-boot-bios test-boot-uefi test-boot-negative
test-boot-bios: $(ISO)
	@./tools/test-boot.sh bios

test-boot-uefi: $(ISO) $(OVMF_VARS_BUILD)
	@./tools/test-boot.sh uefi

test-boot-negative: $(ISO)
	@./tools/test-boot.sh negative

.PHONY: test-phase1
test-phase1: test kernel iso
	@./tools/test-boot.sh bios
	@./tools/test-boot.sh uefi
	@./tools/test-boot.sh negative

# ---------------------------------------------------------------------------
# Limpeza
# ---------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -rf "$(SMOKE_DIR)" "$(KERNEL_OBJ_DIR)" "$(ISO_ROOT)" "$(NEGATIVE_DIR)"
	rm -f "$(BUILD_DIR)"/*.iso "$(BUILD_DIR)"/*.hdd \
	      "$(KERNEL_ELF)" "$(KERNEL_MAP)" "$(OVMF_VARS_BUILD)" \
	      "$(BUILD_DIR)/iso-files.txt"

.PHONY: distclean
distclean: clean
	rm -rf "$(BUILD_DIR)"
