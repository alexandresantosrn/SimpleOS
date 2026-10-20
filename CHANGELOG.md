# Changelog

Mudanças relevantes do SimpleOS serão registradas aqui.

O formato segue uma adaptação de [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Não lançado]

### Planejado
- Preparar ambiente e estrutura do repositório.
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

### Alterado
- README atualizado com o estado real da Fase 0, comandos disponíveis e
  pendência de XORRISO.
- Documentação de arquitetura, decisões, roadmap e plano de testes atualizada
  com as decisões e evidências da Fase 0.

### Corrigido
- Nenhuma correção registrada.

### Segurança
- Nenhuma mudança registrada.

> Atualize este arquivo com mudanças realmente realizadas. Não registre funcionalidades apenas planejadas como concluídas.
