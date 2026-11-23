# Pacote 2 — Diário de alimentação

**Responsável:** ______________________

## Objetivo

Entregar a funcionalidade mais importante do app (F03): registrar, consultar, corrigir e excluir refeições e petiscos, cadastrar alimentos e porções reutilizáveis e oferecer o atalho de **dois toques** a partir do Início.

**Requisitos:** RF04, RF05, RF06, RF07, RF08, RF14, RF19 (mensagem pós-registro), RF20, RNF01, RNF06, RNF08 · **Unidade II:** U2-01 (meta no diário e gramas), U2-05/U2-06 (refeições passadas recalculam na hora), U2-11 (S1), U2-12 (aderência), briefing B-b, teste oficial T2.
**Depende de:** P1 (componentes, banco, rotas). **Entrega para:** P1 (`resumoDiaProvider` no card "Hoje"), P4 (`aderenciaProvider`, ingestão diária para a projeção), **todos** (Firebase Emulator Suite e apoio aos testes de integração, P2-2.3).

**Ordem de execução:** **etapa 2** do `plano-de-execucao.md`, depois que o P1 entregar. Nas telas, a ordem importa: **alimento → refeição → petisco → diário → atalho**, porque o atalho precisa de um alimento cadastrado e o diário precisa dos registros para exibir.

## Dados e regras

- Tabelas `alimentos`, `refeicoes` e `extras` (`comum/dados-e-sync.md`) com índice em `dataHora`.
- Regras R01, R02, R05, R08, R09 e R10 (`comum/regras.md`), em `domain/energia.dart` e `domain/resumo_dia.dart`, com testes.
- **Alimento do atalho:** o da refeição mais recente; se não houver refeição, o último alimento cadastrado.
- **Excluir um alimento** marca `arquivado = true`: ele some das escolhas, mas as refeições antigas continuam com os valores copiados (RF04).
- Providers expostos (todos por pet): `resumoDiaProvider(petId, dia)`, `refeicoesDoDiaProvider(petId, dia)`, `extrasDoDiaProvider(petId, dia)`, `aderenciaProvider(petId)` (M7) e a regra S1 (M8). São streams do drift: editar uma refeição de qualquer data recalcula resumo, aderência e a projeção do P4 na hora (U2-05, U2-06).
- Alimentos são **por pet** (cada pet tem a própria ração).

## Telas

### 02 — Diário (`docs/design/telas/02-diario.png`)

Tela principal. Título `Diário`. Subtítulo: data selecionada no formato `30 setembro 2026` (padrão: hoje).

| Card | Conteúdo | Botão |
|---|---|---|
| Data selecionada | `Confira o que foi registrado.` | `secundario` **Selecionar data** → `showDatePicker` (até hoje). Data sem nenhum registro → abre 19 |
| Refeições | Uma `PaHistorico` por refeição, em ordem de horário: `08:00 • Ração habitual • 30 g • 108 kcal`. Vazio: `Nenhuma refeição registrada.` | `secundario` **Editar refeição** → 07 com a refeição mais recente do dia. Vazio: `secundario` **Adicionar refeição** → 07 em branco (P-08) |
| Petiscos e extras | `12:00 • Petisco • 3 g • 12 kcal` (sem quantidade: `12:00 • Petisco • 12 kcal`). Vazio: `Nenhum petisco registrado.` | `secundario` **Editar petisco** → 08 com o extra mais recente. Vazio: sem botão |
| Resumo do dia | R02 com a meta (M1, do P1): `120 de 397 kcal • Petiscos 10% dos registros` / `Faltam 277 kcal para a meta de hoje.` Sem meta: `… / Registre uma pesagem para ver a meta.` Dia vazio: texto de R09 | `secundario` **Adicionar petisco** → 08 em branco |
| Alimentos e porções | `Reutilize os valores da embalagem.` | `secundario` **Gerenciar alimentos** → 09 |

Tocar em qualquer linha `PaHistorico` abre o formulário daquele registro (é assim que se edita um registro que não é o mais recente).

### 21 — Diário atualizado (`21-diario-atualizado.png`)

**Não é um layout separado** (P-05). O app tem um único Diário, o 02. O PNG 21 serve só de referência para duas coisas:
- Quando o tutor chega pelo botão "Consultar diário atualizado" (tela 20), o título vira `Diário atualizado` e volta a ser `Diário` assim que ele sai da aba. Os cards são os mesmos do 02, já com a refeição nova na lista.
- Várias refeições no mesmo card aparecem como linhas `PaHistorico` empilhadas, sem espaço extra entre elas.

O que o PNG 21 mostra e **não** vai para o app: o card "Data selecionada" sumindo, os nomes "Petiscos" e "Total registrado" e o rótulo "Agora" no lugar do horário (a linha mostra o horário real). A aba **Diário fica ativa** (no PNG nenhuma aparece ativa, erro do protótipo, P-07).

### 06 — Registrar refeição (atalho) (`06-registrar-refeicao.png`)

Diálogo aberto pelo Início. Título `Registrar refeição`. Subtítulo `Confira e confirme a porção habitual.`

| Campo | Comportamento |
|---|---|
| Alimento | escolha entre os não arquivados; vem preenchido com o alimento do atalho |
| Porção | **escolha** (briefing B-b, "selecionar quantidade"): `Porção habitual • 30 g / 108 kcal` (pré-selecionada), `Metade • 15 g / 54 kcal`, `Uma e meia • 45 g / 162 kcal`, `Outra quantidade…` (abre o 07 com o campo Quantidade em foco). Sem tocar, vale a habitual, e o fluxo continua em **2 toques** |
| Data e hora | somente leitura: `{data} • agora` |

Texto: `Energia do rótulo: {densidade} kcal/100 g. Esta porção não é uma prescrição.`
Botões: `primario` **Confirmar refeição** (2º toque: grava e abre 20), `primario` **Alterar dados** (→ 07 preenchido com esses valores, ainda sem gravar), `secundario` **Voltar**.

### 07 — Refeição (`07-refeicao.png`)

Título `Refeição`, subtítulo `Adicionar ou corrigir um registro.`
Campos: Alimento (escolha) · Quantidade (número, g) · Energia (somente leitura: `{R01} kcal (rótulo)`, recalcula enquanto digita) · Data · Horário.
Botões: `primario` **Salvar refeição**, `perigo` **Excluir registro** (só ao editar) → 23, `secundario` **Voltar**.
- Ao editar, a energia é recalculada com a densidade **guardada na refeição**. Se o tutor trocar o alimento, a refeição passa a guardar a densidade do alimento novo.

### 08 — Petisco ou extra (`08-petisco-ou-extra.png`)

Título `Petisco ou extra`, subtítulo `Categoria separada das refeições.`
Campos: Descrição (texto, padrão "Petisco") · Quantidade (número, g, **opcional**) · Energia informada (número, kcal, obrigatória) · Data · Horário.
Botões: como no 07 (`Salvar petisco`, `Excluir registro`, `Voltar`).

### 09 — Alimentos e porções (`09-alimentos-e-porcoes.png`)

Título `Alimentos e porções`, subtítulo `Valores do rótulo, sem recomendação automática.`
Campos: Alimento (escolha entre os existentes + "Novo alimento…"; com "Novo", vira campo de texto para o nome) · Densidade (número, `kcal/100 g`) · Porção reutilizável (número, g).
Texto: `Registros antigos preservam alimento, densidade e quantidade usados naquele momento.`
Botões: `primario` **Salvar alimento e porção**, `perigo` **Excluir alimento e porção** → 23 (arquiva), `secundario` **Voltar**.
- O botão "Conferir erro de densidade" do protótipo **não existe no app**: ele só servia para mostrar o estado 22. No app, o 22 aparece quando se tenta salvar com densidade ≤ 0.

### 22 — Confira a densidade (`22-confira-a-densidade.png`)

Título `Confira a densidade`, subtítulo `O valor precisa ser positivo.` Campo Densidade em **estado de erro** com o valor digitado. Texto: `Informe o valor e a unidade da embalagem. Não é possível converter com zero.`
Botões: `primario` **Corrigir valor** (no protótipo, "Corrigir valor demonstrativo"; volta ao 09 com foco na densidade e os outros campos preservados), `secundario` **Voltar**.

### 19 — Consultar outra data (`19-consultar-outra-data.png`)

Título `Consultar outra data`. Subtítulo: a data escolhida (`29 setembro 2026`). Texto de R09.
Botões: `primario` **Retomar registro hoje** (Diário volta para hoje), `secundario` **Voltar** (mantém a data escolhida, com os cards vazios).

### 20 — Refeição salva (`20-refeicao-salva.png`)

Só aparece **depois** da transação concluída. Título `Refeição salva`, subtítulo `Salva neste aparelho.` Texto de R08 com os totais de antes e depois.
Botões: `primario` **Consultar diário atualizado** → aba Diário com o título `Diário atualizado`, `secundario` **Voltar** (fica onde estava).

### 23 — Confirmar exclusão

Componente da base, feito pelo P1 na Fase 0 (`confirmarExclusao()`, ver `pacote-1`). Este pacote só chama a função em "Excluir registro" (07, 08) e em "Excluir alimento e porção" (09).

## Unidade II

### Meta no diário e no atalho (U2-01)

- O Diário usa `metaProvider(petId)` do P1 (M1). Textos em R02.
- Atalho 06: abaixo do texto do rótulo, acrescentar `Meta de hoje: 397 kcal (≈ 110 g)` quando houver meta.

### Aderência ao plano alimentar (U2-12)

- `features/diario/domain/aderencia.dart`: M7 (janela de 14 dias, faixa de ±10% da meta, só dias com registro).
- Exposta por `aderenciaProvider(petId)`. Quem mostra é o card **Indicadores** do P4.

### Sugestão S1 — reduzir petiscos (U2-11)

- `features/diario/domain/sugestao_petiscos.dart`: regra S1 de M8 (≥ 3 dos últimos 7 dias com registro com extras > 10% do total; fonte AAHA/WSAVA em `pesquisa.md`).
- Ação do botão: "Ver diário" → aba Diário.

### Teste oficial T2

`test/diario/aderencia_e_petiscos_test.dart`:
- Aderência: o caso de M7 (totais 380, 400, 120, 228, 410, —, 390 com meta 396,75 → **4 de 6 = 67%**); sem nenhum dia com registro → indisponível (sem divisão por zero); meta indisponível → indisponível.
- S1: 3 dias com extras acima de 10% → sugere; 2 dias → não sugere; dias sem registro não contam.

## Parte Firebase

### Firebase Emulator Suite (P2-2.3), usado por todo o grupo

Este pacote monta o ambiente local de Firebase em que todos testam a sincronização sem tocar no projeto real.
1. `firebase init emulators` com **Auth, Firestore e Storage**. Portas no `firebase.json`; arquivos de regras apontando para os do P5.
2. Scripts `emuladores.sh` e `emuladores.ps1` (`firebase emulators:start --import ./emulador-dados --export-on-exit`). `emulador-dados/` fica no `.gitignore`.
3. `integration_test/apoio_firebase.dart`:
   ```dart
   Future<void> usarEmuladores() async {
     // 10.0.2.2 = máquina host vista pelo emulador Android
     FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
     await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
     await FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9199);
   }
   Future<void> limparEmuladores();          // DELETE nos endpoints REST de limpeza do emulador
   Future<User> criarUsuarioDeTeste(String sufixo);
   ```
4. `integration_test/README.md`: como subir os emuladores e rodar `flutter test integration_test`.
5. Conferir que **nada aponta para o projeto real** quando `usarEmuladores()` é chamado.

### Diário

- `AlimentoMapeador`, `RefeicaoMapeador` e `ExtraMapeador` (`data/sync/mapeadores/`). Datas viram `Timestamp`. Os campos copiados da refeição (`alimentoNome` e `densidadeKcalPor100g`) **vão junto** para o Firestore, senão a restauração perderia o histórico.
- Teste de ida e volta para os três.
- P2-3.2: `integration_test/sync_diario_test.dart` no emulador (P2-2.3, deste pacote). **Ida:** criar, editar e excluir uma refeição e um petisco → motor → ler os documentos com `FirebaseFirestore.instance` e conferir campos (inclusive as cópias `alimentoNome` e `densidadeKcalPor100g`), `versao` e `excluido: true`. **Volta:** gravar uma refeição direto no emulador → pull → conferir que ela aparece no Diário com os totais certos. **Histórico:** arquivar o alimento depois de sincronizar e conferir que o documento da refeição antiga não muda.
- Com a cópia ativa no projeto real, repetir uma vez e tirar print do console.

## Critérios de aceite

- [ ] Com um alimento cadastrado: Início → **Registrar refeição** → **Confirmar refeição** grava em **2 toques** e mostra o 20.
- [ ] 30 g de um alimento com 360 kcal/100 g dá 108 kcal. Petisco de 12 kcal → resumo `120 kcal • Petiscos 10% dos registros`.
- [ ] Editar a quantidade de uma refeição antiga usa a densidade antiga, mesmo depois de mudar a densidade do alimento.
- [ ] Excluir um alimento não altera nenhuma refeição antiga.
- [ ] Densidade 0 ou negativa → 22, sem gravar nada.
- [ ] Data sem registros → 19, e nenhum "0 kcal" aparece.
- [ ] Fechar o app logo depois do 20 e reabrir: a refeição continua lá (RNF08).
- [ ] Modo avião: todo o pacote funciona.
- [ ] RNF06: salvar em até 1 s com 1.000 registros, medido 20 vezes (anotar aparelho e resultados).
- [ ] Golden tests do 02 e do 06 comparados com os PNGs.
- [ ] Com a meta da Luna, o resumo mostra `120 de 397 kcal`; editar a refeição de 3 dias atrás muda o resumo daquele dia, a aderência e a projeção do P4 sem recarregar a tela.
- [ ] No atalho, escolher "Metade" grava 15 g / 54 kcal; não tocar na porção grava a habitual em 2 toques.
- [ ] Cada pet tem os próprios alimentos e refeições.
- [ ] T2 passa.
- [ ] Emuladores sobem com o script; `usarEmuladores()` conecta e nada vai para o projeto real.
- [ ] Pelo menos um colega rodou o próprio teste de integração seguindo só o `integration_test/README.md`.

## Evidências para guardar

Saída dos testes das regras R01/R02 e dos mapeadores; vídeo do fluxo de 2 toques; tabela das 20 medições de tempo; prints dos goldens ao lado dos PNGs; print do Firestore com um documento de refeição; print da interface do Emulator Suite (`localhost:4000`) com documentos de teste; saída do T2 e do teste de integração; hash dos commits.

## Rascunho para a revisão técnica

> Rascunho escrito a partir do que este pacote prevê. **Substitua tudo o que está entre colchetes pelo que aconteceu de verdade** e apague o que você não fez.

**1. Código gerado por IA que precisou ser corrigido**
Pedi para a IA gerar a função que recalcula a energia quando o tutor corrige uma refeição. O trecho que precisei corrigir foi [colar o trecho real]. [Exemplo do tipo de erro que aparece neste pacote: a função buscava a densidade atual do alimento em vez de usar a densidade guardada na própria refeição. Assim, se o tutor mudasse o rótulo da ração, todas as refeições antigas mudavam de valor.] Ajustei para [usar `refeicao.densidadeKcalPor100g`] e criei um teste que [altera o alimento e confere que a refeição antiga continua com 108 kcal].

**2. Conhecimentos da disciplina aplicados**
Usei persistência local com SQLite (drift), com transações para que a refeição e a fila de sincronização sejam gravadas juntas; gerenciamento de estado com streams (Riverpod), para os totais do dia se atualizarem sozinhos depois de salvar ou excluir; formulários e validação de entrada; e diálogos e navegação entre telas para os formulários abrirem por cima do Diário. [Ajustar para os nomes da disciplina.]

**3. Solução para a dificuldade**
A solução foi guardar na própria refeição uma cópia do nome e da densidade do alimento no momento do registro, e fazer todos os cálculos a partir dessa cópia. Para verificar, escrevi testes que [criam uma refeição, mudam a densidade do alimento, editam a quantidade e conferem o valor] e testei no app [descrever o resultado].

**4. Maior dificuldade técnica**
A parte mais difícil foi manter os totais corretos quando os dados mudam depois. Uma refeição depende do alimento, mas o requisito diz que corrigir ou excluir um alimento não pode mudar o histórico. Isso apareceu [quando implementei a edição de refeições / a exclusão de alimentos] e fez [o resumo do dia mostrar valores diferentes depois de editar o alimento].

**5. Uso do Firebase**
No projeto, o Firebase só guarda a cópia remota opcional; o diário funciona todo no aparelho. Eu montei o ambiente de testes do grupo com o Firebase Local Emulator Suite, rodando Authentication, Cloud Firestore e Cloud Storage na máquina, e escrevi as funções que apontam o app para os emuladores e criam um usuário de teste. Assim todo mundo testava a sincronização sem mexer nos dados do projeto real. No Cloud Firestore, escrevi os mapeadores que transformam alimentos, refeições e petiscos em documentos dentro de `usuarios/{uid}` e o caminho de volta, e o teste de integração dessa parte, lendo os documentos direto do Firestore para conferir a versão, as lápides das exclusões e a restauração. [Apagar o que não usou.]

**6. Principal contribuição individual**
Fiz o diário de alimentação, que é a funcionalidade principal do app. O resultado concreto é que o tutor consegue registrar a refeição habitual em dois toques a partir do Início, que era o requisito de usabilidade mais importante, vê o total do dia comparado com a meta calculada, e os petiscos ficam separados da ração. A partir desses registros eu calculo a aderência ao plano alimentar e a sugestão de reduzir petiscos.

**7. Fluxo de dados com o Firebase**
Quando o tutor confirma uma refeição, o app grava a refeição no banco local e, na mesma transação, coloca um item na fila de sincronização. Só depois disso aparece "Refeição salva". Com a cópia remota ativa e Wi-Fi, o motor de sync pega esse item, usa o meu `RefeicaoMapeador` para montar o documento e grava em `usuarios/{uid}/refeicoes/{id}` com a versão. Se o tutor exclui a refeição, o documento recebe `excluido: true` em vez de sumir, para outro aparelho não restaurar. Na volta, o mapeador converte o documento de novo em refeição local.

**8. Funcionalidades implementadas**
- Atalho "Registrar refeição": abre com o alimento e a porção habituais, permite escolher outra quantidade e grava em dois toques.
- Refeições: criar, editar e excluir, com energia calculada pelo rótulo.
- Petiscos e extras: categoria separada, com energia informada.
- Alimentos e porções: cadastro com validação de densidade e exclusão que preserva o histórico.
- Resumo do dia: totais, parcela dos petiscos e comparação com a meta calculada pelo RER × fator.
- Aderência ao plano alimentar (dias dentro de ±10% da meta) e sugestão de reduzir petiscos, com o teste automatizado T2.
- Ambiente de testes com o Firebase Emulator Suite, usado pelo grupo todo nos testes de sincronização.
- Outra data e dia sem registros: sem tratar ausência como zero.
[Apagar ou detalhar.]

**9. O que faria diferente**
Eu permitiria salvar mais de uma porção por alimento (por exemplo, "manhã 30 g" e "noite 25 g") e escolher qual usar no atalho. [Ou outra melhoria real.] Priorizaria isso porque muitos tutores dividem a ração em porções diferentes ao longo do dia, e hoje o atalho de dois toques só serve para uma delas; nas outras é preciso usar "Alterar dados".

**10. Testes e evidências**
Fiz testes unitários das regras (energia, resumo do dia e validações: [N] testes), o teste oficial T2, que confere a aderência no caso de 4 de 6 dias (67%) e a sugestão de petiscos ([resultado]), testes de ida e volta dos mapeadores do Firestore, um teste de integração no Firebase Emulator que sincroniza refeições e petiscos nos dois sentidos ([resultado]) e golden tests do Diário e do atalho comparados com os PNGs. Manualmente, testei o fluxo de dois toques, o modo avião e o fechamento do app logo depois de salvar. Medi o tempo de salvar 20 vezes com 1.000 registros: [resultado]. As evidências são [prints, vídeo, tabela de tempos, commits].
