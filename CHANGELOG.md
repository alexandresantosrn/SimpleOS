# Changelog

Mudanças relevantes do SimpleOS serão registradas aqui.

O formato segue uma adaptação de [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Não lançado]

### Planejado
- Validar inicialização mínima pelo Limine no QEMU.
- Implementar terminal, teclado e shell.
- Implementar sistema de arquivos em memória.
- Investigar persistência em disco virtual.

### Adicionado
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
- README, ADR-0011 e `docs/THIRD_PARTY.md` atualizados para a licença MIT.

### Corrigido
- Removida a alegação de fallback documentado para Limine 12.9.3, que não
  possuía procedimento correspondente.

### Segurança
- Nenhuma mudança registrada.

> Atualize este arquivo com mudanças realmente realizadas. Não registre funcionalidades apenas planejadas como concluídas.
