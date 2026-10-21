# Evidências da Fase 1 — 21/10/2026

## Identificação

- **Commit base antes da Fase 1:** `0add865` (`HEAD` e `origin/main` antes do
  commit da Fase 1; remoto no mesmo commit).
- **Alterações da Fase 1:** commit local criado; push não realizado.
- **Instalações nesta fase:** nenhuma. O XORRISO 1.5.4-2 foi instalado na
  Fase 0, em 20/10/2026, com autorização explícita.
- **Ambiente:** Ubuntu 22.04.5 LTS, x86-64.
- **Ferramentas:** GCC 11.4.0, binutils 2.38, GNU Make 4.3, Git 2.34.1,
  QEMU 6.2.0, GDB 12.1, OVMF 2022.02, XORRISO 1.5.4-2, Limine 12.9.4.
- **QEMU:** máquina `q35`, 2 GiB, uma CPU, KVM com `-cpu host`.
- **Kernel:** ELF64 `ET_EXEC`, entrada `0xffffffff80001000`, primeiro `PT_LOAD`
  em `0xffffffff80000000`.
- **SHA-256 do kernel:** `b388adb400b010c92fd78e8a16f511a7d0b9c0e5dbc70fb5ec089adb0c2b35c8`.
- **SHA-256 da ISO:** `c812f9a955b3bf57ea5063f443abf8186116e7b3cd35718f9babfe43588ca71d`.

## Arquivos e artefatos

- `src/main.c`: entrada, requisições Limine e mensagens.
- `src/serial.c`, `src/serial.h`: serial COM1.
- `src/linker.ld`: layout ELF64 high-half e `.limine_requests`.
- `config/limine.conf`: configuração da ISO e `paging_mode: 4level`.
- `tools/test-boot.sh`: harness de boot.
- `build/kernel.elf`: kernel gerado.
- `build/simpleos.iso`: ISO híbrida BIOS/UEFI.
- `build/kernel.map`: mapa de linkedição.

## Nota sobre os logs

Os logs de serial foram copiados do QEMU e normalizados para LF, com remoção de
espaços à direita, para armazenamento no Git. O conteúdo das mensagens foi
preservado; as execuções originais ficam em `build/logs/` durante a validação.

## Resultados

| ID | Resultado | Evidência |
|---|---|---|
| T1.1 | `make kernel` exit 0; `nm -u` vazio | `kernel-build.log` |
| T1.2 | `ET_EXEC`; high half; `.limine_requests` presente | `kernel-readelf.log` |
| T1.3 | ISO com os seis arquivos exigidos; `bios-install` OK | `iso-build.log`, `iso-files.txt` |
| T1.4 | BIOS: marcador encontrado | `qemu-bios-run1.log` |
| T1.5 | BIOS repetido: marcador encontrado | `qemu-bios-run2.log` |
| T1.6 | UEFI/OVMF: marcador encontrado | `qemu-uefi.log` |
| T1.7 | Caminho inválido: Limine PANIC; marcador ausente | `qemu-negative.log` |
| T1.8 | `make test` e `make check-image-tools` aprovados | `phase0-test.log`, `phase0-image-tools.log` |
| T1.9 | `make test-phase1` aprovado após rebuild limpo | `phase1-test.log` |

## Marcadores

Saída BIOS (primeira execução):

```text
[simpleos] SimpleOS Phase 1
[simpleos] base revision: 6
[simpleos] Limine: Limine 12.9.4
[simpleos] Firmware: BIOS
[simpleos] SIMPLEOS_PHASE1_OK
```

Saída UEFI:

```text
[simpleos] SimpleOS Phase 1
[simpleos] base revision: 6
[simpleos] Limine: Limine 12.9.4
[simpleos] Firmware: UEFI
[simpleos] SIMPLEOS_PHASE1_OK
```

O teste negativo registrou:

```text
limine: Failed to open executable with path `boot():/boot/limine/kernel-missing.elf`. Is the path correct?
PANIC: limine: Failed to open executable...
```

e não produziu `SIMPLEOS_PHASE1_OK`.

## Comandos executados

```sh
make clean
make kernel
file build/kernel.elf
readelf -h build/kernel.elf
readelf -l build/kernel.elf
readelf -S build/kernel.elf
nm -u build/kernel.elf
make iso
make test
make check-image-tools
make test-phase1
```

O `make test-phase1` executou:

- `make test` (Fase 0);
- `make kernel`;
- `make iso` quando necessário;
- `make test-boot-bios`;
- `make test-boot-uefi`;
- `make test-boot-negative`.

## Limitações

- Validação somente no QEMU; não há teste em hardware físico.
- Diagnóstico somente pela serial COM1; não há framebuffer, terminal, teclado,
  shell, sistema de arquivos ou IDT própria.
- O log UEFI contém sequências ANSI emitidas pelo OVMF antes das mensagens do
  kernel; o marcador é pesquisado no arquivo completo.
- O kernel não trata exceções; falhas nessa área pertencem à Fase 2.
- O driver serial usa polling sem timeout; em hardware sem COM1 o kernel pode
  bloquear antes de emitir o marcador.
- Os testes foram executados com KVM. O fallback TCG do script não foi
  exercitado nesta validação.
- Os testes não provam persistência nem compatibilidade com hardware real.

## Observação sobre o Git

O commit local da Fase 1 foi criado nesta execução; nenhum push foi realizado.
`git-status.txt` e `git-diff-stat.txt` são snapshots do estado **anterior** ao
commit, preservados como evidência do escopo alterado. O código e a ISO
referenciados acima correspondem à árvore de trabalho validada antes do commit.
