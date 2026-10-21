# Build e ambiente — SimpleOS

**Estado:** Fase 0 concluída em 20/10/2026. O kernel ainda não foi implementado,
nenhuma ISO foi gerada e nenhum boot de kernel foi validado; esses itens
pertencem à Fase 1.

Este documento descreve o que já funciona na Fase 0, as versões verificadas e
os comandos exatos. A geração da imagem e o boot pertencem à Fase 1.

## 1. Escopo da Fase 0

A Fase 0 prepara:

- repositório Git e estrutura inicial;
- verificação das ferramentas do ambiente;
- versão fixada do Limine e verificação de integridade;
- header do protocolo Limine fixado por commit;
- `Makefile` com alvos de verificação, aquisição e smoke test;
- documentação e evidências.

**Fora do escopo desta fase:** kernel, ponto de entrada, linker script,
terminal, shell, sistema de arquivos, ISO com kernel e boot no QEMU.

## 2. Ambiente verificado

Verificação executada em 20/10/2026:

| Ferramenta | Versão / observação | Situação |
|---|---|---|
| Ubuntu | 22.04.5 LTS, x86-64 | OK |
| GCC | 11.4.0, alvo `x86_64-linux-gnu` | OK |
| GNU binutils | 2.38 | OK |
| GNU Make | 4.3 | OK |
| Git | 2.34.1 | OK |
| QEMU | 6.2.0 | OK |
| GDB | 12.1 | OK (opcional) |
| OVMF | 2022.02 | OK |
| mtools | 4.0.32 | OK |
| dosfstools | 4.2 | OK |
| `sgdisk` | 1.0.8 | OK |
| XORRISO | 1.5.4-2, `/usr/bin/xorriso` | OK |
| NASM | ausente | opcional; não usado |
| Clang/LLD | ausentes | opcional; não usados |

O GCC nativo do Ubuntu é usado como compilador freestanding. Não é necessário
um compilador cruzado `x86_64-elf` para esta fase.

O XORRISO foi instalado com autorização explícita em 20/10/2026. O pacote
`xorriso 1.5.4-2` trouxe as dependências `libisoburn1 1.5.4-2`,
`libburn4 1.5.4-1`, `libisofs6 1.5.4-1` e `libjte2 1.22-3build1`. O comando
registrado no histórico do APT foi:

```sh
sudo apt-get install -y xorriso
```

A ferramenta é necessária para criar a ISO híbrida BIOS/UEFI; não é necessária
para compilar o kernel nem para executar o QEMU.

## 3. Comandos da Fase 0

### 3.1 Verificar o ambiente

```sh
make check-env
```

Verifica as ferramentas principais, o alvo do GCC, os headers freestanding,
o Git, o QEMU, o OVMF e as ferramentas de imagem. Não instala nada e não usa
`sudo`.

### 3.2 Verificar ferramentas de imagem

```sh
make check-image-tools
```

Este alvo exige XORRISO, mtools, `sgdisk` e `dosfstools`. No ambiente atual
todos os requisitos estão presentes e o comando termina com:

```text
Resultado: OK — requisitos verificados.
```

O alvo não instala pacotes. A instalação do XORRISO foi feita separadamente,
com autorização explícita, conforme a seção 2.

### 3.3 Baixar e compilar o Limine

```sh
make limine
```

O comando:

1. baixa `limine-binary-12.9.4.tar.gz` da URL fixa;
2. verifica o SHA-256;
3. extrai o conteúdo em `build/limine-binary/`;
4. compila o utilitário `limine` para o host;
5. confere os arquivos de boot esperados.

O utilitário gerado fica em:

```text
build/limine-binary/limine
```

### 3.4 Smoke test de toolchain

```sh
make smoke
```

Compila `tests/toolchain-smoke.c` como objeto ELF64 x86-64, usando as flags
freestanding do projeto. Esse alvo **não** cria kernel, não linka um executável
e não inicializa o QEMU.

Resultado esperado:

- `ELF 64-bit LSB relocatable, x86-64`;
- `Class: ELF64`;
- `Machine: Advanced Micro Devices X86-64`;
- nenhum símbolo indefinido.

### 3.5 Executar os testes disponíveis

```sh
make test
```

Equivale a `make check-env` seguido de `make smoke`.

### 3.6 Limpeza

```sh
make clean
```

Remove o objeto de smoke e eventuais artefatos de ISO/kernel, preservando
`build/downloads/` e o Limine já extraído. Nunca remove `docs/`, fontes ou
documentação.

```sh
make distclean
```

Remove todo o diretório `build/`, incluindo downloads. Use quando quiser
reproduzir a aquisição do Limine desde o início.

## 4. Limine fixado

| Item | Valor |
|---|---|
| Versão | 12.9.4 |
| URL | `https://github.com/Limine-Bootloader/Limine/releases/download/v12.9.4/limine-binary.tar.gz` |
| SHA-256 | `847334bc4bc142de996fbd132806b89ed73ac9ab34dbc1e90cfebf1fcc68c2b1` |
| Base revision | 6 |
| `limine.h` | commit `3a0526b700e356f0eac1b71a77697b3fd1c707a3` |
| SHA-256 de `limine.h` | `0aadf2633c85d8cb145344c968add158aeb1deb68af567d55ba8431c492b6d4c` |
| Licença do Limine | BSD-2-Clause |

O hash é verificado antes da extração. Não use a URL `latest` em builds
reproduzíveis. Para trabalhar offline, mantenha o tarball em
`build/downloads/limine-binary-12.9.4.tar.gz`; o script reutiliza o arquivo e
verifica o hash.

## 5. Flags de compilação

As flags atuais estão em `Makefile`. Elas incluem:

```text
-ffreestanding -fno-stack-protector -fno-stack-clash-protection
-fno-common -fno-PIC -fno-pie -mno-red-zone -mcmodel=kernel
-mno-mmx -mno-sse -mno-80387 -fcf-protection=none
-nostdinc -isystem <diretório de headers do GCC>
```

Observações:

- `-fno-pie` e `-fno-PIC` são necessários porque o GCC do Ubuntu é configurado
  com PIE por padrão; `-mcmodel=kernel` não funciona com PIE.
- `-nostdinc` remove os headers da libc. Os headers freestanding do próprio GCC
  são usados via `-isystem`.
- A linkagem com `-nostdlib` não inclui `libgcc`. Operações que gerem helpers
  de divisão ou aritmética de 128 bits precisam ser evitadas ou implementadas
  na Fase 2.
- `-mcmodel=kernel` exige que o linker script coloque o kernel nos 2 GiB
  superiores; isso será validado na Fase 1.

## 6. Artefatos

| Caminho | Conteúdo | Rastreado? |
|---|---|---|
| `build/downloads/limine-binary-12.9.4.tar.gz` | Tarball verificado | Não |
| `build/limine-binary/` | Limine extraído e utilitário compilado | Não |
| `build/smoke/toolchain-smoke.o` | Objeto do smoke test | Não |
| `build/logs/` | Logs locais de execução | Não |
| `docs/evidence/phase-0/` | Evidências selecionadas | Sim |

## 7. Próxima fase — não implementada

Os alvos abaixo existem apenas para falhar com mensagem clara enquanto a Fase 1
não for autorizada:

```sh
make kernel
make iso
make run
make run-uefi
make debug
```

Quando a Fase 1 for aprovada, o fluxo previsto será:

```text
src/ + linker script
        |
        v
build/kernel.elf
        |
        v
build/iso_root/ + Limine
        |
        v
build/simpleos.iso
        |
        v
QEMU BIOS / QEMU UEFI
```

A ISO híbrida prevista usará:

```sh
xorriso -as mkisofs -R -r -J \
  -b boot/limine/limine-bios-cd.bin -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -hfsplus -apm-block-size 2048 \
  --efi-boot boot/limine/limine-uefi-cd.bin \
  -efi-boot-part --efi-boot-image --protective-msdos-label \
  build/iso_root -o build/simpleos.iso

build/limine-binary/limine bios-install build/simpleos.iso
```

**Nada acima foi executado nesta fase.**

## 8. Segurança

- Não execute `sudo` nem instale pacotes sem autorização explícita.
- Não grave imagens em discos físicos, pendrives ou outras mídias.
- Use apenas imagens virtuais descartáveis no QEMU.
- Não declare a Fase 0 ou a Fase 1 concluídas sem as evidências correspondentes.
- Não faça commit ou push sem autorização.
