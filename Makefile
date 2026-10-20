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

GCC_INCLUDE := $(shell $(CC) -print-file-name=include)

# Flags de compilação freestanding. A linkagem e o linker script pertencem
# à Fase 1 e não são exercitados pelos alvos desta fase.
CFLAGS := -std=gnu11 -O2 -g -Wall -Wextra \
          -ffreestanding -fno-stack-protector -fno-stack-clash-protection \
          -fno-common -fno-PIC -fno-pie \
          -ffunction-sections -fdata-sections \
          -m64 -march=x86-64 -mno-red-zone -mcmodel=kernel \
          -mno-mmx -mno-sse -mno-80387 -fcf-protection=none

CPPFLAGS := -nostdinc -isystem $(GCC_INCLUDE) \
            -Ithird_party/limine-protocol/include

# ---------------------------------------------------------------------------
# Alvos da Fase 0
# ---------------------------------------------------------------------------

.PHONY: all
all: check-env smoke

.PHONY: help
help:
	@printf '%s\n' \
	  'SimpleOS — alvos disponíveis na Fase 0:' \
	  '' \
	  '  make                  Verifica o ambiente e compila o smoke test.' \
	  '  make check-env        Verifica toolchain, Git, QEMU e ferramentas básicas.' \
	  '  make check-image-tools Verifica ferramentas exigidas para gerar a ISO.' \
	  '  make limine           Baixa, verifica e compila o Limine fixado.' \
	  '  make smoke            Compila o objeto freestanding de teste.' \
	  '  make test             Executa check-env e smoke.' \
	  '  make clean            Remove artefatos gerados, preservando downloads.' \
	  '  make distclean        Remove todo o diretório build/.' \
	  '  make print-config     Mostra as variáveis de build.' \
	  '' \
	  'Alvos da Fase 1 (ainda não implementados): kernel, iso, run, run-uefi, debug.'

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
	@printf 'CFLAGS=%s\n' "$(CFLAGS)"
	@printf 'CPPFLAGS=%s\n' "$(CPPFLAGS)"

# ---------------------------------------------------------------------------
# Limpeza
# ---------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -rf "$(SMOKE_DIR)" "$(BUILD_DIR)/iso_root"
	rm -f "$(BUILD_DIR)"/*.iso "$(BUILD_DIR)"/*.hdd "$(BUILD_DIR)/kernel.elf"

.PHONY: distclean
distclean: clean
	rm -rf "$(BUILD_DIR)"

# ---------------------------------------------------------------------------
# Fase 1 — alvos reservados, sem implementação nesta fase
# ---------------------------------------------------------------------------

.PHONY: phase1-only
phase1-only:
	@echo "Este alvo pertence à Fase 1 e ainda não foi implementado." >&2
	@exit 2

.PHONY: kernel iso run run-uefi debug
kernel iso run run-uefi debug: phase1-only
