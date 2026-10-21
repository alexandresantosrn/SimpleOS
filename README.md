# SimpleOS

Sistema operacional educacional x86-64, desenvolvido majoritariamente em C, com inicialização pelo Limine e testes iniciais no QEMU.

> **Estado atual:** Fase 0 concluída em 20/10/2026; Fase 1 concluída em
> 21/10/2026. O SimpleOS já possui um kernel mínimo x86-64 carregado pelo
> Limine, com diagnóstico pela serial COM1 e boot validado no QEMU em BIOS e
> UEFI. A Fase 1 está registrada em commit local; o push para o remoto
> permanece pendente e depende de autorização.

## Objetivos

- Inicializar um kernel x86-64 pelo Limine.
- Exibir um terminal textual e receber comandos pelo teclado.
- Implementar um shell simples.
- Manipular arquivos e diretórios.
- Começar com sistema de arquivos em memória e evoluir para persistência em disco virtual.
- Gerar uma imagem inicializável e testar em hardware selecionado, após validação no QEMU.

## Escopo inicial

### Incluído
- Kernel freestanding em C.
- Boot pelo Limine.
- Diagnóstico por saída serial.
- Terminal textual.
- Teclado e shell básicos.
- Operações básicas de arquivos e diretórios.
- Testes em QEMU.

### Fora do escopo inicial
- Interface gráfica, rede, áudio, Wi-Fi, Bluetooth, compatibilidade com Linux, multitarefa e suporte universal a hardware.

## Arquitetura pretendida

```text
Firmware BIOS/UEFI
    |
    v
Limine 12.9.4
    |
    v
Kernel SimpleOS
    ├── Inicialização e diagnóstico serial
    ├── Gerenciamento de memória (fase futura)
    ├── Terminal e entrada (fase futura)
    ├── Shell e parser (fase futura)
    ├── Sistema de arquivos (fase futura)
    └── Driver de armazenamento (fase futura)
```

A arquitetura evolui conforme as fases são validadas. A Fase 1 cobre apenas
boot, diagnóstico serial mínimo e parada controlada do kernel.

## Requisitos e ferramentas

As versões verificadas e os comandos exatos estão em `docs/BUILD.md`. O ambiente atual tem:

- GCC 11.4.0 e GNU binutils 2.38, usados em modo freestanding x86-64.
- GNU Make 4.3 e Git 2.34.1.
- QEMU 6.2.0 e OVMF 2022.02 para testes virtuais.
- GDB 12.1 para depuração.
- Limine 12.9.4 fixado por versão e SHA-256.
- mtools, dosfstools e `sgdisk` para futuras imagens de disco.
- XORRISO 1.5.4-2, necessário para gerar a ISO híbrida da Fase 1.

Não presuma que as versões disponíveis no sistema hospedeiro são compatíveis sem verificar.

## Compilar, gerar a imagem e executar

```sh
make                  # Fase 0: verifica o ambiente e compila o smoke test
make test             # Fase 0: check-env + smoke
make kernel           # compila e valida build/kernel.elf
make iso              # gera e valida build/simpleos.iso
make run              # inicia a ISO no QEMU via BIOS
make run-uefi         # inicia a ISO no QEMU via UEFI/OVMF
make debug            # inicia o QEMU parado para GDB
make test-phase1      # Fase 0 + build + BIOS + UEFI + negativo
make test-boot-bios   # somente o teste de boot BIOS
make test-boot-uefi   # somente o teste de boot UEFI
make test-boot-negative # teste com caminho de kernel inválido
```

O kernel emite o diagnóstico pela serial COM1. Nos alvos de teste, o QEMU usa
`-serial file:` e o log fica em `build/logs/`. A mensagem de sucesso procurada
é:

```text
SIMPLEOS_PHASE1_OK
```

O alvo padrão `make` e o alvo `make test` continuam com o comportamento da
Fase 0. Os testes da Fase 1 exigem `make kernel`/`make iso` e são executados
separadamente por `make test-phase1`.

Consulte `docs/BUILD.md` para os comandos detalhados. As evidências da Fase 0
estão em `docs/evidence/phase-0/`; as da Fase 1, em
`docs/evidence/phase-1/`.

## Documentação

- `AGENTS.md`: regras para agentes de IA.
- `docs/ARCHITECTURE.md`: arquitetura e interfaces.
- `docs/ROADMAP.md`: fases, estados e critérios de aceite.
- `docs/TEST_PLAN.md`: plano de testes.
- `docs/DECISIONS.md`: decisões técnicas e alternativas.
- `docs/DEBUGGING.md`: diagnóstico de problemas conhecidos.
- `docs/BUILD.md`: comandos exatos, versões e artefatos de build.
- `docs/THIRD_PARTY.md`: versões, hashes e licenças de terceiros.
- `docs/evidence/phase-0/`: evidências verificáveis da Fase 0.
- `docs/evidence/phase-1/`: evidências de build, ISO e boot da Fase 1.
- `CHANGELOG.md`: histórico de mudanças.

## Licença

O SimpleOS é distribuído sob a licença MIT. Consulte [`LICENSE`](LICENSE).
Os avisos de terceiros estão em `docs/THIRD_PARTY.md`.

## Regras de segurança

- Validar o boot no QEMU antes de testar em hardware.
- Usar imagens de disco virtuais descartáveis nos testes de armazenamento.
- Não executar comandos de gravação de imagem em dispositivos físicos sem identificar o destino e obter aprovação explícita.
- Não considerar uma funcionalidade concluída sem evidência de teste.
