# Changelog

Mudanças relevantes do SimpleOS serão registradas aqui.

O formato segue uma adaptação de [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Não lançado]

### Planejado
- Implementar terminal, teclado e shell.
- Implementar sistema de arquivos em memória.
- Investigar persistência em disco virtual.

### Adicionado
- Kernel mínimo freestanding em `src/main.c`, com entrada `kernel_main`,
  requisições Limine (base revision 6, bootloader info e firmware type) e
  parada controlada.
- Saída serial COM1 em `src/serial.c`/`src/serial.h`.
- Linker script `src/linker.ld` para ELF64 `ET_EXEC` não-PIE em
  `0xffffffff80000000`, com `.limine_requests` preservada.
- Configuração `config/limine.conf` com `paging_mode: 4level`.
- Alvos `kernel`, `iso`, `run`, `run-uefi`, `debug`, `test-boot-bios`,
  `test-boot-uefi`, `test-boot-negative` e `test-phase1` no `Makefile`.
- Harness `tools/test-boot.sh` com captura serial, timeout, repetibilidade e
  teste negativo.
- ISO híbrida BIOS/UEFI gerada com XORRISO e `limine bios-install`.
- Boot validado no QEMU em BIOS, BIOS repetido e UEFI/OVMF, com o marcador
  `SIMPLEOS_PHASE1_OK`.
- Evidências em `docs/evidence/phase-1/`.
- Esqueleto inicial da documentação do projeto.
- `.gitignore` para artefatos de build e arquivos locais.
- `Makefile` com alvos de verificação de ambiente, aquisição do Limine,
  smoke test, limpeza e alvos reservados para a Fase 1.
- Script `tools/check-env.sh` para verificar ferramentas e versões sem
  instalar pacotes.
- Script `tools/fetch-limine.sh` para baixar, verificar por SHA-256 e
  compilar o Limine 12.9.4.
- Smoke test de compilação freestanding em `tests/toolchain-smoke.c`.
- Header `limine.h` fixado pelo commit
  `3a0526b700e356f0eac1b71a77697b3fd1c707a3`.
- Documentação de build em `docs/BUILD.md`, registro de terceiros em
  `docs/THIRD_PARTY.md` e evidências em `docs/evidence/phase-0/`.
- Repositório Git inicializado na branch `main`.
- XORRISO 1.5.4-2 instalado com autorização, com as dependências
  `libisoburn1`, `libburn4`, `libisofs6` e `libjte2`.
- Commit de código da Fase 0 `89a60b5` e teste de clone limpo aprovado.
- Licença MIT (`LICENSE`) incorporada do repositório remoto por merge.
- Remote `origin` configurado para `https://github.com/alexandresantosrn/SimpleOS.git`;
  push inicial executado manualmente em 21/10/2026.

### Alterado
- README atualizado com a Fase 0 concluída, comandos disponíveis e XORRISO
  instalado.
- Documentação de build, decisões, roadmap, plano de testes, terceiros e
  depuração atualizada com o XORRISO 1.5.4-2 e o teste de clone limpo.
- README, arquitetura, build, roadmap, plano de testes, decisões e depuração
  atualizados com os resultados reais da Fase 1.
- `make test` preservado para a Fase 0; `make test-phase1` adicionado para
  build, BIOS, UEFI, repetibilidade e cenário negativo.
- README, ADR-0011 e `docs/THIRD_PARTY.md` atualizados para a licença MIT.

### Corrigido
- Removida a alegação de fallback documentado para Limine 12.9.3, que não
  possuía procedimento correspondente.
- Linker script corrigido para manter `.limine_requests` como seção própria,
  gravável e entre os marcadores do protocolo.
- Validação da ISO corrigida para usar `xorriso -find -exec lsdl`.

### Segurança
- Nenhuma mudança registrada.

> Atualize este arquivo com mudanças realmente realizadas. Não registre funcionalidades apenas planejadas como concluídas.
