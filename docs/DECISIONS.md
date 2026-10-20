# Registro de decisões técnicas

Este documento registra decisões aprovadas, alternativas consideradas e razões. Não transforme sugestões em decisões confirmadas sem validação.

## Modelo de registro

Para cada decisão, documente:
- **ID:** `ADR-0001`, `ADR-0002` etc.
- **Estado:** Proposta, Aprovada, Rejeitada ou Substituída.
- **Contexto:** qual problema precisa ser resolvido.
- **Decisão:** o que será usado.
- **Alternativas:** opções consideradas.
- **Consequências:** benefícios, custos e limitações.
- **Evidência:** testes, documentação ou protótipo que sustentam a decisão.

---

## ADR-0001 — Arquitetura inicial

**Estado:** Aprovada para a Fase 0

**Contexto:** precisamos de um alvo controlável para um primeiro sistema operacional educacional.

**Decisão proposta:** começar com x86-64, C freestanding e teste no QEMU.

**Alternativas:** outras arquiteturas e desenvolvimento inicial em hardware físico.

**Consequências:** boa disponibilidade de ferramentas e virtualização; ainda será necessário compreender ABI, linker, boot protocol e hardware de baixo nível.

**Evidência:** a registrar após a preparação do ambiente.

## ADR-0002 — Bootloader

**Estado:** Aprovada; detalhes de versão e pinagem em ADR-0006

**Contexto:** escrever um bootloader próprio aumentaria bastante o escopo inicial.

**Decisão proposta:** utilizar Limine e fixar uma versão específica no projeto.

**Alternativas:** escrever bootloader próprio ou adotar outra solução.

**Consequências:** simplifica o fluxo de boot, mas o kernel deve implementar corretamente o protocolo escolhido e a mídia precisa conter os arquivos no local esperado.

**Evidência:** registrar versão, documentação usada e teste no QEMU.

## ADR-0003 — Ambiente de testes

**Estado:** Aprovada; detalhes de QEMU/OVMF em ADR-0007

**Contexto:** testar diretamente em hardware aumenta o risco e dificulta depuração.

**Decisão proposta:** usar QEMU como ambiente principal no início.

**Alternativas:** testar somente em hardware físico.

**Consequências:** ciclos de teste rápidos e discos virtuais descartáveis; a emulação não garante compatibilidade física.

**Evidência:** log de boot e instruções reproduzíveis.

## ADR-0004 — Sistema de arquivos em etapas

**Estado:** Proposta

**Contexto:** semântica de arquivos e acesso persistente a blocos são problemas distintos.

**Decisão proposta:** implementar primeiro um sistema de arquivos em memória e depois a persistência em disco virtual.

**Alternativas:** iniciar diretamente com um sistema de arquivos persistente.

**Consequências:** facilita testar operações de diretórios antes de lidar com drivers, setores e corrupção de dados; haverá trabalho adicional de integração.

**Evidência:** testes da Fase 6 e da Fase 7.

## ADR-0005 — Toolchain da Fase 0

**Estado:** Aprovada para a Fase 0

**Contexto:** o ambiente já possui GCC e binutils nativos; instalar uma toolchain cruzada ou Clang/LLD adicionaria dependências sem necessidade imediata.

**Decisão:** usar GCC 11.4.0 com alvo `x86_64-linux-gnu` e GNU binutils 2.38, em modo freestanding, com `-fno-pie`, `-mcmodel=kernel`, `-mno-red-zone`, `-mno-sse`, `-mno-mmx`, `-mno-80387`, `-fno-stack-protector` e `-nostdinc` usando os headers freestanding do próprio GCC.

**Alternativas:** instalar Clang/LLD 14 ou uma toolchain cruzada `x86_64-elf`.

**Consequências:** menos dependências e uso direto do ambiente disponível; a linkagem real e eventuais helpers de compilador ainda precisam ser validados na Fase 1/2.

**Evidência:** `make check-env`, `make smoke` e logs em `docs/evidence/phase-0/`.

## ADR-0006 — Limine fixado

**Estado:** Aprovada para a Fase 0

**Contexto:** o projeto precisa de uma versão reproduzível do bootloader.

**Decisão:** usar a release binária do Limine 12.9.4, base revision 6, com URL fixa e SHA-256 `847334bc4bc142de996fbd132806b89ed73ac9ab34dbc1e90cfebf1fcc68c2b1`. O header do protocolo é fixado no commit `3a0526b700e356f0eac1b71a77697b3fd1c707a3`.

**Alternativas:** compilar o Limine a partir do código-fonte, exigindo NASM e mais ferramentas; usar a URL `latest`, que não é reproduzível.

**Consequências:** build reproduzível e sem necessidade de NASM; a versão 12.9.4 é recente e tem fallback documentado para 12.9.3.

**Evidência:** `make limine`, verificação de SHA-256 e `limine version` em `docs/evidence/phase-0/`.

## ADR-0007 — QEMU e firmware de teste

**Estado:** Aprovada para a Fase 0

**Contexto:** o ambiente de testes inicial deve ser virtual e reproduzível.

**Decisão:** usar QEMU 6.2.0 com máquina `q35`, 2 GiB de RAM, SeaBIOS para BIOS e OVMF 2022.02 para UEFI. KVM é preferencial quando acessível; TCG é o fallback.

**Alternativas:** testar apenas em hardware físico ou usar outro firmware.

**Consequências:** ciclos rápidos e discos virtuais descartáveis; a emulação não prova compatibilidade com hardware físico.

**Evidência:** `make check-env` e execução de teste de inicialização do QEMU com KVM; o boot real pertence à Fase 1.

## ADR-0008 — Escopo estrito da Fase 0

**Estado:** Aprovada para a Fase 0

**Contexto:** a Fase 0 deve preparar o ambiente sem antecipar a implementação do kernel.

**Decisão:** a Fase 0 inclui verificação de ferramentas, Git, estrutura, Makefile, pinagem do Limine, smoke test de compilação e documentação. Não inclui `src/main.c`, linker script, `entry.S`, ISO com kernel ou boot de kernel.

**Alternativas:** incluir um kernel mínimo ou uma ISO apenas com o Limine.

**Consequências:** o aceite da Fase 0 não prova boot; essa evidência fica explicitamente para a Fase 1. Os alvos `kernel`, `iso`, `run`, `run-uefi` e `debug` falham com mensagem clara.

**Evidência:** `docs/BUILD.md`, `docs/ROADMAP.md` e logs dos alvos da Fase 1.

## ADR-0009 — Headers freestanding

**Estado:** Aprovada para a Fase 0

**Contexto:** o kernel não pode depender de headers da libc do hospedeiro.

**Decisão:** usar `-nostdinc` com `-isystem $(gcc -print-file-name=include)`, aproveitando `stdint.h`, `stddef.h`, `stdbool.h`, `stdarg.h` e `limits.h` do GCC.

**Alternativas:** vendorizar `freestanding-c-hdrs` ou escrever headers próprios.

**Consequências:** menos dependências agora; a estratégia deve ser reavaliada se a reprodutibilidade entre versões de compilador se tornar um requisito forte.

**Evidência:** `make check-env` e `make smoke`.

## ADR-0010 — Geração da imagem

**Estado:** Proposta

**Contexto:** a estratégia de imagem depende do XORRISO, que não está instalado.

**Decisão proposta:** usar ISO híbrida BIOS/UEFI com `limine-bios-cd.bin`, `limine-uefi-cd.bin`, `limine-bios.sys`, `BOOTX64.EFI` e `limine bios-install`.

**Alternativas:** imagem HDD com mtools + `sgdisk` + FAT, sem instalar XORRISO.

**Consequências:** a ISO é o caminho oficial mais simples, mas exige autorização para instalar `xorriso`; a imagem HDD é mais trabalhosa e será necessária para persistência.

**Evidência:** ainda não há; a instalação e o teste pertencem à Fase 1.

## ADR-0011 — Licença do projeto

**Estado:** Pendente

**Contexto:** o projeto ainda não tem licença definida.

**Decisão proposta:** definir uma licença permissiva antes de distribuir código ou imagens; sugerir BSD-2-Clause para compatibilidade com o Limine.

**Consequências:** sem licença, o status de distribuição permanece indefinido.

## ADR-0012 — Commits e publicação

**Estado:** Pendente

**Contexto:** a Fase 0 foi executada, mas não há autorização para commit ou push.

**Decisão proposta:** permitir um commit local da Fase 0 após revisão; push e publicação exigem autorização separada.

**Consequências:** as evidências ainda não têm um identificador de commit; o teste de clone limpo permanece não executado.

## Decisões pendentes

- [x] Versão exata do Limine e protocolo utilizado. — v12.9.4, base revision 6.
- [x] Toolchain e alvo de compilação. — GCC 11.4.0, x86_64-linux-gnu, freestanding.
- [ ] Linker script e formato do kernel. — Fase 1.
- [ ] Saída serial e terminal por framebuffer. — Fase 2/3.
- [ ] Estratégia inicial de teclado. — Fase 4.
- [ ] Gerenciamento de memória. — Fase 2.
- [ ] Interface de bloco e dispositivo virtual. — Fase 7.
- [ ] Sistema de arquivos persistente e subconjunto suportado. — Fase 7.
- [ ] Formato da imagem e procedimento de boot USB. — ISO proposta; XORRISO pendente.
- [ ] Instalação do XORRISO. — requer autorização explícita.
- [ ] Licença do projeto. — ADR-0011.
- [ ] Commit inicial e teste de clone limpo. — ADR-0012.
