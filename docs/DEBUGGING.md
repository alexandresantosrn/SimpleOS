# Guia de depuração do SimpleOS

Este arquivo deve registrar problemas reproduzidos e soluções confirmadas. As notas abaixo são procedimentos de diagnóstico, não afirmações de que o ambiente já está configurado.

## 1. O QEMU não inicia a imagem

Verifique:
- Se a imagem foi criada e está no caminho esperado.
- Se o comando de execução corresponde ao formato da imagem.
- Se a configuração do Limine está no local correto.
- Se os caminhos para o kernel correspondem aos arquivos presentes.
- Se o kernel é compatível com o protocolo configurado.
- Se a arquitetura e o modo de firmware selecionados são compatíveis.

Registre o comando exato e a mensagem completa do erro.

## 2. O Limine abre, mas o kernel não inicia

Verifique:
- O caminho configurado para o kernel.
- O formato e a arquitetura do executável.
- O linker script e o ponto de entrada.
- As requisições e estruturas necessárias ao protocolo Limine na versão fixada.
- Se a saída serial está configurada corretamente.

Não altere várias partes ao mesmo tempo. Faça uma hipótese, uma mudança e um teste.

## 3. Tela preta ou ausência de texto

Diferencie:
- Falha antes de entrar no kernel.
- Kernel iniciado, mas sem saída visual.
- Dados de framebuffer ausentes ou inválidos.
- Problema no console serial ou no comando do QEMU.

Se possível, use saída serial para determinar se o kernel iniciou, em vez de depender somente da tela.

## 4. Travamento após uma mensagem

- Identifique a última mensagem registrada.
- Acrescente logs em pontos de inicialização bem definidos.
- Revise ponteiros, limites de buffers, alinhamento e conversões de tipos.
- Use GDB se a configuração de depuração estiver disponível.
- Evite remover validações apenas para fazer o programa avançar.

## 5. Teclado não responde

- Confirme o método de entrada implementado e o dispositivo apresentado pelo QEMU.
- Verifique o mapeamento de teclas e o tratamento de teclas especiais.
- Confirme se o kernel recebe eventos/códigos antes de convertê-los em caracteres.
- Não conclua que um teclado USB físico é suportado porque o teclado emulado funciona.

## 6. Arquivos desaparecem após reiniciar

Se o sistema de arquivos atual é em memória, perder os dados após reinicializar é esperado. Persistência exige gravação em armazenamento e um sistema de arquivos que possa recuperar os dados na inicialização.

## 7. Falhas de compilação

Registre:
- Comando de compilação completo.
- Primeira mensagem de erro relevante e contexto.
- Versões do compilador e linker.
- Arquivo e linha afetados.
- Mudanças recentes no diff.

Corrija a causa inicial antes de tentar resolver erros em cascata.

## 8. Ambiente e problemas conhecidos (Fases 0 e 1)

### 8.1 XORRISO e geração da ISO

O `xorriso 1.5.4-2` foi instalado com autorização em 20/10/2026. O comando
`make check-image-tools` termina com
`Resultado: OK — requisitos verificados.` Na Fase 1, `make iso` gerou
`build/simpleos.iso` e `limine bios-install` concluiu com sucesso. Logs em
`docs/evidence/phase-1/`.

### 8.2 GCC com PIE e `-mcmodel=kernel`

O GCC do Ubuntu é configurado com PIE por padrão. A flag `-mcmodel=kernel`
falha sem `-fno-pie`/`-fno-PIC`; o `Makefile` inclui ambas. A linkagem usa
também `-no-pie` e produziu um `ET_EXEC` válido em `0xffffffff80000000`.

### 8.3 Localização do `readelf`

O `readelf` pode imprimir cabeçalhos traduzidos. O alvo `make smoke` usa
`LC_ALL=C` para que a verificação de `Class`, `Machine` e `Type` seja estável.

### 8.4 Aviso de CPUID do KVM

O QEMU pode emitir avisos como `host doesn't support requested feature:
CPUID.80000001H:ECX.svm`. O aviso, isoladamente, não deve ser tratado como
falha. Em um teste sem mídia, o processo QEMU iniciou e foi encerrado pelo
timeout; isso não valida boot de kernel. Se houver falha, use `-accel tcg` ou
não use `-cpu host`.

### 8.5 Firmware UEFI

O OVMF está disponível em `/usr/share/ovmf/OVMF.fd` e em
`/usr/share/OVMF/OVMF_CODE.fd` com `OVMF_VARS.fd`. Para testes reproduzíveis,
copie `OVMF_VARS.fd` para `build/` antes de usar pflash; não altere o arquivo
do sistema.

### 8.6 Hash do Limine

Se o SHA-256 do tarball não conferir, não extraia nem use o arquivo. Remova o
tarball corrompido de `build/downloads/` e execute `make limine` novamente.
Não substitua o hash por um valor obtido de fonte não confiável.

### 8.7 Requisições Limine fora de `.limine_requests`

**Sintoma:** a primeira linkagem terminou, mas `readelf -S` não mostrava uma
seção `.limine_requests`; as requisições estavam diluídas em `.data`.

**Causa:** o linker script original coletava as seções de entrada dentro de
`.data`, sem criar uma seção de saída com o nome esperado.

**Correção:** criar uma seção de saída `.limine_requests`, com `ALIGN(8)` e
`KEEP`, contendo os marcadores de início/fim e as requisições; ela permanece no
segmento gravável. O início de `.text` também foi afastado dos cabeçalhos ELF
com `SIZEOF_HEADERS`.

**Regressão:** `make kernel` verifica a seção; `objdump -s -j .limine_requests`
e os boots BIOS/UEFI confirmam que o Limine processa as requisições.

### 8.8 `xorriso -find -print` não existe

**Sintoma:** a validação da ISO falhou com
`-find[ix]: unknown option '-print'`.

**Correção:** usar `xorriso -indev <iso> -find / -type f -exec lsdl` e filtrar
a saída. A ISO em si já havia sido gerada e o `bios-install` concluído; o erro
era apenas da verificação.

### 8.9 Saída serial no QEMU

Os testes automatizados usam `-serial file:build/logs/<nome>.log` para não
misturar a serial com a saída do monitor. Os alvos interativos usam
`-serial stdio`. No UEFI, o log pode conter sequências ANSI do OVMF antes das
mensagens do kernel; a busca pelo marcador `SIMPLEOS_PHASE1_OK` continua
válida.

## 9. Registro de incidentes

```text
ID:
Data:
Commit:
Sintoma:
Passos para reproduzir:
Esperado:
Observado:
Logs:
Hipótese:
Experimentos realizados:
Causa confirmada ou ainda desconhecida:
Correção:
Teste de regressão:
```
