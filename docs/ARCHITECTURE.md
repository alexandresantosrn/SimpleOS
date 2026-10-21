# Arquitetura do SimpleOS

**Estado:** Fase 1 validada em 21/10/2026 para boot mínimo, diagnóstico serial e ISO híbrida. Componentes de memória, terminal, entrada, shell e armazenamento continuam pendentes.

## 1. Objetivo arquitetural

Manter o kernel pequeno e dividido em componentes com responsabilidades claras. A arquitetura deve evoluir conforme testes e limitações reais forem conhecidos, evitando abstrações prematuras.

## 2. Fluxo de inicialização

```text
Firmware BIOS/UEFI
    |
    v
Limine 12.9.4
    |
    v
Ponto de entrada do kernel (kernel_main)
    |
    v
Inicialização mínima da Fase 1
    ├── validar base revision do protocolo
    ├── configurar serial COM1
    ├── emitir diagnóstico de boot
    └── parar o processador
```

O firmware inicia o bootloader; o Limine lê sua configuração e carrega o kernel compatível com o protocolo selecionado. O firmware não interpreta diretamente o arquivo `limine.conf`.

## 3. Componentes

### Boot e inicialização
Responsável pelo ponto de entrada, requisições do protocolo Limine e passagem segura para a inicialização do kernel.

### Diagnóstico
Na Fase 1, fornece saída serial mínima em COM1 para comprovar o boot. Logs
estruturados, níveis de severidade e caminho de falha fatal pertencem à Fase 2.
O terminal por framebuffer pertence à Fase 3.

### Memória
Interpreta o mapa de memória recebido no boot e fornece as primitivas de alocação que forem necessárias. A interface e o algoritmo ainda serão decididos.

### Terminal
Exibe texto, mantém posição do cursor e trata limites da tela. O backend de saída será validado no QEMU.

### Entrada/teclado
Converte eventos ou códigos de tecla em caracteres e teclas especiais. O método inicial será definido com base no ambiente de teste.

### Shell
Recebe linhas, faz parsing e encaminha comandos. Não deve conter diretamente a implementação do sistema de arquivos.

### Sistema de arquivos
Define operações sobre caminhos, arquivos e diretórios. A primeira implementação será em memória.

### Armazenamento
Abstrai leitura e escrita em blocos. Deve ser separada da lógica de arquivos para permitir começar com dispositivo virtual e, posteriormente, investigar hardware físico.

## 4. Fluxo de dependências pretendido

```text
Shell
  ├── Terminal/entrada
  └── Interface do sistema de arquivos
            |
            +-- Implementação em memória (inicial)
            |
            +-- Implementação persistente (futura)
                         |
                         v
                 Interface de bloco
                         |
                         v
                Driver de dispositivo
```

### 4.1 Fluxo de build atual

```text
src/main.c + src/serial.c + src/linker.ld
        |
        v
build/kernel.elf (ELF64 ET_EXEC não-PIE)
        |
        v
build/iso_root/ + Limine 12.9.4
        |
        v
build/simpleos.iso (BIOS + UEFI)
        |
        v
QEMU BIOS / QEMU UEFI
```

O kernel é validado com `file`, `readelf` e `nm`. A ISO é validada pela lista
de arquivos e pelo boot nos dois firmwares.

Decisões fixadas para as Fases 0 e 1:

- GCC 11.4.0 nativo, alvo `x86_64-linux-gnu`, modo freestanding.
- Limine 12.9.4, base revision 6, binário verificado por SHA-256.
- Header do protocolo no commit `3a0526b700e356f0eac1b71a77697b3fd1c707a3`.
- QEMU 6.2.0 com `q35`, SeaBIOS e OVMF.
- ISO híbrida BIOS/UEFI com XORRISO 1.5.4-2 e `limine bios-install`.
- Kernel ELF64 `ET_EXEC` não-PIE em `0xffffffff80000000`, com
  `-mcmodel=kernel`, linker script próprio e entrada `kernel_main`.
- Requisições Limine em `.limine_requests`, entre marcadores, em segmento
  gravável: base revision 6, bootloader info e firmware type.
- Paginação inicial de quatro níveis configurada no `limine.conf`.
- Diagnóstico mínimo pela serial COM1; sem framebuffer na Fase 1.
- Parada do kernel com `cli; hlt` após a mensagem de sucesso.

## 5. Restrições

- Kernel x86-64 e ambiente freestanding.
- Não depender de serviços do sistema hospedeiro.
- Não assumir que APIs POSIX estão disponíveis.
- Não assumir que suporte a boot por USB fornece suporte a armazenamento USB dentro do sistema operacional.
- Não assumir que um driver testado no QEMU funciona em todo hardware físico.

## 6. Decisões e pendências

Registrar decisões aprovadas em `DECISIONS.md`, incluindo:
- Versão e protocolo do Limine. — resolvido: 12.9.4, base revision 6.
- Toolchain e formato do kernel. — resolvido: GCC freestanding, ELF64 `ET_EXEC`.
- Configuração do linker. — resolvido na Fase 1: ADR-0013.
- Método de saída de diagnóstico. — resolvido na Fase 1: serial COM1 mínima
  (ADR-0014); framebuffer e logs estruturados permanecem para a Fase 2/3.
- Paginação inicial. — resolvido na Fase 1: quatro níveis (ADR-0015).
- Backend inicial do terminal. — pendente para a Fase 3.
- Entrada de teclado inicial. — pendente para a Fase 4.
- Modelo de memória. — pendente para a Fase 2.
- Sistema de arquivos persistente e escopo suportado. — pendente para a Fase 7.
- Dispositivos virtuais usados no QEMU. — QEMU `q35` definido; dispositivos de armazenamento pendentes.

## 7. Atualização deste documento

Atualize o documento quando uma interface ou decisão arquitetural mudar. Explique o motivo, os impactos e os testes que sustentam a mudança.
