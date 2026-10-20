# Evidências da Fase 0

**Data:** 20/10/2026

**Ambiente:** Ubuntu 22.04.5 LTS, x86-64, GCC 11.4.0, binutils 2.38,
GNU Make 4.3, Git 2.34.1, QEMU 6.2.0, GDB 12.1, OVMF 2022.02.

**Estado:** Fase 0 em andamento; não concluída.

## Resultados

| ID | Teste | Comando | Resultado observado | Estado |
|---|---|---|---|---|
| T0.1 | Baseline dos documentos | `sha256sum ... > baseline.sha256` | Hashes originais registrados antes das alterações | Aprovado |
| T0.2 | Verificação da toolchain | `make check-env` | Exit 0; aviso de XORRISO ausente | Aprovado com ressalva |
| T0.3 | Integridade do Limine | `make limine` | SHA-256 conferiu; utilitário compilado | Aprovado |
| T0.4 | Utilitário Limine | `./build/limine-binary/limine version` | `Limine 12.9.4` | Aprovado |
| T0.5 | Header do protocolo | `sha256sum limine.h` | Hash `0aadf...` confere | Aprovado |
| T0.6 | Compilação freestanding | `make smoke` | ELF64 x86-64, sem símbolos indefinidos | Aprovado |
| T0.7 | Limpeza segura | `make clean` | Docs preservados; smoke removido; Limine preservado | Aprovado |
| T0.8 | Alvos da Fase 1 bloqueados | `make kernel`, `make iso`, etc. | Exit 2 com mensagem de Fase 1 | Aprovado |
| T0.9 | Ferramentas de imagem | `make check-image-tools` | Falhou: XORRISO ausente | Bloqueado |
| T0.10 | Reprodução em clone limpo | `git clone` + `make test` | Não executado: ainda não há commit | Não executado |
| T0.11 | Boot do Limine no QEMU | ISO + QEMU | Não executado: XORRISO ausente e Fase 1 não iniciada | Não executado |
| T0.12 | Inicialização do QEMU sem mídia | `timeout 8s qemu-system-x86_64 ...` | Exit 124 por timeout; processo iniciou, sem mídia | Informativo |

## Logs

- `check-env.log` — verificação principal.
- `check-image-tools.log` — falha esperada por XORRISO ausente.
- `limine.log` — download, hash e compilação do Limine.
- `limine-rerun.log` — reutilização do tarball e nova compilação.
- `limine-version.log`, `limine-usage.log` — utilitário Limine.
- `smoke.log` — compilação e inspeção do objeto de teste.
- `test.log`, `final-test.log` — `make test`.
- `make-all.log` — `make all` após limpeza.
- `clean.log` — limpeza de artefatos.
- `phase1-targets.log` — bloqueio explícito dos alvos da Fase 1.
- `qemu-bios-smoke.log` — inicialização do QEMU sem mídia (informativo).
- `help.log`, `print-config.log` — alvos auxiliares.

## Limitações

- XORRISO não está instalado; a ISO híbrida não pode ser gerada.
- Não há commit inicial; o teste de clone limpo não pode ser executado.
- O smoke test compila um objeto, mas não valida linkedição, linker script,
  carregamento pelo Limine ou boot.
- Nenhum teste foi executado em hardware físico.
