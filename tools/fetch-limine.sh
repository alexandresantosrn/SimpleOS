#!/bin/sh
#
# Baixa, verifica e compila o Limine fixado para o SimpleOS.
#
# O script não usa sudo, não instala pacotes e só escreve dentro de build/.
# A versão e o hash são fixos; não use a URL "latest".

set -eu

VERSION=12.9.4
SHA256=847334bc4bc142de996fbd132806b89ed73ac9ab34dbc1e90cfebf1fcc68c2b1
URL="https://github.com/Limine-Bootloader/Limine/releases/download/v${VERSION}/limine-binary.tar.gz"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$ROOT_DIR"

BUILD_DIR=build
DOWNLOAD_DIR="$BUILD_DIR/downloads"
TARBALL="$DOWNLOAD_DIR/limine-binary-${VERSION}.tar.gz"
SOURCE_DIR="$BUILD_DIR/limine-binary"
TOOL="$SOURCE_DIR/limine"

mkdir -p "$DOWNLOAD_DIR"

if [ -f "$TARBALL" ]; then
    printf 'Tarball já existe: %s\n' "$TARBALL"
else
    printf 'Baixando Limine %s...\n' "$VERSION"
    curl -fL --proto '=https' --tlsv1.2 --retry 3 \
        -o "$TARBALL" "$URL"
fi

printf '%s  %s\n' "$SHA256" "$TARBALL" | sha256sum -c -

# A remoção é limitada ao diretório gerado e conhecido dentro de build/.
case "$SOURCE_DIR" in
    build/limine-binary)
        rm -rf "$SOURCE_DIR"
        ;;
    *)
        echo "ERRO: caminho de extração inesperado: $SOURCE_DIR" >&2
        exit 1
        ;;
esac

mkdir -p "$BUILD_DIR"
tar -xzf "$TARBALL" -C "$BUILD_DIR"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERRO: o tarball não criou $SOURCE_DIR" >&2
    exit 1
fi

printf 'Compilando o utilitário limine para o host...\n'
make -C "$SOURCE_DIR"

if [ ! -x "$TOOL" ]; then
    echo "ERRO: utilitário limine não foi gerado em $TOOL" >&2
    exit 1
fi

for required in limine-bios.sys limine-bios-cd.bin limine-uefi-cd.bin BOOTX64.EFI; do
    if [ ! -f "$SOURCE_DIR/$required" ]; then
        echo "ERRO: arquivo esperado ausente: $SOURCE_DIR/$required" >&2
        exit 1
    fi
done

printf '\nLimine %s pronto.\n' "$VERSION"
printf '  Diretório: %s\n' "$SOURCE_DIR"
printf '  Utilitário: %s\n' "$TOOL"
printf '  SHA-256 do tarball: %s\n' "$SHA256"
