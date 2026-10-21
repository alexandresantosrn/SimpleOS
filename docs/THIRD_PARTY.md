# Componentes de terceiros

Este documento registra versões, hashes e licenças de componentes externos
usados pelo SimpleOS. A Fase 0 não distribui uma imagem inicializável; os
avisos abaixo já preparam a distribuição futura.

## Limine

| Item | Valor |
|---|---|
| Projeto | Limine Bootloader |
| Versão | 12.9.4 |
| Release | 19/10/2026 |
| Artefato | `limine-binary.tar.gz` |
| SHA-256 | `847334bc4bc142de996fbd132806b89ed73ac9ab34dbc1e90cfebf1fcc68c2b1` |
| Licença | BSD-2-Clause |
| Uso no projeto | Bootloader da ISO híbrida BIOS/UEFI |

O tarball contém `LICENSE` e `3RDPARTY.md`. Ao distribuir uma imagem que inclua
o Limine, esses arquivos devem acompanhar a distribuição, conforme os termos
da licença e os avisos de terceiros do projeto.

## Header do protocolo Limine

| Item | Valor |
|---|---|
| Repositório | `Limine-Bootloader/limine-protocol` |
| Commit | `3a0526b700e356f0eac1b71a77697b3fd1c707a3` |
| Arquivo | `include/limine.h` |
| SHA-256 | `0aadf2633c85d8cb145344c968add158aeb1deb68af567d55ba8431c492b6d4c` |
| Licença | Permissiva, estilo ISC (copyright e permissão ampla) |
| Uso no projeto | Estruturas e requisições do protocolo Limine |

O texto completo da licença está em `third_party/limine-protocol/LICENSE`.

## Ferramentas de build

GCC, GNU binutils, GNU Make, QEMU, OVMF, mtools, dosfstools, `sgdisk`, Git e
XORRISO são ferramentas do ambiente hospedeiro, não são incorporadas ao
kernel. As versões verificadas estão em `docs/BUILD.md` e nas evidências da
Fase 0.

| Ferramenta | Versão instalada | Uso no projeto | Incorporada? |
|---|---|---|---|
| XORRISO | 1.5.4-2 | Criação da ISO híbrida BIOS/UEFI | Não |

O pacote `xorriso` depende de `libisoburn1 1.5.4-2`, `libburn4 1.5.4-1`,
`libisofs6 1.5.4-1` e `libjte2 1.22-3build1`; essas bibliotecas também são
componentes do ambiente hospedeiro e não são distribuídas com o kernel.

## Licença do SimpleOS

O código do SimpleOS é distribuído sob a licença **MIT**, com copyright de
2026 de Alexandre Dantas. O texto completo está em [`LICENSE`](../LICENSE).

A MIT é permissiva e compatível com a distribuição do Limine sob BSD-2-Clause.
Os avisos de copyright e licença de componentes de terceiros continuam
necessários e estão documentados neste arquivo. A licença do projeto não
concede direitos de marca nem uma concessão explícita de patentes.
