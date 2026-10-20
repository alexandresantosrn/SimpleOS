#!/bin/sh
#
# Verificação de ambiente da Fase 0 do SimpleOS.
#
# Este script é somente de leitura: não instala pacotes, não altera
# configurações e não executa sudo. Ele apenas relata o que existe.
#
# Uso:
#   ./tools/check-env.sh            # requisitos principais da Fase 0
#   ./tools/check-env.sh --image    # também exige as ferramentas de imagem

set -u

IMAGE_MODE=0
case "${1:-}" in
    --image)
        IMAGE_MODE=1
        ;;
    "")
        ;;
    *)
        echo "uso: $0 [--image]" >&2
        exit 2
        ;;
esac

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$ROOT_DIR"

fail=0
warn=0

section() {
    printf '\n== %s ==\n' "$1"
}

ok() {
    printf '  [OK] %s\n' "$*"
}

missing() {
    printf '  [FALTA] %s\n' "$*"
}

info() {
    printf '  [INFO] %s\n' "$*"
}

check_required() {
    name=$1
    if command -v "$name" >/dev/null 2>&1; then
        ok "$name: $(command -v "$name")"
    else
        missing "$name"
        fail=1
    fi
}

check_optional() {
    name=$1
    if command -v "$name" >/dev/null 2>&1; then
        ok "$name: $(command -v "$name")"
    else
        info "$name: ausente (opcional)"
    fi
}

check_image_tool() {
    name=$1
    if command -v "$name" >/dev/null 2>&1; then
        ok "$name: $(command -v "$name")"
    else
        missing "$name"
        warn=1
        if [ "$IMAGE_MODE" -eq 1 ]; then
            fail=1
        fi
    fi
}

first_line() {
    "$@" 2>/dev/null | head -n 1
}

section "Sistema"
info "Diretório: $ROOT_DIR"
info "Kernel: $(uname -srm)"
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    info "Distribuição: ${PRETTY_NAME:-desconhecida}"
fi

section "Ferramentas principais"
for cmd in gcc as ld make git qemu-system-x86_64 curl sha256sum readelf objdump nm file; do
    check_required "$cmd"
done

section "Versões"
if command -v gcc >/dev/null 2>&1; then
    printf '  GCC: %s\n' "$(first_line gcc --version)"
    printf '  Alvo GCC: %s\n' "$(gcc -dumpmachine 2>/dev/null || echo desconhecido)"
fi
if command -v ld >/dev/null 2>&1; then
    printf '  Linker: %s\n' "$(first_line ld --version)"
fi
if command -v make >/dev/null 2>&1; then
    printf '  Make: %s\n' "$(first_line make --version)"
fi
if command -v git >/dev/null 2>&1; then
    printf '  Git: %s\n' "$(first_line git --version)"
fi
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    printf '  QEMU: %s\n' "$(first_line qemu-system-x86_64 --version)"
fi
if command -v gdb >/dev/null 2>&1; then
    printf '  GDB: %s\n' "$(first_line gdb --version)"
fi
if command -v xorriso >/dev/null 2>&1; then
    printf '  XORRISO: %s\n' "$(first_line xorriso --version)"
fi
if command -v nasm >/dev/null 2>&1; then
    printf '  NASM: %s\n' "$(first_line nasm -v)"
fi
if command -v clang >/dev/null 2>&1; then
    printf '  Clang: %s\n' "$(first_line clang --version)"
fi

section "Compilação freestanding"
gcc_target=$(gcc -dumpmachine 2>/dev/null || true)
case "$gcc_target" in
    x86_64*)
        ok "GCC produz código para x86_64 ($gcc_target)"
        ;;
    *)
        missing "GCC não aponta para x86_64 (alvo: ${gcc_target:-desconhecido})"
        fail=1
        ;;
esac

gcc_include=$(gcc -print-file-name=include 2>/dev/null || true)
if [ -n "$gcc_include" ] && [ -f "$gcc_include/stdint.h" ]; then
    ok "Headers freestanding do GCC: $gcc_include"
else
    missing "Headers freestanding do GCC (stdint.h não encontrado)"
    fail=1
fi

if [ -n "$gcc_include" ] && [ -f "$gcc_include/stdint.h" ]; then
    if printf '%s\n' \
        '#include <stdint.h>' \
        '#include <stddef.h>' \
        '#include <stdbool.h>' \
        'uint64_t simpleos_check(uint64_t v) { return v + 1; }' \
        | gcc -std=gnu11 -ffreestanding -nostdinc -isystem "$gcc_include" \
              -m64 -march=x86-64 -mno-red-zone -mcmodel=kernel \
              -mno-mmx -mno-sse -mno-80387 -fno-stack-protector -fno-pie \
              -c -x c - -o /dev/null >/dev/null 2>&1; then
        ok "Compilação C freestanding com as flags do projeto"
    else
        missing "Compilação C freestanding com as flags do projeto"
        fail=1
    fi
fi

section "Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    ok "Repositório Git: $(git rev-parse --show-toplevel 2>/dev/null)"
    info "Branch: $(git branch --show-current 2>/dev/null || echo '(sem branch)')"
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
        info "Commit atual: $(git rev-parse --short HEAD)"
    else
        info "Ainda não há commit inicial."
    fi
else
    missing "O diretório não é um repositório Git"
    fail=1
fi

section "QEMU e firmware"
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    if qemu-system-x86_64 -accel help 2>/dev/null | grep -qx 'kvm'; then
        ok "QEMU suporta o acelerador kvm"
    else
        info "QEMU não anunciou o acelerador kvm; use tcg"
    fi
    if qemu-system-x86_64 -accel help 2>/dev/null | grep -qx 'tcg'; then
        ok "QEMU suporta o acelerador tcg"
    else
        missing "QEMU não anunciou o acelerador tcg"
        fail=1
    fi
fi

if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    ok "/dev/kvm acessível para leitura e escrita"
else
    info "/dev/kvm não está acessível; os testes podem usar tcg"
fi

if [ -f /usr/share/ovmf/OVMF.fd ] || [ -f /usr/share/OVMF/OVMF_CODE.fd ]; then
    ok "Firmware OVMF encontrado"
    [ -f /usr/share/ovmf/OVMF.fd ] && info "OVMF combinado: /usr/share/ovmf/OVMF.fd"
    [ -f /usr/share/OVMF/OVMF_CODE.fd ] && info "OVMF CODE: /usr/share/OVMF/OVMF_CODE.fd"
    [ -f /usr/share/OVMF/OVMF_VARS.fd ] && info "OVMF VARS: /usr/share/OVMF/OVMF_VARS.fd"
else
    info "OVMF não encontrado; testes UEFI não estarão disponíveis"
    warn=1
fi

section "Ferramentas de imagem"
for cmd in xorriso mcopy mformat sgdisk mkfs.fat; do
    check_image_tool "$cmd"
done
if ! command -v xorriso >/dev/null 2>&1; then
    info "XORRISO é necessário para a ISO híbrida da Fase 1."
    info "Instalação prevista (não executada): sudo apt install xorriso"
fi

section "Ferramentas opcionais"
for cmd in gdb nasm clang lld genisoimage python3 qemu-img; do
    check_optional "$cmd"
done

section "Resumo"
if [ "$fail" -ne 0 ]; then
    printf 'Resultado: FALHOU — há requisitos obrigatórios ausentes.\n'
    exit 1
fi
if [ "$warn" -ne 0 ]; then
    printf 'Resultado: OK com avisos — ferramentas de imagem ou UEFI pendentes.\n'
else
    printf 'Resultado: OK — requisitos verificados.\n'
fi
exit 0
