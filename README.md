# SimpleOS

Sistema operacional educacional x86-64, desenvolvido majoritariamente em C, com inicialização pelo Limine e testes iniciais no QEMU.

> **Estado atual:** Fase 0 concluída em 20/10/2026. A estrutura de build, a verificação de ambiente, a pinagem do Limine e as ferramentas de imagem estão preparadas. A Fase 1 ainda não foi iniciada; o kernel não foi implementado e nenhum boot de kernel foi validado.

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
Firmware UEFI
    |
    v
Limine
    |
    v
Kernel SimpleOS
    ├── Inicialização e diagnóstico
    ├── Gerenciamento de memória
    ├── Terminal e entrada
    ├── Shell e parser
    ├── Sistema de arquivos
    └── Driver de armazenamento
```

A arquitetura é uma proposta inicial e deve ser atualizada quando decisões técnicas forem validadas.

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

## Compilar e executar

**Fase 0:** os comandos abaixo funcionam para verificar o ambiente, baixar o
Limine e compilar o smoke test. Eles não criam kernel nem imagem inicializável.

```sh
make                  # verifica o ambiente e compila o smoke test
make test             # equivalente a check-env + smoke
make check-env        # verifica ferramentas e versões
make limine           # baixa, verifica e compila o Limine fixado
make smoke            # compila o objeto freestanding de teste
make check-image-tools # verifica XORRISO e ferramentas de imagem
make clean            # remove artefatos gerados conhecidos
```

Os alvos `kernel`, `iso`, `run`, `run-uefi` e `debug` pertencem à Fase 1 e
ainda não estão implementados. Eles falham com uma mensagem explícita.

Consulte `docs/BUILD.md` para detalhes, limitações e o fluxo previsto da
Fase 1. As evidências da Fase 0 estão em `docs/evidence/phase-0/`.

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
- `CHANGELOG.md`: histórico de mudanças.

## Licença

O SimpleOS é distribuído sob a licença MIT. Consulte [`LICENSE`](LICENSE).
Os avisos de terceiros estão em `docs/THIRD_PARTY.md`.

## Regras de segurança

- Validar o boot no QEMU antes de testar em hardware.
- Usar imagens de disco virtuais descartáveis nos testes de armazenamento.
- Não executar comandos de gravação de imagem em dispositivos físicos sem identificar o destino e obter aprovação explícita.
- Não considerar uma funcionalidade concluída sem evidência de teste.
