# Plano de testes do SimpleOS

**Princípio:** não declarar um teste aprovado sem executar o procedimento e registrar a evidência.

## 1. Categorias de teste

- **Build:** compilação, linkedição e geração da imagem.
- **Unitário:** funções testáveis fora do kernel, quando a arquitetura permitir.
- **Integração:** comunicação entre shell, sistema de arquivos e drivers.
- **Boot/QEMU:** inicialização e comportamento em máquina virtual.
- **Persistência:** recuperação de dados após reinicialização.
- **Hardware:** testes físicos controlados, somente depois de validação virtual.

## 2. Evidências

Para cada execução relevante, registrar:
- Data.
- Commit ou identificador da versão testada.
- Sistema hospedeiro e versões das ferramentas.
- Comando exato.
- Resultado esperado.
- Resultado observado.
- Log ou arquivo de evidência.
- Estado: aprovado, falhou, bloqueado ou não executado.

## 3. Matriz por fase

| Fase | Teste | Resultado esperado | Estado inicial |
|---|---|---|---|
| 0 | Verificação das ferramentas | Versões e dependências registradas | Aprovado |
| 0 | Build em clone limpo | Reproduzível conforme README | Aprovado no commit de código `89a60b5` |
| 1 | Boot pelo Limine no QEMU | Kernel mostra mensagem inicial | Não executado |
| 1 | Caminho de kernel incorreto | Erro identificável; não declarar sucesso | Não executado |
| 2 | Registro do mapa de memória | Informações válidas, sem acesso indevido | Não executado |
| 2 | Falha controlada | Diagnóstico identificável | Não executado |
| 3 | Texto e quebra de linha | Saída legível | Não executado |
| 3 | Limites do framebuffer | Nenhuma escrita fora dos limites | Não executado |
| 4 | Entrada e Enter | Linha recebida corretamente | Não executado |
| 4 | Backspace e buffer cheio | Limites respeitados | Não executado |
| 5 | Comando válido | Comportamento esperado | Não executado |
| 5 | Comando inválido | Mensagem de erro, sem falha do kernel | Não executado |
| 6 | CRUD de arquivos | Operações consistentes | Não executado |
| 6 | Caminho inválido | Erro controlado | Não executado |
| 6 | Diretório raiz | Não pode ser removido indevidamente | Não executado |
| 7 | Gravar e reiniciar | Dados persistem no disco virtual | Não executado |
| 7 | Erro de I/O | Erro reportado e estado tratado | Não executado |
| 8 | Boot da imagem | Limine e kernel iniciam no alvo testado | Não executado |
| 9 | Dispositivo USB suportado | Funciona conforme escopo documentado | Não executado |
| 10 | Regressão completa | Testes aplicáveis passam | Não executado |

### 3.1 Resultados da Fase 0 — 20/10/2026

Ambiente: Ubuntu 22.04.5 LTS, x86-64, GCC 11.4.0, binutils 2.38,
GNU Make 4.3, Git 2.34.1, QEMU 6.2.0, GDB 12.1, OVMF 2022.02,
XORRISO 1.5.4-2.

| ID | Teste | Comando | Esperado | Observado | Estado | Evidência |
|---|---|---|---|---|---|---|
| T0.1 | Baseline dos documentos | `sha256sum ... > baseline.sha256` | Hashes originais registrados | Arquivo criado antes das alterações | Aprovado | `docs/evidence/phase-0/baseline.sha256` |
| T0.2 | Verificação principal | `make check-env` | Exit 0; versões registradas | Exit 0; todas as ferramentas obrigatórias presentes | Aprovado | `test-after-xorriso.log` |
| T0.3 | Limine fixado | `make limine` | SHA-256 confere e utilitário compila | Hash conferiu; `limine` compilado | Aprovado | `limine.log` |
| T0.4 | Versão do Limine | `limine version` | `Limine 12.9.4` | `Limine 12.9.4` | Aprovado | `limine-version.log` |
| T0.5 | Header do protocolo | `sha256sum limine.h` | Hash `0aadf...` | Hash confere | Aprovado | `verification.log` |
| T0.6 | Smoke freestanding | `make smoke` | ELF64 x86-64, sem símbolos indefinidos | Confirmado | Aprovado | `smoke.log` |
| T0.7 | Limpeza segura | `make clean` | Docs preservados; smoke removido | Confirmado | Aprovado | `clean.log`, `verification.log` |
| T0.8 | Alvos da Fase 1 | `make kernel`, `make iso`, `make run`, `make run-uefi`, `make debug` (cada um separadamente) | Falha clara, sem implementação | Exit 2 com mensagem | Aprovado | `phase1-targets.log` |
| T0.9 | Ferramentas de imagem | `make check-image-tools` | Todas presentes | `Resultado: OK — requisitos verificados.` | Aprovado | `check-image-tools-after-xorriso.log` |
| T0.10 | Clone limpo | `git clone` + `make test`, `make check-image-tools`, `make limine`, `limine version` | Mesmo resultado | Commit de código `89a60b5`; todos os alvos passaram; `Limine 12.9.4` | Aprovado | `clean-clone-phase0.log` |
| T0.11 | Boot do Limine no QEMU | ISO + QEMU | Menu/boot do Limine | Não executado: Fase 1 não iniciada; nenhuma ISO gerada | Não executado | — |
| T0.12 | Inicialização do QEMU sem mídia | `timeout 8s qemu-system-x86_64 ...` | Processo inicia e é encerrado | Exit 124 por timeout; não valida boot | Informativo | `qemu-bios-smoke.log` |
| T0.13 | Instalação do XORRISO | `command -v xorriso`, `xorriso --version`, `dpkg-query` | Ferramenta e dependências instaladas | `xorriso 1.5.4-2`; dependências presentes | Aprovado | `xorriso-installed.log` |

**Conclusão:** a Fase 0 está concluída no commit de código `89a60b5`. O smoke test valida
compilação freestanding, mas não valida linkedição, linker script, geração de
ISO ou boot; esses itens pertencem à Fase 1.

## 4. Testes de parser e sistema de arquivos

Sempre que possível, mantenha parser e operações do sistema de arquivos suficientemente isolados para testar com um executável hospedeiro ou harness próprio. Se isso exigir uma abstração extra, justifique-a; não crie uma arquitetura de testes excessivamente complexa antes de precisar dela.

Casos mínimos:
- Entrada vazia.
- Espaços extras.
- Quantidade excessiva de argumentos.
- Linha no limite e acima do limite.
- Arquivo ou diretório inexistente.
- Nome duplicado.
- Caminho absoluto e relativo.
- Tentativa de remover a raiz.
- Tentativa de remover diretório não vazio.
- Capacidade máxima de arquivos ou dados.

## 5. Testes de persistência

Usar uma imagem de disco virtual descartável. Testar:
1. Inicializar com disco vazio ou formatado conforme o escopo escolhido.
2. Criar um arquivo e gravar conteúdo conhecido.
3. Encerrar e reiniciar o SimpleOS.
4. Reabrir o arquivo e comparar o conteúdo.
5. Registrar o log e o resultado.

Nunca usar o disco interno do computador como alvo inicial de testes.

## 6. Relatório de teste

```text
Teste:
Commit:
Ambiente:
Comando:
Esperado:
Observado:
Estado: Aprovado / Falhou / Bloqueado / Não executado
Evidência:
Observações:
```

## 7. Critério geral

Uma compilação bem-sucedida não prova que o kernel funciona em execução. Um boot bem-sucedido no QEMU não prova que funciona em hardware físico. Relate separadamente essas evidências.
