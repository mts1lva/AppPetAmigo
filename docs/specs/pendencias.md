# Pendências e decisões

Pontos que o protótipo e os requisitos não definiam, ou definiam de forma contraditória. **Todos foram decididos em 19/11/2026** e as specs já refletem as decisões. Se o grupo quiser mudar alguma, atualize esta tabela e os arquivos indicados.

## Decisões tomadas

| ID | Questão | Decisão | Motivo | Onde está aplicado |
|---|---|---|---|---|
| P-01 | "Bom dia, Marina" sem campo para o nome do tutor | **Só a saudação** ("Bom dia"), sem nome | Minimização de dados (RNF04): nenhuma função depende do nome do tutor | R11; P1 (tela 01) |
| P-02 | "Gata" e "castrada" sem campo de sexo | **Campo Sexo (Macho/Fêmea)** no cadastro do pet | Mantém o texto do Início igual ao protótipo; é dado do pet, não do tutor | R05, R11; `pets.sexo`; P1 (tela 05) |
| P-03 | Escala do ECC | **1 a 9 (WSAVA)**, exibida como "5 de 9"; o app não interpreta o valor | É a escala citada em `pesquisa.md`; interpretar seria diagnóstico (RF10) | R05; `referencias.ecc`; P4 (tela 12) |
| P-04 | "Peso inicial" na edição do pet | **Revista pela Unidade II (U2-06):** no cadastro, cria a primeira pesagem; na edição, continua "Peso inicial" e é **editável** (no 05 e na Evolução), recalculando tudo na hora | O enunciado exige editar o peso inicial | P1 (tela 05), P4 (tela 11) |
| P-05 | Diário 02 e "Diário atualizado" 21 com layouts diferentes | **Um só Diário (02)**. Depois de salvar pelo atalho, só o título muda para "Diário atualizado" | Mesma tela com cards de nomes diferentes confunde quem usa e duplica código | P2; `navegacao.md` |
| P-06 | "Cancelar" verde na tela 23 | **"Cancelar" secundário**; "Confirmar exclusão" continua primário | Consistência com todos os outros botões de cancelar ou voltar | `design-system.md`; P2 (tela 23) |
| P-07 | Tela 21 sem aba ativa | Aba **Diário ativa** | Erro do protótipo | P2 |
| P-08 | Só o registro mais recente acessível em atividades, pesagens e dia sem refeição | Cards novos **"Anteriores"** (P3) e **"Pesagens anteriores"** (P4) com `PaHistorico`; "Adicionar refeição" no card vazio (P2) | O CRUD dos requisitos exige consultar e editar registros antigos | P2, P3, P4 |
| P-09 | Desativar a cópia remota | **Confirmação** avisando que a cópia enviada continua guardada; para apagar, usa-se a exclusão integral | Desativar é reversível (RF16); apagar dados remotos é ação separada e explícita (RF17) | P5 (tela 15) |
| P-10 | Limites técnicos ausentes nos requisitos | Peso ≤ 150 kg; idade ≤ 30; duração ≤ 600 min; sem datas futuras; variação suspeita ≥ ×1,5 ou ≤ ×0,67 | Pegam erro de digitação. **Não são critérios clínicos** | R05, R06 |
| P-11 | `PaMensagem` "falha" igual às outras | **Igual**, como no protótipo; o texto diz o estado | Fidelidade; RNF02 já é atendido pelo texto | `design-system.md` |
| P-12 | Peso das fontes de título e seção | **700**. Tamanhos confirmados no PDF; o peso foi conferido visualmente | O PDF não traz o nome do peso; confirmar no Figma se houver acesso | `design-system.md` |
| P-13 | Opções de "Origem" (12) e "Atividade" (05) | Origem: Veterinário / consulta, Outro profissional, Tutor. Atividade: Baixa, Moderada, Alta | Cobrem os casos do protótipo; revisar quando houver método NRC | P1, P4 |
| P-14 | Pet sem foto | Círculo `suave` com a inicial do nome | Mantém o cabeçalho equilibrado sem imagem genérica | R11; P1 |
| P-15 | Foto na exportação de dados | **Não vai** no JSON | Reduz tamanho e exposição (RNF04) | R13; P3 |
| P-16 | Ações que faltam no protótipo da cópia remota | Botões "Ver situação da cópia" (15) e "Tentar agora" (16) | Sem eles, a tela 16 fica inacessível depois de ativar, e não há como repetir após uma falha | P5 |

## Parâmetros da Unidade II que o enunciado não define (confirmar com o professor)

O enunciado exige os modelos, mas não dá todos os números. Abaixo, os valores adotados, cada um numa constante de `domain/parametros.dart` para mudar num lugar só. **Levar esta tabela ao professor** antes da etapa 2 do `plano-de-execucao.md`.

| ID | Parâmetro | Valor adotado | Por que / risco |
|---|---|---|---|
| P-17 | Fator de atividade para (a) adulto **não castrado** com atividade baixa ou moderada e (b) **gatos** | (a) **1,8**; (b) os **mesmos** fatores do enunciado | (a) O enunciado só cita castrados (1,6), ativos (2,0) e filhotes (3,0). (b) Na literatura, gatos castrados costumam ter fator menor (cerca de 1,2): com 1,6, a meta da Luna (397 kcal) pode ficar alta. Perguntar se o professor quer fatores próprios para gatos |
| P-18 | Peso ideal estimado pelo ECC | Cerca de **10% por ponto** fora de 4–5 (escala de 9) | Regra prática associada à escala WSAVA; vale só quando não há objetivo informado pelo veterinário |
| P-19 | Ritmo da curva ideal | **1% do peso por semana** (perda ou ganho) | Dentro das faixas da diretriz AAHA 2021 citada em `pesquisa.md`; conferir o valor exato na diretriz |
| P-20 | Energia por kg de peso e base da meta | **7.700 kcal/kg**; meta = RER do **peso atual** × fator | 7.700 é um valor usual em modelos de balanço energético. Alternativa comum para perda de peso: RER do **peso ideal**. Perguntar qual o professor prefere |
| P-21 | Gasto de atividade e metas de exercício | MET passeio **3,0**, brincadeira **4,0**; meta de exercício (S2) **30 min/dia (cão)** e **15 min/dia (gato)** | Valores didáticos para a atividade entrar na projeção; não há fonte específica no repositório |
| P-22 | Parâmetros da projeção adaptativa | Janelas de **30 dias** (pesagens) e **14 dias** (alimentação e atividade); peso da tendência observada `w = n ÷ 4`; limite de **2% do peso por semana** | Escolhas de modelagem para a projeção reagir aos dados sem oscilar; todas testadas no T4 |

### Diferenças visuais esperadas em relação aos PNGs

Por causa dessas decisões e da Unidade II, os golden tests **devem** divergir do protótipo nestes pontos, e só neles:
- 01, 05 e telas com o Início ao fundo: título sem "Marina".
- 01: card "Referência alimentar" com a meta; cards novos **Sugestões** e **Lembretes**; dica "Trocar de pet" com 2 ou mais pets.
- 02: resumo do dia comparado com a meta.
- 04: gráfico interativo de 180 de altura com três séries e legenda; card novo **Indicadores**.
- 05: campos Sexo e Idade (anos + meses) e botão "Excluir este pet".
- 06: Porção como escolha e linha da meta.
- 10, 18 e 26: textos atualizados pela Unidade II.
- 21: não existe como layout próprio.
- 23: "Cancelar" em branco com borda.
- 03 e 04: cards "Anteriores"/"Pesagens anteriores" quando houver registros antigos.
- 15/16: botões novos da P-16.
- Diálogos novos sem PNG: N1 Seus pets, N2 Lembretes, N3 Pesagem salva.

## Bloqueios externos (não dependem só do grupo)

| ID | Item | Situação |
|---|---|---|
| B-01 | Método NRC (RF03, RF04, RNF11) | **Resolvido pela Unidade II**: RER × fator (M1). Os valores que faltam estão em P-17 a P-22, para confirmar com o professor |
| B-02 | Revisão das dicas (RF18) | Conteúdo "em revisão" até avaliação profissional |
| B-03 | Base legal, política de retenção e expiração de backups (RNF05) | Antes de usar a cópia remota com dados reais. Não ativar backup agendado nem PITR no Firestore até lá |
| B-04 | Validação profissional de P-03, P-10 e P-17 a P-22 | Recomendável antes de uso real; não bloqueia o desenvolvimento. Todo número calculado aparece com o aviso "Estimativa educativa. Não substitui a avaliação do veterinário." |

## Itens que só existem no protótipo (não implementar)

| No protótipo | No app |
|---|---|
| Tela 24 "Recurso do aparelho" | Seletor nativo de foto (P1) e de compartilhamento (P3) |
| Botão "Conferir erro de densidade" (09) | A tela 22 aparece ao salvar com densidade ≤ 0 |
| Botão "Conferir variação" (11) | A tela 25 aparece ao salvar com variação suspeita |
| "Corrigir valor demonstrativo" (22) | "Corrigir valor" |
| "Concluir simulação" (24) | — |
| "Autenticação simulada." (15) | Removido |
| "Valor fora do esperado no exemplo." (25) | "Valor fora do esperado." |
| "Energia do rótulo demonstrativo" (06) | "Energia do rótulo" |
| "Senha • informada no aparelho" (15) | Campo de senha real, oculto |
| Três `PaMensagem` juntas (16) | Uma, com o estado atual |
| Layout próprio da tela 21 | Diário único (P-05) |
| Dados de Luna, Marina e `tutor@exemplo.invalid` | Só em testes e goldens, nunca no build de release |

## Rastreabilidade

| Requisito | Pacote | | Requisito | Pacote |
|---|---|---|---|---|
| RF01, RF02 | P1 | | RNF01 | P2 |
| RF03 | P1 (indisponível) | | RNF02, RNF03 | P1 + todos |
| RF04–RF08 | P2 | | RNF04, RNF05 | P5 |
| RF09–RF11 | P4 | | RNF06 | P2, P4 |
| RF12 | P3 | | RNF07 | P1 |
| RF13 | P3 | | RNF08 | todos (transações) |
| RF14 | todos | | RNF09 | P5 |
| RF15–RF17 | P5 | | RNF10 | P1 (navegação) |
| RF18 | P3 | | RNF11 | P1, P4 |
| RF19, RF20 | P2, P4 | | RNF12 | P1 |
