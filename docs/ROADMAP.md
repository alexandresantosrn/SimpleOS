# Roadmap do SimpleOS

**Estado atual:** Fase 0 concluída em 20/10/2026; Fase 1 não iniciada.

## Estados permitidos

- `Não iniciada`
- `Em andamento`
- `Bloqueada`
- `Concluída`

Uma fase só pode ser marcada como concluída quando seus critérios de aceite forem atendidos e as evidências forem registradas em `TEST_PLAN.md`.

## Fase 0 — Ambiente e repositório

**Estado:** Concluída em 20/10/2026.

**Objetivo:** build reproduzível e ferramentas identificadas.

- [x] Verificar toolchain, linker, Make, Git, QEMU e ferramentas de imagem.
  - Ferramentas principais verificadas; XORRISO 1.5.4-2 instalado e
    `make check-image-tools` aprovado.
- [x] Fixar versão do Limine.
  - Limine 12.9.4, SHA-256 e header do protocolo fixados.
- [x] Criar estrutura do projeto e documentação.
  - Estrutura inicial, `Makefile`, scripts, smoke test e documentação criados.
- [x] Definir alvos de build/test/run/clean no Makefile.
  - Alvos da Fase 0 implementados; alvos da Fase 1 reservados e bloqueados.
- [x] Documentar comandos exatos.
  - `docs/BUILD.md` e `README.md` atualizados.

**Aceite original:** build e instruções reproduzíveis em um ambiente limpo.

**Critério operacional registrado:** a Fase 0 cobre toolchain, estrutura,
Limine, smoke test e documentação; a geração de imagem e o boot de kernel
pertencem à Fase 1. O aceite foi atendido com:

- XORRISO 1.5.4-2 instalado com autorização explícita;
- `make check-image-tools` e `make test` aprovados;
- commit de código `89a60b57abb53b3f25ab9f899fcd14f3e5b5c02b`;
- clone limpo validado com `make test`, `make check-image-tools`, `make limine`
  e `limine version`.

A ISO híbrida ainda não foi gerada e o boot de kernel continua sendo aceite da
Fase 1.

**Evidências:** `docs/evidence/phase-0/`.

## Fase 1 — Boot mínimo

**Objetivo:** carregar um kernel x86-64 pelo Limine.

- [ ] Configurar protocolo e requisições necessárias.
- [ ] Criar linker script e ponto de entrada.
- [ ] Produzir imagem inicializável.
- [ ] Iniciar no QEMU e obter mensagem de sucesso.

**Aceite:** inicialização repetível no QEMU, com evidência de log.

## Fase 2 — Diagnóstico e infraestrutura básica

- [ ] Logs de diagnóstico.
- [ ] Leitura segura do mapa de memória.
- [ ] Tratamento básico de falhas e exceções.
- [ ] Documentação dos limites conhecidos.

**Aceite:** falhas controladas produzem diagnósticos úteis.

## Fase 3 — Terminal

- [ ] Validar informações de framebuffer.
- [ ] Exibir texto e quebra de linha.
- [ ] Implementar limpeza e controle de posição.
- [ ] Verificar limites de escrita.

**Aceite:** terminal legível e operações básicas estáveis no QEMU.

## Fase 4 — Teclado

- [ ] Definir método inicial de entrada.
- [ ] Ler teclas e converter caracteres.
- [ ] Tratar Enter e Backspace.
- [ ] Limitar tamanho de linha.

**Aceite:** entrada de linha funcional, sem sobrescrita de memória nos limites testados.

## Fase 5 — Shell

- [ ] Implementar parser separado do terminal.
- [ ] Implementar `help`, `clear`, `version` e `echo`.
- [ ] Tratar comandos desconhecidos e argumentos inválidos.
- [ ] Criar testes de parser.

**Aceite:** comandos e erros têm resultados previsíveis.

## Fase 6 — Sistema de arquivos em memória

- [ ] Definir nós, caminhos e diretório atual.
- [ ] Implementar `ls`, `cd`, `mkdir`, `touch`, `cat`, `write`, `rm`, `rmdir`.
- [ ] Testar caminhos inválidos, limites e diretórios não vazios.
- [ ] Documentar que os dados se perdem ao reiniciar.

**Aceite:** operações básicas e casos de erro cobertos por testes.

## Fase 7 — Persistência em disco virtual

- [ ] Definir interface de bloco.
- [ ] Ler setores de um disco virtual.
- [ ] Selecionar e documentar o sistema de arquivos.
- [ ] Implementar escrita dentro do escopo aprovado.
- [ ] Verificar dados após reinicialização.

**Aceite:** arquivo gravado é recuperado após reiniciar o SimpleOS no QEMU.

## Fase 8 — Inicialização por pendrive

- [ ] Validar imagem no QEMU.
- [ ] Documentar partições, arquivos e modo de boot.
- [ ] Criar procedimento de recuperação.
- [ ] Testar em mídia descartável, sem alterar o disco interno.

**Aceite:** boot por USB testado e documentado em equipamento identificado.

## Fase 9 — USB dentro do SimpleOS

- [ ] Identificar controlador USB alvo.
- [ ] Implementar suporte necessário para teclado USB HID.
- [ ] Investigar armazenamento USB e protocolo apropriado.
- [ ] Integrar com armazenamento e sistema de arquivos.
- [ ] Registrar dispositivos físicos efetivamente testados.

**Aceite:** somente os dispositivos documentados são declarados como suportados.

## Fase 10 — Estabilização da versão 0.1

- [ ] Build limpo.
- [ ] Regressão de testes.
- [ ] Teste de persistência.
- [ ] Revisão de buffers, endereços e erros.
- [ ] README atualizado e tag Git criada.

**Aceite:** outra pessoa consegue reproduzir build e testes seguindo a documentação.

## Registro de progresso

| Fase | Estado | Evidência / observações |
|---|---|---|
| 0 — Ambiente | Concluída | Commit de código `89a60b5`; clone limpo e XORRISO 1.5.4-2 aprovados; evidências em `docs/evidence/phase-0/` |
| 1 — Boot mínimo | Não iniciada | |
| 2 — Diagnóstico | Não iniciada | |
| 3 — Terminal | Não iniciada | |
| 4 — Teclado | Não iniciada | |
| 5 — Shell | Não iniciada | |
| 6 — FS em memória | Não iniciada | |
| 7 — Persistência | Não iniciada | |
| 8 — Boot USB | Não iniciada | |
| 9 — USB real | Não iniciada | |
| 10 — Versão 0.1 | Não iniciada | |
