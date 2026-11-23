# Requisitos da Unidade II

Fonte: enunciado da Unidade II (`PetAmigo.pdf`, páginas 3 e 4, recebido em 19/11/2026). As páginas 1 e 2 do mesmo PDF são o briefing original do projeto; os itens dele que afetam as specs estão no fim deste arquivo.

**A Unidade II prevalece** sobre `docs/requisitos.md` e sobre as decisões anteriores das specs sempre que houver conflito. Cada exigência tem um código `U2-xx`, que os pacotes e o plano citam.

## Exigências

| Código | Exigência (resumo fiel do enunciado) | Onde está especificado | Pacote |
|---|---|---|---|
| U2-01 | Calorias pela fórmula **RER (NRC) × fator de atividade** (ex.: 1,6 castrados, 2,0 ativos, 3,0 filhotes). Não pode ser fixo nem simplificado | `comum/modelos-matematicos.md` → M1 | P1 (domínio), P2 (uso no diário) |
| U2-02 | **Gráfico interativo**: arrastar o dedo na linha do tempo e ver o peso exato do dia; mostrar a linha do **peso ideal** calculado | M6; `pacote-4` | P4 |
| U2-03 | **Curva ideal futura de 90 dias** (perda ou ganho até o peso ideal) | M3 | P4 |
| U2-04 | **Projeção adaptativa de 90 dias** com histórico de alimentação, atividade e pesagens, comparada com a curva ideal | M4 | P4 |
| U2-05 | **Recalcular** a curva sempre que houver refeição registrada, peso alterado ou atividade registrada; atualização **em tempo real** com Riverpod | M9; `arquitetura.md` | P4 (com P2, P3) |
| U2-06 | Editar o **peso inicial** e **refeições passadas**, com gráfico e calorias recalculados na hora | `pacote-1`, `pacote-2`, M9 | P1, P2 |
| U2-07 | Tratar exceções matemáticas (divisão por zero, dados ausentes); sem pesagens, o gráfico mostra um **estado vazio amigável** | M10 | P4 |
| U2-08 | **Data prevista** para atingir o peso ideal, com base no histórico real de alimentação e atividades | M5 | P4 |
| U2-09 | **Notificações locais** nos horários definidos pelo tutor (ex.: 08:00, 14:00, 20:00), **mesmo com o app fechado pelo sistema** | `pacote-3` → Lembretes | P3 |
| U2-10 | **Vários pets** por tutor, cada um com histórico, metas, gráfico e notificações próprios | `dados-e-sync.md`; `pacote-1` → Seus pets | P1 (+ todos filtram pelo pet atual) |
| U2-11 | **Sugestões**: reduzir petiscos, aumentar exercícios, mudar objetivo nutricional | M8 | P2 (petiscos), P3 (exercícios), P4 (objetivo) |
| U2-12 | Exibir **peso atual, peso ideal, percentual de evolução e aderência ao plano alimentar** | M2, M7; `pacote-4` → Indicadores | P4 (P2 calcula a aderência) |
| U2-13 | **Riverpod ou Bloc** | Riverpod (`arquitetura.md`) | todos |
| U2-14 | **Clean Architecture** | `arquitetura.md` → Clean Architecture | todos (P1 monta o esqueleto) |
| U2-15 | **Offline-first** | Já era a base das specs | todos |
| U2-16 | **Sincronização em lote via Wi-Fi** | `dados-e-sync.md` → Envio em lote | P5 |
| U2-17 | **5 testes automatizados** (no mínimo) | Os 5 obrigatórios estão em `plano-de-execucao.md` → Os 5 testes automatizados oficiais; cada pacote tem vários outros | todos |
| U2-18 | **Exportação em PDF** para consulta veterinária | `pacote-3` → Resumo em PDF | P3 |

## Itens do briefing original que mudam as specs

| Código | Briefing (`PetAmigo.pdf`, pág. 2) | Efeito nas specs |
|---|---|---|
| B-a | "Celebrar pequenas vitórias (ex.: 'Seu cão perdeu 100g!')" | R08 passa a **celebrar a aproximação do peso ideal** (M8). Sem peso ideal, ou indo na direção contrária, não há celebração nem culpa |
| B-b | "Abrir > Tocar em 'Registrar refeição' > Selecionar quantidade" | No atalho (tela 06), a **Porção vira escolha** (habitual, metade, uma e meia, outra quantidade), com a habitual pré-selecionada. Continua em 2 toques |
| B-c | "Calculadora de calorias diárias (baseada em peso, **idade** e nível de atividade)" | A idade passa a ser guardada em **meses**, para identificar filhotes (fator 3,0) |

## Conflitos com o que estava decidido e como ficaram

| Antes (requisitos do grupo / specs) | Agora (Unidade II) |
|---|---|
| RF03/RNF11: cálculo NRC bloqueado ("Referência indisponível") | **Cálculo ativo** (RER × fator). A tela 18 passa a explicar o cálculo e a fonte, com o aviso "não substitui o veterinário" |
| RF04: conversão para gramas indisponível | **Ativa**: meta em kcal ÷ densidade do rótulo × 100 |
| R02: "Comparação com meta indisponível" | O Diário compara o total com a meta (`120 de 397 kcal`) |
| RF12: atividade não entra em cálculo de calorias | A atividade **entra na projeção de peso** (M4). A **meta diária não muda** com a atividade, para não "liberar" petisco por causa do passeio |
| Escopo de **um único pet** | **Vários pets**. Continuam as 4 abas; o pet atual é escolhido no Início |
| RF13: resumo em texto | **PDF** (o texto vira o conteúdo do PDF) |
| P-04: peso inicial somente leitura na edição | **Editável**; alterar recalcula gráfico, evolução e projeção |
| RF19/R08: não comemorar variação de peso | Comemora a **aproximação do peso ideal** (B-a). Continua proibido culpar ou comemorar sem peso ideal definido |
| B-01: método NRC bloqueado | Resolvido pelo enunciado. Os valores que o enunciado não define estão em `pendencias.md` (P-17 a P-22) para confirmar com o professor |

## O que continua valendo

Offline-first, sincronização só no Wi-Fi, cópia remota opcional, as 4 abas, o design system, o tom acolhedor, a privacidade e a exclusão integral.
