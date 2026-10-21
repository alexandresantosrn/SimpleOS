#!/bin/sh
#
# Testes de boot da Fase 1 do SimpleOS.
#
# Uso:
#   ./tools/test-boot.sh bios
#   ./tools/test-boot.sh uefi
#   ./tools/test-boot.sh negative
#
# O script apenas usa arquivos dentro de build/ e nunca grava em mídia física.

set -u

MODE=${1:-}
case "$MODE" in
    bios|uefi|negative)
        ;;
    *)
        echo "uso: $0 bios|uefi|negative" >&2
        exit 2
        ;;
esac

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$ROOT_DIR"

BUILD_DIR=build
ISO=$BUILD_DIR/simpleos.iso
ISO_ROOT=$BUILD_DIR/iso_root
NEGATIVE_DIR=$BUILD_DIR/negative
NEGATIVE_ISO=$NEGATIVE_DIR/simpleos-negative.iso
LOG_DIR=$BUILD_DIR/logs
OVMF_CODE=/usr/share/OVMF/OVMF_CODE.fd
OVMF_VARS=/usr/share/OVMF/OVMF_VARS.fd
OVMF_VARS_BUILD=$BUILD_DIR/OVMF_VARS.fd
QEMU=${QEMU:-qemu-system-x86_64}
QEMU_TIMEOUT=${QEMU_TIMEOUT:-15}
LIMINE_TOOL=$BUILD_DIR/limine-binary/limine
XORRISO=${XORRISO:-xorriso}

if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    QEMU_ACCEL=${QEMU_ACCEL:-kvm}
else
    QEMU_ACCEL=${QEMU_ACCEL:-tcg}
fi
QEMU_CPU=${QEMU_CPU:-$([ "$QEMU_ACCEL" = kvm ] && printf host || printf max)}

mkdir -p "$LOG_DIR"

fail() {
    echo "FALHOU: $*" >&2
    exit 1
}

show_log_tail() {
    log=$1
    if [ -f "$log" ]; then
        echo "--- final do log $log ---" >&2
        tail -n 40 "$log" >&2 || true
        echo "--- fim do log ---" >&2
    else
        echo "log ausente: $log" >&2
    fi
}

run_qemu() {
    log=$1
    image=$2

    rm -f "$log"

    if [ "$MODE" = uefi ]; then
        [ -f "$OVMF_CODE" ] || fail "OVMF_CODE ausente: $OVMF_CODE"
        [ -f "$OVMF_VARS" ] || fail "OVMF_VARS ausente: $OVMF_VARS"
        cp "$OVMF_VARS" "$OVMF_VARS_BUILD" || fail "não foi possível copiar OVMF_VARS"
        timeout "$QEMU_TIMEOUT" "$QEMU" \
            -M q35 -m 2G -smp 1 \
            -accel "$QEMU_ACCEL" -cpu "$QEMU_CPU" \
            -net none -no-reboot \
            -drive if=pflash,format=raw,unit=0,readonly=on,file="$OVMF_CODE" \
            -drive if=pflash,format=raw,unit=1,file="$OVMF_VARS_BUILD" \
            -cdrom "$image" -boot d \
            -display none -monitor none -serial "file:$log" \
            >/dev/null 2>&1
    else
        timeout "$QEMU_TIMEOUT" "$QEMU" \
            -M q35 -m 2G -smp 1 \
            -accel "$QEMU_ACCEL" -cpu "$QEMU_CPU" \
            -net none -no-reboot \
            -cdrom "$image" -boot d \
            -display none -monitor none -serial "file:$log" \
            >/dev/null 2>&1
    fi

    return $?
}

check_positive() {
    log=$1
    label=$2
    rc=$3

    if grep -q 'SIMPLEOS_PHASE1_OK' "$log" 2>/dev/null; then
        if [ "$rc" -ne 0 ] && [ "$rc" -ne 124 ]; then
            echo "AVISO: QEMU terminou com código $rc após produzir o marcador."
        fi
        echo "APROVADO: $label encontrou SIMPLEOS_PHASE1_OK."
        return 0
    fi

    echo "FALHOU: $label não encontrou SIMPLEOS_PHASE1_OK (QEMU rc=$rc)." >&2
    show_log_tail "$log"
    return 1
}

make_negative_iso() {
    [ -f "$ISO" ] || fail "ISO base ausente: $ISO"
    [ -d "$ISO_ROOT" ] || fail "árvore da ISO ausente: $ISO_ROOT"
    [ -x "$LIMINE_TOOL" ] || fail "ferramenta Limine ausente: $LIMINE_TOOL"

    rm -rf "$NEGATIVE_DIR"
    mkdir -p "$NEGATIVE_DIR"
    cp -R "$ISO_ROOT" "$NEGATIVE_DIR/iso_root" || fail "não foi possível copiar a árvore da ISO"

    sed 's|path: boot():/boot/limine/kernel.elf|path: boot():/boot/limine/kernel-missing.elf|' \
        "$ISO_ROOT/boot/limine/limine.conf" \
        > "$NEGATIVE_DIR/iso_root/boot/limine/limine.conf" \
        || fail "não foi possível alterar a configuração negativa"

    grep -q 'kernel-missing.elf' "$NEGATIVE_DIR/iso_root/boot/limine/limine.conf" \
        || fail "a configuração negativa não aponta para o kernel ausente"

    "$XORRISO" -as mkisofs -R -r -J \
        -b boot/limine/limine-bios-cd.bin -no-emul-boot \
        -boot-load-size 4 -boot-info-table \
        -hfsplus -apm-block-size 2048 \
        --efi-boot boot/limine/limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        "$NEGATIVE_DIR/iso_root" -o "$NEGATIVE_ISO" \
        >/dev/null 2>&1 || fail "xorriso falhou ao gerar a ISO negativa"

    "$LIMINE_TOOL" bios-install "$NEGATIVE_ISO" >/dev/null 2>&1 \
        || fail "limine bios-install falhou na ISO negativa"
}

printf 'Teste de boot: modo=%s, timeout=%ss, accel=%s, cpu=%s\n' \
    "$MODE" "$QEMU_TIMEOUT" "$QEMU_ACCEL" "$QEMU_CPU"

case "$MODE" in
    bios)
        [ -f "$ISO" ] || fail "ISO ausente: $ISO (execute make iso)"
        log=$LOG_DIR/phase1-bios.log
        run_qemu "$log" "$ISO"
        rc=$?
        check_positive "$log" "boot BIOS" "$rc"
        ;;
    uefi)
        [ -f "$ISO" ] || fail "ISO ausente: $ISO (execute make iso)"
        log=$LOG_DIR/phase1-uefi.log
        run_qemu "$log" "$ISO"
        rc=$?
        check_positive "$log" "boot UEFI" "$rc"
        ;;
    negative)
        make_negative_iso
        log=$LOG_DIR/phase1-negative.log
        run_qemu "$log" "$NEGATIVE_ISO"
        rc=$?

        if grep -q 'SIMPLEOS_PHASE1_OK' "$log" 2>/dev/null; then
            echo "FALHOU: o teste negativo produziu o marcador de sucesso." >&2
            show_log_tail "$log"
            exit 1
        fi

        if grep -Eiq 'error|failed|not found|no such|invalid|missing|inexistente' "$log" 2>/dev/null; then
            echo "APROVADO: teste negativo não produziu o marcador e registrou erro (QEMU rc=$rc)."
        else
            echo "FALHOU: não houve marcador, mas o erro não foi identificado no log (QEMU rc=$rc)." >&2
            show_log_tail "$log"
            exit 1
        fi
        ;;
esac
