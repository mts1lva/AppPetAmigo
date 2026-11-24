# Plano de execução

Tarefas para construir o app, já incluindo as exigências da **Unidade II** (`unidade-2.md`), e a ordem entre elas.

A ordem é dada pelas **dependências entre tarefas**, em `dependencias.yaml`. Uma tarefa de qualquer pacote pode ser feita assim que todas as tarefas de que ela depende estiverem **na `dev`**, ou seja, com o PR aceito. Por isso os pacotes podem andar em paralelo. Cada integrante continua responsável pelo próprio pacote **inteiro**: código, parte Firebase, testes e evidências. **Não há etapa só de testes.** O que depende do app completo (motor de sync real e os 5 testes oficiais juntos) fecha na etapa 5.

Antes de começar uma tarefa, confira se ela está liberada. No Claude Code, a skill `executar-entrega` faz isso sozinha. No terminal:

```
dart tool/dependencias.dart verificar P2-1.3   # liberada, bloqueada (e por quê) ou já feita
dart tool/dependencias.dart proximas P2        # o que já dá para fazer no pacote 2
```

As etapas abaixo agrupam as tarefas por pacote e guardam a lista "pronta para passar" de cada pacote. **A ordem entre as etapas não é mais obrigatória.**

```
Etapa 1 ──────► Etapa 2 ──────► Etapa 3 ──────► Etapa 4 ──────► Etapa 5
P1              P2              P3              P4              P5
base, pets,     diário,         atividades,     evolução,       privacidade, sync em lote,
Início, meta    emulador do     lembretes,      gráfico,        Firebase real de todas as
                Firebase        PDF             projeção        coleções, fechamento
```

O desenho mostra o sentido geral das dependências, não uma fila. Combine com o grupo um prazo para cada pacote.

## Quem usa o quê

Resumo por pacote. O detalhe, tarefa a tarefa, está em `dependencias.yaml`.

| Pacote | Usa | Entrega para quem vem depois |
|---|---|---|
| P1 | nada | base, componentes, banco, rotas, meta M1, contratos da fila |
| P2 | P1 | `resumoDiaProvider`, aderência e ingestão (P4), Firebase Emulator Suite (todos) |
| P3 | P1, P2 (PDF) | `gastoAtividadeProvider` (P4), `GeradorExportacao` e `cancelarTodos` (P5) |
| P4 | P1, P2, P3 | curvas para o PDF do P3, `ultimaPesagemProvider`, S3 |
| P5 | todos | motor de sync que envia as coleções de todos |

## Regras

1. **Stubs só para frente.** Quem vem antes usa stub (mesma assinatura da versão final) para o que ainda não existe. Quem vem depois **troca o stub pelo real e liga os próprios dados nas telas que já existem**. Essas ligações estão listadas na etapa de cada um.
2. **Códigos e dependências.** Os códigos continuam os mesmos (`P2-1.3` = pacote 2, tarefa 1.3). O número do meio só agrupa o tipo de tarefa (0 regras e domínio, 1 telas, 2 ligações, 3 Firebase, 4 verificação), não diz quando ela é feita. A ordem vem do `dependencias.yaml`: uma tarefa só começa quando **todas as dependências diretas** estão na `dev`. Se uma dependência estiver errada, corrija a linha do `dependencias.yaml` num PR combinado com o grupo; não pule o bloqueio. Nova tarefa no plano ganha a sua linha no `dependencias.yaml` no mesmo commit, e o `flutter test` confere isso.
   - O **título** do commit leva o código da tarefa (ex.: `feat(diario): P2-1.3 formulário de refeição`). É por ele que a tarefa conta como feita. Tarefas de verificação manual também terminam com um commit de evidência que tenha o código no título.
3. **Tudo offline até a etapa 5.** Nenhuma chamada ao Firebase além da inicialização sem rede (P1-0.10). Todo repositório já chama `fila.enfileirar(...)` dentro da transação, com a `FilaSyncInativa`.
4. **A parte Firebase de cada um fica na própria etapa:** o mapeador da coleção, com teste de ida e volta, e o **teste de integração** no emulador (`integration_test/sync_<colecao>_test.dart`, roteiro na P5-3.7). Esse teste só roda quando o motor real existir; o P5 o faz passar na etapa 5. A partir da etapa 2, o emulador do P2 já sobe com `usarEmuladores()`.
5. **Git.** Cada grupo de tarefas num branch a partir da `dev` atualizada (ex.: `p2/diario`) e um PR para a `dev`. Uma tarefa conta como feita quando o PR é aceito; até lá, quem depende dela espera. PRs pequenos liberam os colegas mais cedo. Aceite os PRs com **"Create a merge commit"** ou **"Rebase and merge"**, **nunca "Squash and merge"**: o squash junta os títulos dos commits num só e as tarefas deixam de ser reconhecidas como feitas.
6. **Cada PR para a `dev`** precisa de:
   - [ ] `flutter analyze` sem avisos e `flutter test` passando, inclusive os testes oficiais que já existem;
   - [ ] o diário de bordo e as evidências atualizados (`revisao-tecnica.md`), para responder às 10 perguntas da revisão técnica (seção abaixo);
   - [ ] uma **nota de passagem** na descrição: tarefas entregues, stubs criados ou trocados, o que elas liberam e as pendências.
7. **Pacote completo.** Um pacote termina quando todas as tarefas da etapa dele estão na `dev` e a lista "pronta para passar" da etapa está marcada.

**Antes das tarefas do P2 em diante:** levar ao professor a tabela de parâmetros P-17 a P-22 (`pendencias.md`), que o enunciado não define.

---

## Etapa 1 — P1: base, pets e Início

| Tarefa | O que entregar | Referência |
|---|---|---|
| P1-0.1 a P1-0.11 | ✅ **Feito**: projeto, Clean Architecture, tema, os 7 componentes, golden, banco com todas as tabelas, formatos, rotas, M1 + **T1**, Firebase sem rede, `sugestoesProvider` | `pacote-1` → Entregas da base |
| P5-0.1 | Contratos da fila, feitos pelo P1 porque toda gravação chama a fila desde a P1-1.1: `FilaSync` (interface + `FilaSyncInativa`, que não faz nada), `OperacaoSync`, `MapeadorSync` (interface) | `dados-e-sync.md` → Contratos |
| Stubs | Os stubs que o Início usa, criados na pasta do dono, com a assinatura de "Stubs" (abaixo): `resumoDiaProvider` (P2), `lembretesProvider` (P3), `estadoCopiaProvider` (P5, sempre `desligada`) | este arquivo → Stubs |
| `ultimaPesagemProvider` | Real desde já, lendo a tabela `pesagens`, que o P1 grava no cadastro. Fica em `features/evolucao/`; o P4 assume na etapa 4 mantendo a assinatura | `pacote-1` → Início |
| P1-1.1 | Funcionalidade `pets` completa (exemplo de Clean Architecture): o cadastro grava o pet **e insere a primeira pesagem direto na tabela `pesagens`**, na mesma transação | `pacote-1` |
| P1-1.2 | Tela 26 "Vamos começar?" com o botão ligado ao 05 | `pacote-1` |
| P1-1.3 | Tela 05 Dados do pet (Sexo, idade em anos + meses, peso inicial editável, "Excluir este pet"). A conferência R06/tela 25 na edição do peso inicial entra na etapa 4 | `pacote-1` |
| P1-1.4 | Foto: `image_picker` → cópia para a área privada → `fotoArquivo` | `pacote-1` |
| P1-1.5 | **N1 Seus pets** e troca do pet atual (U2-10) | `pacote-1` |
| P1-1.6 | Tela 01 Início: cards de perfil e Referência alimentar com dados reais; Hoje, Sugestões, Lembretes e Seu controle nos stubs | `pacote-1` |
| P1-1.7 | Tela 18 "Como a meta é calculada" | `pacote-1` |
| P1-1.8 | Golden do 01 e do 05 comparados com os PNGs | `design-system.md` → Verificação visual |
| P1-3.1 | `PetMapeador` + `enviarFoto`/`baixarFoto` (Storage) + teste de ida e volta do mapeador | `pacote-1` → Parte Firebase |
| P1-3.2 | `integration_test/sync_pet_test.dart`: dois pets com foto, ida e volta, fotos no Storage (roteiro na P5-3.7). Roda na etapa 5 | `pacote-1` → Parte Firebase |
| P1-4.4 | Instalação e cadastro no emulador Android 8.0 (API 26) | `pacote-1` |
| P1-4.6 | TalkBack e fonte em 200% nas telas do P1 | `pacote-1` → Critérios |

**Pronta para passar:**
- [ ] Em modo avião: cadastrar dois pets, trocar entre eles no N1, editar (inclusive peso inicial e foto) e excluir um.
- [ ] O Início mostra a meta real da Luna (`397 kcal`) e muda sozinho ao editar o peso inicial.
- [ ] T1 e os goldens do 01 e do 05 passam.

## Etapa 2 — P2: diário

| Tarefa | O que entregar | Referência |
|---|---|---|
| P2-0.1 | Domínio do diário: R01, R02, R04, aderência (M7) e S1 (M8) + **T2** | `comum/regras.md`; M7; M8 |
| P2-1.1 | Repositórios de alimentos, refeições e extras (por pet, com lápide e fila) + testes | `pacote-2` |
| P2-1.2 | Tela 09 Alimentos e porções + tela 22 Confira a densidade | `pacote-2` |
| P2-1.3 | Tela 07 Refeição (criar/editar/excluir com `confirmarExclusao`; editar refeição passada recalcula tudo) | `pacote-2` |
| P2-1.4 | Tela 08 Petisco ou extra | `pacote-2` |
| P2-1.5 | Tela 02 Diário com a meta (R02), `PaHistorico`, seleção de data + tela 19 | `pacote-2` |
| P2-1.6 | Tela 06 Registrar refeição com **escolha de quantidade** (B-b) + tela 20 + título "Diário atualizado" | `pacote-2` |
| P2-1.7 | Golden do 02 e do 06 | `design-system.md` |
| P2-2.1 | **Ligar no Início:** trocar o stub de `resumoDiaProvider` pela leitura real (card Hoje e botão Registrar refeição); `aderenciaProvider` real; S1 no `sugestoesProvider`. Sem alimento, o atalho leva ao 09 | `pacote-2`; `pacote-1` → Início |
| P2-2.3 | **Firebase Emulator Suite** (Auth, Firestore, Storage): `firebase.json`, scripts `emuladores.sh`/`.ps1` e `integration_test/apoio_firebase.dart` com `usarEmuladores()`, `limparEmuladores()` e `criarUsuarioDeTeste()`. Documentar em `integration_test/README.md` | `pacote-2` |
| P2-3.1 | `AlimentoMapeador`, `RefeicaoMapeador`, `ExtraMapeador` + testes de ida e volta | `dados-e-sync.md` |
| P2-3.2 | Testes de integração de alimentos, refeições e extras (roteiro na P5-3.7). Rodam na etapa 5 | `pacote-2` |
| P2-4.3 | RNF06 do diário: 20 medições (salvar, abrir o resumo) com 1.000 registros, em `--profile` | `arquitetura.md` → Desempenho |
| P2-4.6 | TalkBack e fonte em 200% nas telas do P2 | `pacote-2` |

**Pronta para passar:**
- [ ] Em modo avião: registrar refeição pelo atalho em 2 toques, petisco, editar uma refeição passada e ver os totais mudarem.
- [ ] O card Hoje do Início mostra os dados reais.
- [ ] T1 e T2 passam; `usarEmuladores()` conecta a um emulador local rodando.

## Etapa 3 — P3: atividades, lembretes e PDF

| Tarefa | O que entregar | Referência |
|---|---|---|
| P3-0.1 | Domínio dos lembretes (entidade, `AgendadorNotificacoes`, `ReagendarTodos`), gasto de atividade (M4) e S2 (M8) + **T3** com agendador falso | `pacote-3` |
| P3-0.2 | `assets/conteudo/dicas.json` (pelo menos 3 dicas por espécie, `em_revisao`) | `pacote-3` |
| P3-1.1 | Repositórios de atividades e lembretes + testes | `pacote-3` |
| P3-1.2 | Tela 10 Passeio ou brincadeira | `pacote-3` |
| P3-1.3 | Tela 03 Atividades (Hoje, Anteriores, Novo momento, Dica) | `pacote-3` |
| P3-1.4 | `AgendadorLocal` (`flutter_local_notifications`), permissões, toque na notificação, reagendar ao abrir | `pacote-3` |
| P3-1.5 | **N2 Lembretes** e diálogo de edição (U2-09) | `pacote-3` |
| P3-1.6 | Teste manual: aviso com o app fechado pelo sistema (`adb shell am kill`), no modo soneca e depois de reiniciar | `pacote-3` |
| P3-1.7 | `GeradorPdf` (R12) com os dados reais do diário + tela 13 + `share_plus` (U2-18). As curvas do gráfico usam dados de exemplo até a etapa 4 | `pacote-3`; R12 |
| P3-1.8 | `GeradorExportacao` (R13) | R13 |
| P3-1.9 | Golden do 03 | `design-system.md` |
| P3-2.1 | **Ligar no Início:** trocar o stub de `lembretesProvider` (card Lembretes → N2); `gastoAtividadeProvider` real; S2 no `sugestoesProvider` | `pacote-3`; `pacote-1` → Início |
| P3-3.1 | `AtividadeMapeador`, `LembreteMapeador` + testes de ida e volta | `dados-e-sync.md` |
| P3-3.2 | Testes de integração de atividades e lembretes, conferindo o reagendamento (roteiro na P5-3.7). Rodam na etapa 5 | `pacote-3` |
| P3-4.5 | Lembretes num emulador Android 14 (alarme exato negado por padrão) e no Android 8.0 | `pacote-3` |
| P3-4.6 | TalkBack e fonte em 200% nas telas do P3 | `pacote-3` |

**Pronta para passar:**
- [ ] Em modo avião: registrar e editar atividades, criar lembretes e recebê-los com o app fechado, gerar o PDF com o diário real.
- [ ] O card Lembretes do Início mostra os horários reais.
- [ ] T1, T2 e T3 passam.

## Etapa 4 — P4: evolução

| Tarefa | O que entregar | Referência |
|---|---|---|
| P4-0.1 | Domínio da evolução: R06, M2, M3, M4, M5, M6 (dados do gráfico), M7 (evolução), S3 e celebração (M8) + **T4** | `modelos-matematicos.md` |
| P4-1.1 | Repositórios de pesagens e referências + testes; assumir o `ultimaPesagemProvider` criado pelo P1, mantendo a assinatura | `pacote-4` |
| P4-1.2 | Tela 11 Pesagem (inclusive peso inicial) + tela 25 Conferir pesagem + **N3** celebração | `pacote-4` |
| P4-1.3 | Providers de M9 (peso ideal, curvas, projeção, previsão, indicadores) sobre os streams reais do P2 e do P3 | `pacote-4`; M9 |
| P4-1.4 | **Gráfico interativo** (`CustomPainter` + gestos, balão, estado vazio) (U2-02) | `design-system.md` → Gráfico |
| P4-1.5 | Tela 04 Evolução com o card Indicadores | `pacote-4` |
| P4-1.6 | Tela 12 ECC e objetivo | `pacote-4` |
| P4-1.7 | Golden do 04 com 0, 1 e 3 pesagens | `design-system.md` |
| P4-2.1 | **Ligar no que já existe:** S3 no `sugestoesProvider`; conferência R06 + tela 25 na edição do peso inicial do 05 (P1) | `pacote-4`; `pacote-1` → Tela 05 |
| P4-2.2 | "Compartilhar resumo" abre a tela 13; o PDF do P3 passa a usar as curvas reais | `pacote-4`; `pacote-3` |
| P4-2.4 | **U2-05**: registrar refeição, editar peso e registrar atividade com a Evolução aberta, e ver a projeção mudar na hora | U2-05; M9 |
| P4-3.1 | `PesagemMapeador`, `ReferenciaMapeador` + testes de ida e volta | `dados-e-sync.md` |
| P4-3.2 | Testes de integração de pesagens e referências, conferindo o recálculo da projeção (roteiro na P5-3.7). Rodam na etapa 5 | `pacote-4` |
| P4-4.3 | RNF06 da evolução: 20 medições (abrir o gráfico, recalcular a projeção) com 1.000 registros, em `--profile` | `arquitetura.md` → Desempenho |
| P4-4.6 | TalkBack e fonte em 200% nas telas do P4 | `pacote-4` |

**Pronta para passar:**
- [ ] Em modo avião: pesagem com conferência e celebração, ECC/objetivo, arrastar o dedo no gráfico, projeção mudando em tempo real.
- [ ] O PDF tem as curvas reais; o peso inicial do 05 passa pela conferência.
- [ ] T1 a T4 passam.

## Etapa 5 — P5: privacidade e cópia remota

| Tarefa | O que entregar | Referência |
|---|---|---|
| P5-1.1 | Tela 14 Seus dados | `pacote-5` |
| P5-1.2 | Exclusão integral local (transação, fotos, `cancelarTodos` dos lembretes do P3, volta ao 26) | `pacote-5` |
| P5-1.3 | `wifi.dart` (`connectivity_plus`) | `pacote-5` |
| P5-1.4 | `FilaSyncAtiva` + `MotorSync` com **envio em lote** contra um **remoto falso em memória** (`FakeRemoto`) + **T5** | `dados-e-sync.md` → Envio em lote |
| P5-1.5 | `firestore.rules` e `storage.rules` | `dados-e-sync.md` |
| P5-2.2 | "Exportar dados" usa o `GeradorExportacao` do P3 | `pacote-5` |
| P5-3.1 | `FirebaseRemoto` real com **`WriteBatch`** (troca o `FakeRemoto`), rede só no Wi-Fi, registrando os mapeadores de todos os pacotes | `pacote-5` |
| P5-3.2 | Tela 15 Cópia remota opcional (Auth, ativar/desativar, primeiro envio em lotes, restauração + `ReagendarTodos`) | `pacote-5` |
| P5-3.3 | Tela 16 Cópia remota + `estadoCopiaProvider` real (troca o stub; card Seu controle do Início) | `pacote-5` |
| P5-3.4 | Tela 17 Conferir versões | `pacote-5` |
| P5-3.5 | Exclusão integral remota + mensagem no 26 | `pacote-5` |
| P5-3.6 | Testar as regras no emulador (usuário A não lê nem grava os dados de B) e publicar no projeto real | `pacote-5` |
| P5-3.7 | Fazer passar no emulador os testes de integração de todas as coleções (P1-3.2 a P4-3.2). Roteiro de cada teste: **ida**: cria, edita e exclui pelo repositório → roda o motor → lê o documento com `FirebaseFirestore.instance` e confere campos, `versao` e lápide; **volta**: grava um documento direto no emulador → roda o pull → confere o registro local. Se um teste falhar por causa de uma coleção, o dono dela corrige | `dados-e-sync.md` |
| P5-4.7 | Network Inspector: nada sai em modo avião ou com dados móveis | `pacote-5` |
| P5-4.6 | TalkBack e fonte em 200% nas telas do P5 | `pacote-5` |

**Pronta para passar (fechamento do projeto):**
- [ ] Todos os critérios de aceite do pacote 5 passam com todas as coleções e vários pets.
- [ ] Os testes de integração de todas as coleções passam no emulador.
- [ ] Os **5 testes automatizados oficiais (U2-17)** rodam juntos em `flutter test`, com a saída salva como evidência.
- [ ] Sincronização feita uma vez no projeto real; cada integrante tira o print do próprio tipo de registro no console do Firestore para as evidências.

---

## Stubs

Um stub é uma implementação provisória com a **mesma assinatura** da versão final. Quem usa o provider não muda nada quando o dono troca o stub pela versão real na própria etapa.

| Stub | Quem cria | Quem troca |
|---|---|---|
| `resumoDiaProvider(petId, dia)` → `ResumoDia.vazio` | P1 (etapa 1) | P2 (P2-2.1) |
| `lembretesProvider(petId)` → lista vazia | P1 (etapa 1) | P3 (P3-2.1) |
| `estadoCopiaProvider` → sempre `desligada` | P1 (etapa 1) | P5 (P5-3.3) |
| S1, S2, S3 → `null` no `sugestoesProvider` | P1 (P1-0.11, feito) | P2, P3 e P4 (P2-2.1, P3-2.1, P4-2.1) |
| Curvas do gráfico do PDF → dados de exemplo | P3 (P3-1.7) | P4 (P4-2.2) |

```dart
// lib/features/diario/apresentacao/providers.dart (criado pelo P1, trocado na P2-2.1)
final resumoDiaProvider = StreamProvider.family<ResumoDia, (String petId, DateTime dia)>(
  (ref, args) => Stream.value(ResumoDia.vazio(args.$2)), // TODO(P2-2.1): ler do banco
);
```

O `ultimaPesagemProvider` não é stub: o P1 já o implementa lendo a tabela `pesagens`, e o P4 o assume na P4-1.1.

---

## Os 5 testes automatizados oficiais (U2-17)

| # | Teste | Dono | Etapa | Arquivo |
|---|---|---|---|---|
| T1 | Meta diária (RER × fator) | P1 | 1 (✅ feito) | `test/nutricao/meta_diaria_test.dart` |
| T2 | Aderência ao plano + sugestão de petiscos | P2 | 2 | `test/diario/aderencia_e_petiscos_test.dart` |
| T3 | Agendamento dos lembretes + gasto de atividade | P3 | 3 | `test/lembretes/agendamento_test.dart` |
| T4 | Projeção adaptativa, limite e data prevista (com divisão por zero) | P4 | 4 | `test/evolucao/projecao_test.dart` |
| T5 | Sincronização em lote | P5 | 5 | `test/sync/lote_test.dart` |

A partir da etapa em que entra, cada teste oficial precisa continuar passando em todas as etapas seguintes. Na etapa 5, os cinco rodam juntos como evidência final.

---

## Revisão técnica individual

Cada integrante precisa responder **sozinho** às 10 perguntas da revisão técnica (rascunho no fim do próprio pacote; preparação em `revisao-tecnica.md`). Por isso, cada etapa inclui código, uma parte Firebase própria e testes próprios. Preencha o diário de bordo **durante** a etapa, não no fim.

| Pergunta | Etapa 1 (P1) | Etapa 2 (P2) | Etapa 3 (P3) | Etapa 4 (P4) | Etapa 5 (P5) |
|---|---|---|---|---|---|
| 1. Código de IA corrigido | componentes e telas | repositórios e formulários | agendador e PDF | modelos e gráfico | motor de sync |
| 2. Conhecimentos aplicados | layout, tema, rotas, SQLite | formulários, CRUD, streams | notificações, arquivos | `CustomPainter`, gestos, cálculo | autenticação, rede, lotes |
| 3 e 4. Dificuldade e solução | fidelidade ao Figma × fonte 200% | atalho em 2 toques, recálculo | aviso com o app fechado | projeção e divisão por zero | lote atômico, conflitos |
| 5. Uso do Firebase | projeto, `flutterfire`, init sem rede, Storage | Emulator Suite, mapeadores | mapeadores, reagendamento | mapeadores, recálculo | Auth, `WriteBatch`, regras |
| 6. Contribuição | base usada por todos | diário | lembretes e PDF | evolução | cópia remota e privacidade |
| 7. Fluxo de dados com o Firebase | pet e foto | refeição | lembrete | pesagem | ciclo de envio e pull |
| 8. Funcionalidades | tabela da etapa 1 | tabela da etapa 2 | tabela da etapa 3 | tabela da etapa 4 | tabela da etapa 5 |
| 9. O que faria diferente | livre | livre | livre | livre | livre |
| 10. Testes e evidências | T1, widget, golden, P1-3.2 | T2, golden, P2-3.2, RNF06 | T3, golden, P3-3.2, Android 14 | T4, golden, P4-3.2, RNF06 | T5, regras, P5-3.7, Network Inspector |
