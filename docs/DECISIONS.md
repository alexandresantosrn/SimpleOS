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

**Consequências:** build reproduzível e sem necessidade de NASM. A versão 12.9.4 é a única fixada; qualquer fallback exigirá nova decisão, verificação de hash e atualização da documentação.

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

**Estado:** Aprovada para a Fase 1

**Contexto:** a estratégia de imagem precisa permitir boot BIOS e UEFI no QEMU; o XORRISO foi autorizado e instalado.

**Decisão:** usar ISO híbrida BIOS/UEFI com `limine-bios-cd.bin`, `limine-uefi-cd.bin`, `limine-bios.sys`, `BOOTX64.EFI` e `limine bios-install`, conforme o procedimento oficial do Limine 12.9.4.

**Alternativas:** imagem HDD com mtools + `sgdisk` + FAT, sem depender do XORRISO. A alternativa continua viável e será útil para persistência, mas exige mais etapas de particionamento e formatação.

**Consequências:** a ISO é o caminho oficial mais simples para o primeiro boot; exige o pacote `xorriso 1.5.4-2`, que foi instalado com autorização. A aprovação não valida a ISO: geração e boot continuam sendo testes da Fase 1.

**Evidência:** `xorriso 1.5.4-2`, `make check-image-tools` aprovado e teste de clone limpo em `docs/evidence/phase-0/`.

## ADR-0011 — Licença do projeto

**Estado:** Aprovada

**Contexto:** o projeto precisa de uma licença clara antes de distribuir código ou imagens. O repositório remoto já possui um `LICENSE` MIT com copyright de 2026 de Alexandre Dantas.

**Decisão:** adotar a licença MIT para o código do SimpleOS, mantendo o arquivo `LICENSE` na raiz. A licença permite uso, modificação, distribuição e sublicenciamento, desde que o aviso de copyright e a permissão sejam preservados.

**Alternativas:** BSD-2-Clause, alinhada ao Limine e igualmente permissiva; Apache-2.0, com concessão explícita de patentes e mais obrigações de aviso; GPL-3.0, com copyleft e exigência de abertura de derivados.

**Consequências:** MIT é uma licença de código aberto aprovada pela OSI e reconhecida como livre pela FSF (identificador SPDX `MIT`), simples e compatível com a distribuição do Limine sob BSD-2-Clause. Ela não impõe copyleft, não inclui concessão explícita de patentes e não concede direitos de marca. A compatibilidade e os avisos de terceiros continuam documentados em `docs/THIRD_PARTY.md`.

**Evidência:** `LICENSE` MIT incorporado pelo merge `e2b39af`; análise registrada nesta decisão e em `docs/THIRD_PARTY.md`.

## ADR-0012 — Commits e publicação

**Estado:** Aprovada; push inicial realizado manualmente

**Contexto:** a Fase 0 está em commits locais e o remote `origin` foi configurado. O `LICENSE` remoto foi incorporado por merge, e o push inicial foi executado manualmente em 21/10/2026.

**Decisão:** manter a sincronização sob controle manual. Novos commits só serão publicados por meio de `git push` executado explicitamente.

**Consequências:** o push inicial publicou `2c222b1`, que era o `HEAD` local na ocasião. O upstream está configurado e a árvore de trabalho estava limpa após o push. O clone limpo foi validado e o commit de código `89a60b57abb53b3f25ab9f899fcd14f3e5b5c02b` permanece no histórico. Nenhuma automação de push foi criada.

## Decisões pendentes

- [x] Versão exata do Limine e protocolo utilizado. — v12.9.4, base revision 6.
- [x] Toolchain e alvo de compilação. — GCC 11.4.0, x86_64-linux-gnu, freestanding.
- [ ] Linker script e formato do kernel. — Fase 1.
- [ ] Saída serial e terminal por framebuffer. — Fase 2/3.
- [ ] Estratégia inicial de teclado. — Fase 4.
- [ ] Gerenciamento de memória. — Fase 2.
- [ ] Interface de bloco e dispositivo virtual. — Fase 7.
- [ ] Sistema de arquivos persistente e subconjunto suportado. — Fase 7.
- [x] Formato da imagem inicial. — ISO híbrida BIOS/UEFI aprovada para a Fase 1.
- [ ] Procedimento de boot USB físico. — Fase 8.
- [x] Instalação do XORRISO. — `xorriso 1.5.4-2` instalado e verificado.
- [x] Licença do projeto. — MIT; `LICENSE` na raiz.
- [x] Commit inicial e teste de clone limpo. — commit de código `89a60b5`; clone limpo aprovado.
- [x] Push inicial para `origin` — concluído manualmente em 21/10/2026.
