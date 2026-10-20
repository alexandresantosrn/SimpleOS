# Instruções para agentes — SimpleOS

## Objetivo do projeto

Desenvolver um sistema operacional educacional x86-64, majoritariamente em C, iniciado pelo Limine e testado primeiro no QEMU. O objetivo funcional é oferecer terminal textual, shell e operações básicas de arquivos e diretórios.

## Fonte da verdade

- `README.md`: estado geral e instruções de uso.
- `docs/ARCHITECTURE.md`: arquitetura atual aprovada.
- `docs/ROADMAP.md`: fase atual e critérios de aceite.
- `docs/TEST_PLAN.md`: testes necessários e evidências.
- `docs/DECISIONS.md`: decisões técnicas aprovadas.
- `docs/DEBUGGING.md`: problemas reproduzidos e diagnósticos confirmados.
- `CHANGELOG.md`: histórico de mudanças reais.

Se os documentos se contradisserem ou estiverem desatualizados, informe a divergência antes de fazer alterações arquiteturais.

## Processo obrigatório

1. Leia os documentos relevantes antes de começar.
2. Confirme a fase atual e a tarefa solicitada.
3. Antes de editar, inspecione o repositório e apresente um plano curto.
4. Liste os arquivos que pretende criar ou alterar.
5. Implemente somente a tarefa aprovada; não antecipe fases futuras.
6. Execute os testes aplicáveis e preserve os logs relevantes.
7. Revise o diff e atualize a documentação.
8. Informe resultados reais, limitações e próximo passo.

Se o usuário solicitar explicitamente que implemente sem pedir aprovação intermediária, ainda assim mantenha o escopo limitado e siga as regras de segurança.

## Regras técnicas

- Trate o kernel como ambiente freestanding: não presuma libc, processos, threads, arquivos POSIX ou serviços do sistema hospedeiro.
- Não invente APIs do Limine, registros de hardware ou comportamentos do QEMU. Consulte a documentação correspondente à versão fixada.
- Evite dependências desnecessárias.
- Defina e valide limites de buffers, nomes, argumentos, endereços e estruturas.
- Trate erros de entrada, limites, falhas de memória e falhas de I/O.
- Separe interfaces de terminal, shell, sistema de arquivos e armazenamento.
- Prefira mudanças pequenas, testáveis e fáceis de revisar.
- Não altere versões de ferramentas ou dependências silenciosamente.

## Segurança e operações destrutivas

- Não execute `sudo`, não altere partições, não formate discos e não grave imagens em dispositivos físicos sem autorização explícita.
- Antes de qualquer comando potencialmente destrutivo, explique o que fará, qual dispositivo ou arquivo será afetado e aguarde autorização.
- Use imagens de disco virtuais descartáveis para testes.
- Não apague arquivos do usuário nem execute limpeza fora dos artefatos gerados conhecidos.
- Não faça commit, push ou publicação sem solicitação ou autorização clara do usuário.

## Testes e afirmações

- Não diga que compilou, executou ou testou algo sem ter executado o comando correspondente.
- Não substitua testes que falharam por testes mais fracos para declarar sucesso.
- Se um teste não puder ser executado, informe o motivo e o que permanece sem validação.
- Build bem-sucedido não prova que o kernel funciona em execução.
- QEMU funcionando não prova compatibilidade com hardware físico.

## Relatório obrigatório ao concluir

- Resumo da implementação.
- Arquivos criados ou alterados.
- Comandos executados e seus resultados.
- Testes aprovados, falhos e não executados.
- Limitações, riscos e decisões pendentes.
- Próxima tarefa recomendada, sem implementá-la automaticamente.
