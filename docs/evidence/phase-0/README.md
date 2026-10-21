# Evidências da Fase 0

**Data:** 20/10/2026

**Ambiente:** Ubuntu 22.04.5 LTS, x86-64, GCC 11.4.0, binutils 2.38,
GNU Make 4.3, Git 2.34.1, QEMU 6.2.0, GDB 12.1, OVMF 2022.02,
XORRISO 1.5.4-2.

**Estado:** Fase 0 concluída em 20/10/2026 no commit de código
`89a60b57abb53b3f25ab9f899fcd14f3e5b5c02b`; Fase 1 não iniciada.

## Resultados

| ID | Teste | Comando | Resultado observado | Estado |
|---|---|---|---|---|
| T0.1 | Baseline dos documentos | `sha256sum ... > baseline.sha256` | Hashes originais registrados antes das alterações | Aprovado |
| T0.2 | Verificação da toolchain | `make check-env` | Exit 0; requisitos obrigatórios presentes | Aprovado |
| T0.3 | Integridade do Limine | `make limine` | SHA-256 conferiu; utilitário compilado | Aprovado |
| T0.4 | Utilitário Limine | `./build/limine-binary/limine version` | `Limine 12.9.4` | Aprovado |
| T0.5 | Header do protocolo | `sha256sum limine.h` | Hash `0aadf...` confere | Aprovado |
| T0.6 | Compilação freestanding | `make smoke` | ELF64 x86-64, sem símbolos indefinidos | Aprovado |
| T0.7 | Limpeza segura | `make clean` | Docs preservados; smoke removido; Limine preservado | Aprovado |
| T0.8 | Alvos da Fase 1 bloqueados | `make kernel`, `make iso`, etc. | Exit 2 com mensagem de Fase 1 | Aprovado |
| T0.9 | Ferramentas de imagem | `make check-image-tools` | `Resultado: OK — requisitos verificados.` | Aprovado |
| T0.10 | Reprodução em clone limpo | `git clone` + `make test`, `make check-image-tools`, `make limine`, `limine version` | Commit de código `89a60b5`; todos os alvos passaram; `Limine 12.9.4` | Aprovado |
| T0.11 | Boot do Limine no QEMU | ISO + QEMU | Não executado: Fase 1 não iniciada; nenhuma ISO gerada | Não executado |
| T0.12 | Inicialização do QEMU sem mídia | `timeout 8s qemu-system-x86_64 ...` | Exit 124 por timeout; processo iniciou, sem mídia | Informativo |
| T0.13 | Instalação do XORRISO | `command -v xorriso`, `xorriso --version`, `dpkg-query` | `xorriso 1.5.4-2` e dependências presentes | Aprovado |

## Logs

- `check-env.log` — verificação principal anterior à instalação do XORRISO.
- `check-image-tools.log` — falha histórica por XORRISO ausente.
- `check-image-tools-after-xorriso.log` — verificação aprovada após a instalação.
- `xorriso-installed.log` — versão, pacote e dependências do XORRISO.
- `verification-after-xorriso.log` — estado do repositório e resumo das
  verificações após a instalação.
- `clean-clone-phase0.log` — clone limpo do commit de código `89a60b5` com `make test`,
  `make check-image-tools`, `make limine` e `limine version`.
- `test-after-xorriso.log` — `make test` após a instalação.
- `limine.log` — download, hash e compilação do Limine.
- `limine-rerun.log` — reutilização do tarball e nova compilação.
- `limine-version.log`, `limine-usage.log` — utilitário Limine.
- `smoke.log` — compilação e inspeção do objeto de teste.
- `test.log`, `final-test.log` — `make test` anteriores à instalação.
- `make-all.log` — `make all` após limpeza.
- `clean.log` — limpeza de artefatos.
- `phase1-targets.log` — bloqueio explícito dos alvos da Fase 1.
- `qemu-bios-smoke.log` — inicialização do QEMU sem mídia (informativo).
- `help.log`, `print-config.log` — alvos auxiliares.

Os logs anteriores à instalação refletem o estado da época; os arquivos
`*-after-xorriso.log`, `clean-clone-phase0.log` e `xorriso-installed.log`
registram o estado final da Fase 0.

## Limitações

- A ISO híbrida ainda não foi gerada; geração e boot pertencem à Fase 1.
- O smoke test compila um objeto, mas não valida linkedição, linker script,
  carregamento pelo Limine ou boot.
- Nenhum teste foi executado em hardware físico.
- Os logs contêm caminhos locais do ambiente de desenvolvimento; isso não
  altera os resultados, mas deve ser considerado ao publicar as evidências.
