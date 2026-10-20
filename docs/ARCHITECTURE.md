# Arquitetura do SimpleOS

**Estado:** proposta inicial; decisões ainda precisam ser validadas por protótipo.

## 1. Objetivo arquitetural

Manter o kernel pequeno e dividido em componentes com responsabilidades claras. A arquitetura deve evoluir conforme testes e limitações reais forem conhecidos, evitando abstrações prematuras.

## 2. Fluxo de inicialização

```text
Firmware UEFI
    |
    v
Limine
    |
    v
Ponto de entrada do kernel
    |
    v
Inicialização mínima
    ├── validar informações recebidas do boot
    ├── configurar diagnóstico
    ├── inicializar subsistemas necessários
    └── iniciar terminal/shell quando disponíveis
```

O firmware inicia o bootloader; o Limine lê sua configuração e carrega o kernel compatível com o protocolo selecionado. O firmware não interpreta diretamente o arquivo `limine.conf`.

## 3. Componentes propostos

### Boot e inicialização
Responsável pelo ponto de entrada, requisições do protocolo Limine e passagem segura para a inicialização do kernel.

### Diagnóstico
Oferece logs simples, inicialmente por saída serial no QEMU, além de um caminho de falha fatal.

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

### 4.1 Fluxo de build da Fase 0

A Fase 0 prepara o caminho de build, mas não implementa o kernel:

```text
fontes C freestanding (smoke test)
        |
        v
objeto ELF64 x86-64
        |
        v
(inspeção com file/readelf/nm)

Limine 12.9.4 fixado
        |
        v
build/limine-binary/ (utilitário + arquivos de boot)
```

O fluxo completo da Fase 1 será:

```text
src/ + linker script
        |
        v
build/kernel.elf
        |
        v
build/iso_root/ + Limine
        |
        v
build/simpleos.iso (BIOS + UEFI)
        |
        v
QEMU
```

Decisões já fixadas para a Fase 0:

- GCC 11.4.0 nativo, alvo `x86_64-linux-gnu`, modo freestanding.
- Limine 12.9.4, base revision 6, binário verificado por SHA-256.
- Header do protocolo no commit `3a0526b700e356f0eac1b71a77697b3fd1c707a3`.
- QEMU 6.2.0 com `q35`, SeaBIOS e OVMF.
- ISO híbrida BIOS/UEFI como estratégia proposta; XORRISO ainda ausente.

O kernel será carregado nos 2 GiB superiores, em `0xffffffff80000000`, com
`-mcmodel=kernel` e linker script próprio. A linkagem e o ponto de entrada
serão definidos e testados somente na Fase 1.

## 5. Restrições

- Kernel x86-64 e ambiente freestanding.
- Não depender de serviços do sistema hospedeiro.
- Não assumir que APIs POSIX estão disponíveis.
- Não assumir que suporte a boot por USB fornece suporte a armazenamento USB dentro do sistema operacional.
- Não assumir que um driver testado no QEMU funciona em todo hardware físico.

## 6. Decisões em aberto

Registrar decisões aprovadas em `DECISIONS.md`, incluindo:
- Versão e protocolo do Limine. — resolvido na Fase 0: 12.9.4, base revision 6.
- Toolchain e formato do kernel. — resolvido na Fase 0: GCC freestanding, ELF64.
- Configuração do linker. — pendente para a Fase 1.
- Método de saída de diagnóstico. — pendente para a Fase 2.
- Backend inicial do terminal. — pendente para a Fase 3.
- Entrada de teclado inicial. — pendente para a Fase 4.
- Modelo de memória. — pendente para a Fase 2.
- Sistema de arquivos persistente e escopo suportado. — pendente para a Fase 7.
- Dispositivos virtuais usados no QEMU. — QEMU `q35` definido; dispositivos de armazenamento pendentes.

## 7. Atualização deste documento

Atualize o documento quando uma interface ou decisão arquitetural mudar. Explique o motivo, os impactos e os testes que sustentam a mudança.
