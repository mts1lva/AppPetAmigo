# Plano de execução

Ordem em que o app deve ser construído, já incluindo as exigências da **Unidade II** (`unidade-2.md`). Cada fase só começa quando a anterior passa no **portão**, que é a lista "pronta quando". Dentro de uma fase, os pacotes trabalham **em paralelo**. As tarefas de cada pacote seguem a **ordem numérica**, porque cada uma depende da anterior.

Identificação: `P2-1.3` = pacote 2, fase 1, tarefa 3. Use esse código nas mensagens de commit (ex.: `feat(diario): P2-1.3 formulário de refeição`). Isso facilita juntar evidências para a revisão técnica.

```
Fase 0  Fundação ──────────► Fase 1  Funcionalidades locais ──► Fase 2  Integração local ──► Fase 3  Firebase ──► Fase 4  Verificação final
(P1 base + Clean Arch;       (5 pacotes em paralelo,            (stubs → dados reais,        (mapeadores, Auth,    (5 testes oficiais,
 P5 contratos; P2–P4         tudo offline)                      emulador do Firebase)        envio em lote,        desempenho, Android 8,
 modelos em Dart puro)                                                                        exclusão)             acessibilidade, evidências)
```

---

## Fase 0 — Fundação

Objetivo: qualquer pessoa consegue abrir o app com 4 abas vazias e já tem tema, componentes, banco completo, a estrutura da Clean Architecture e os contratos para trabalhar sem esperar ninguém. Os modelos matemáticos são escritos e testados aqui, porque não dependem de tela.

| Tarefa | Quem | O que entregar | Referência |
|---|---|---|---|
| P1-0.1 | P1 | `flutter create`, `minSdkVersion 26`, dependências de `arquitetura.md`, desugaring no Gradle, Inter e gato em `assets/`, `flutter_lints` | `comum/arquitetura.md` |
| P1-0.2 | P1 | Esqueleto de pastas da **Clean Architecture** para todas as funcionalidades + `core/resultado.dart` (U2-14) | `arquitetura.md` → Clean Architecture |
| P1-0.3 | P1 | `app/tema/*` (cores, espaços, tipografia, `ThemeData`) | `comum/design-system.md` |
| P1-0.4 | P1 | Os 7 componentes em `core/ui/` + `confirmarExclusao()` (tela 23), cada um com widget test | `comum/design-system.md`; `pacote-1` → Tela 23 |
| P1-0.5 | P1 | Infraestrutura de golden test (Inter carregada, 390 × 844) + um exemplo | `comum/design-system.md` → Verificação visual |
| P1-0.6 | P1 | `core/banco/database.dart` com **todas** as tabelas (inclusive `lembretes`, `petId` e `idadeMeses`) e índices, migração 1. Ninguém mais edita o esquema nesta fase | `comum/dados-e-sync.md` |
| P1-0.7 | P1 | `core/formato/` (R10, R11) com testes | `comum/regras.md` |
| P1-0.8 | P1 | `router.dart`: 4 abas com telas provisórias (só o título) e o estado "sem pet"; `petAtualIdProvider` | `comum/navegacao.md` |
| P1-0.9 | P1 | `features/nutricao/domain/meta_diaria.dart` (M1) + **T1** | `modelos-matematicos.md` → M1 |
| P1-0.10 | P1 | Projeto Firebase criado, `flutterfire configure`, inicialização no `main` com persistência e rede desligadas; fuso horário e plugin de notificações inicializados | `pacote-1` → Parte Firebase; `pacote-3` |
| P5-0.1 | P5 | `FilaSync` (interface + `FilaSyncInativa`, que não faz nada), `OperacaoSync`, `MapeadorSync` (interface) | `comum/dados-e-sync.md` → Contratos |
| P5-0.2 | P5 | Stub `estadoCopiaProvider` → sempre `desligada` | este arquivo → Stubs |
| P2-0.1 | P2 | Domínio do diário: R01, R02, R04, aderência (M7) e S1 (M8) + **T2** | `comum/regras.md`; M7; M8 |
| P2-0.2 | P2 | Stubs: `resumoDiaProvider(petId, dia)` vazio; `aderenciaProvider(petId)` indisponível | este arquivo → Stubs |
| P3-0.1 | P3 | Domínio dos lembretes (entidade, `AgendadorNotificacoes`, `ReagendarTodos`), gasto de atividade (M4) e S2 (M8) + **T3** com agendador falso | `pacote-3` |
| P3-0.2 | P3 | Rascunho do `assets/conteudo/dicas.json` (pelo menos 3 dicas por espécie, `em_revisao`) | `pacote-3` |
| P3-0.3 | P3 | Stubs: `lembretesProvider(petId)` vazio; `gastoAtividadeProvider(petId)` = 0 | este arquivo → Stubs |
| P4-0.1 | P4 | Domínio da evolução: R06, M2, M3, M4, M5, M6 (dados do gráfico), M7 (evolução), S3 e celebração (M8) + **T4** | `modelos-matematicos.md` |
| P4-0.2 | P4 | Stubs: `ultimaPesagemProvider(petId)` → `null` | este arquivo → Stubs |
| P1-0.11 | P1 | `sugestoesProvider(petId)` juntando S1, S2 e S3 (todas ainda devolvem `null` até a Fase 2) | M8 |

**Fase 0 pronta quando:**
- [ ] O app abre no emulador com as 4 abas (provisórias) e o estado "sem pet".
- [ ] `flutter test` passa, inclusive **T1, T2, T3 e T4** (o T5 é da Fase 1).
- [ ] Todas as tabelas existem no banco; o domínio de cada funcionalidade não importa Flutter, drift nem Firebase.
- [ ] Os stubs estão no código.

### Stubs

Um stub é uma implementação provisória com a **mesma assinatura** da versão final. Quem usa o provider não muda nada quando o dono troca o stub pela versão real na Fase 2.

```dart
// lib/features/diario/apresentacao/providers.dart (P2-0.2, trocado na P2-2.1)
final resumoDiaProvider = StreamProvider.family<ResumoDia, (String petId, DateTime dia)>(
  (ref, args) => Stream.value(ResumoDia.vazio(args.$2)), // TODO(P2-2.1): ler do banco
);
```

---

## Fase 1 — Funcionalidades locais (em paralelo, tudo offline)

Regra da fase: **nenhuma chamada ao Firebase**. Todo repositório já chama `fila.enfileirar(...)` dentro da transação, mas a fila ainda é a `FilaSyncInativa`. Todos os dados são filtrados pelo **pet atual**.

### P1 — Pets e Início
| Tarefa | O que entregar |
|---|---|
| P1-1.1 | Funcionalidade `pets` completa (exemplo de Clean Architecture): o cadastro grava o pet **e insere a primeira pesagem direto na tabela `pesagens`**, na mesma transação |
| P1-1.2 | Tela 26 "Vamos começar?" |
| P1-1.3 | Tela 05 Dados do pet (Sexo, idade em anos + meses, peso inicial editável, "Excluir este pet") |
| P1-1.4 | Foto: `image_picker` → cópia para a área privada → `fotoArquivo` |
| P1-1.5 | **N1 Seus pets** e troca do pet atual (U2-10) |
| P1-1.6 | Tela 01 Início com os stubs (cards Hoje, Sugestões, Referência alimentar com a meta real, Lembretes, Seu controle) |
| P1-1.7 | Tela 18 "Como a meta é calculada" |
| P1-1.8 | Golden do 01 e do 05 comparados com os PNGs |

### P2 — Diário (nesta ordem: alimento → refeição → petisco → diário → atalho)
| Tarefa | O que entregar |
|---|---|
| P2-1.1 | Repositórios de alimentos, refeições e extras (por pet, com lápide e fila) + testes |
| P2-1.2 | Tela 09 Alimentos e porções + tela 22 Confira a densidade |
| P2-1.3 | Tela 07 Refeição (criar/editar/excluir com `confirmarExclusao`; editar refeição passada recalcula tudo) |
| P2-1.4 | Tela 08 Petisco ou extra |
| P2-1.5 | Tela 02 Diário com a meta (R02), `PaHistorico`, seleção de data + tela 19 |
| P2-1.6 | Tela 06 Registrar refeição com **escolha de quantidade** (B-b) + tela 20 + título "Diário atualizado" |
| P2-1.7 | Golden do 02 e do 06 |

### P3 — Atividades, lembretes e PDF
| Tarefa | O que entregar |
|---|---|
| P3-1.1 | Repositórios de atividades e lembretes + testes |
| P3-1.2 | Tela 10 Passeio ou brincadeira |
| P3-1.3 | Tela 03 Atividades (Hoje, Anteriores, Novo momento, Dica) |
| P3-1.4 | `AgendadorLocal` (`flutter_local_notifications`), permissões, toque na notificação, reagendar ao abrir |
| P3-1.5 | **N2 Lembretes** e diálogo de edição (U2-09) |
| P3-1.6 | Teste manual: aviso com o app fechado pelo sistema (`adb shell am kill`), no modo soneca e depois de reiniciar |
| P3-1.7 | `GeradorPdf` (R12) com dados de exemplo + tela 13 + `share_plus` (U2-18) |
| P3-1.8 | `GeradorExportacao` (R13) |
| P3-1.9 | Golden do 03 |

### P4 — Evolução
| Tarefa | O que entregar |
|---|---|
| P4-1.1 | Repositórios de pesagens e referências + testes |
| P4-1.2 | Tela 11 Pesagem (inclusive peso inicial) + tela 25 Conferir pesagem + **N3** celebração |
| P4-1.3 | Providers de M9 (peso ideal, curvas, projeção, previsão, indicadores) sobre os streams, usando os stubs do P2 e do P3 |
| P4-1.4 | **Gráfico interativo** (`CustomPainter` + gestos, balão, estado vazio) (U2-02) |
| P4-1.5 | Tela 04 Evolução com o card Indicadores (o botão "Compartilhar resumo" fica desabilitado até a P4-2.2) |
| P4-1.6 | Tela 12 ECC e objetivo |
| P4-1.7 | Golden do 04 com 0, 1 e 3 pesagens |

### P5 — Privacidade e motor de sync (sem Firebase real ainda)
| Tarefa | O que entregar |
|---|---|
| P5-1.1 | Tela 14 Seus dados ("Exportar dados" desabilitado até a P5-2.2; "Excluir todos os dados" já funciona **localmente**) |
| P5-1.2 | Exclusão integral local (transação, fotos, `cancelarTodos` dos lembretes, volta ao 26) |
| P5-1.3 | `wifi.dart` (`connectivity_plus`) |
| P5-1.4 | `FilaSyncAtiva` + `MotorSync` com **envio em lote** contra um **remoto falso em memória** (`FakeRemoto`) + **T5** |
| P5-1.5 | Escrever `firestore.rules` e `storage.rules` (os testes ficam na P5-3.6, com o emulador do P2) |

**Fase 1 pronta quando:**
- [ ] Em **modo avião**, dá para: cadastrar dois pets e trocar entre eles, registrar refeição pelo atalho em 2 toques, petisco, atividade e pesagem (com conferência e celebração), mudar ECC/objetivo, arrastar o dedo no gráfico, criar lembretes e recebê-los com o app fechado, gerar o PDF e excluir tudo.
- [ ] Goldens de todas as telas principais gerados e comparados com os PNGs.
- [ ] T1 a T5 passam.

---

## Fase 2 — Integração local

| Tarefa | Quem | O que entregar |
|---|---|---|
| P2-2.1 | P2 | Trocar os stubs de `resumoDiaProvider` e `aderenciaProvider` pela leitura real; ligar S1 ao `sugestoesProvider` |
| P3-2.1 | P3 | Trocar os stubs de `lembretesProvider` e `gastoAtividadeProvider`; ligar S2 |
| P4-2.1 | P4 | Trocar o stub de `ultimaPesagemProvider`; ligar S3; a projeção passa a usar os dados reais do P2 e do P3 |
| P1-2.1 | P1 | Conferir o Início com dados reais (cards, meta, sugestões, lembretes; golden de novo). Se o atalho não tiver alimento, levar ao 09 |
| P4-2.2 | P4 + P3 | "Compartilhar resumo" abre a tela 13; o PDF usa as curvas reais do P4 |
| P5-2.2 | P5 + P3 | "Exportar dados" usa o `GeradorExportacao` do P3 |
| P2-2.3 | P2 | **Firebase Emulator Suite** (Auth, Firestore, Storage): `firebase.json`, scripts `emuladores.sh`/`.ps1` e `integration_test/apoio_firebase.dart` com `usarEmuladores()`, `limparEmuladores()` e `criarUsuarioDeTeste()`. Documentar em `integration_test/README.md` |
| Todos-2.4 | todos | Fluxo completo de ponta a ponta, incluindo **U2-05**: registrar refeição, editar peso e registrar atividade com a Evolução aberta, e ver a projeção mudar na hora |

**Fase 2 pronta quando:** o app inteiro funciona offline com dados reais em todas as telas, sem nenhum stub, e `usarEmuladores()` conecta a um emulador local rodando.

---

## Fase 3 — Firebase (cópia remota)

| Tarefa | Quem | O que entregar |
|---|---|---|
| P1-3.1 | P1 | `PetMapeador` + `enviarFoto`/`baixarFoto` (Storage) + testes |
| P2-3.1 | P2 | `AlimentoMapeador`, `RefeicaoMapeador`, `ExtraMapeador` + testes |
| P3-3.1 | P3 | `AtividadeMapeador`, `LembreteMapeador` + testes |
| P4-3.1 | P4 | `PesagemMapeador`, `ReferenciaMapeador` + testes |
| P5-3.1 | P5 | `FirebaseRemoto` real com **`WriteBatch`** (troca o `FakeRemoto`), rede só no Wi-Fi |
| P5-3.2 | P5 | Tela 15 Cópia remota opcional (Auth, ativar/desativar, primeiro envio em lotes, restauração + `ReagendarTodos`) |
| P5-3.3 | P5 | Tela 16 Cópia remota + `estadoCopiaProvider` real (troca o stub) |
| P5-3.4 | P5 | Tela 17 Conferir versões |
| P5-3.5 | P5 | Exclusão integral remota + mensagem no 26 |
| P5-3.6 | P5 | Testar as regras no emulador (usuário A não lê nem grava os dados de B) e publicar no projeto real |
| P1-3.2 · P2-3.2 · P3-3.2 · P4-3.2 | P1, P2, P3, P4 | **Teste de integração da própria coleção no emulador** (`integration_test/sync_<colecao>_test.dart`): **ida**: cria, edita e exclui pelo repositório → roda o motor → lê o documento com `FirebaseFirestore.instance` e confere campos, `versao` e lápide. **Volta**: grava um documento direto no emulador → roda o pull → confere o registro local. O P1 também testa as fotos no Storage; o P3 confere o reagendamento dos lembretes; o P4 confere o recálculo da projeção |
| Todos-3.7 | todos | Repetir uma vez no projeto real e conferir no console do Firestore o próprio tipo de registro (print para as evidências) |

As tarefas de mapeador (P1 a P4) podem começar assim que a Fase 2 fechar. O P5 integra cada mapeador conforme ficar pronto. Os testes de integração (x-3.2) dependem do `FirebaseRemoto` real (P5-3.1) e do emulador (P2-2.3).

**Fase 3 pronta quando:** todos os critérios de aceite do pacote 5 passam com todas as coleções e vários pets.

---

## Fase 4 — Verificação final

| Tarefa | Quem | O que entregar |
|---|---|---|
| Todos-4.1 | todos | Critérios de aceite do próprio pacote, todos marcados |
| Todos-4.2 | todos | **5 testes automatizados oficiais (U2-17)** rodando juntos em `flutter test`, com a saída salva como evidência |
| P2-4.3 / P4-4.3 | P2, P4 | RNF06: 20 medições (salvar; abrir resumo e gráfico; recalcular a projeção) com 1.000 registros, em modo `--profile` |
| P1-4.4 | P1 | Instalação e fluxo essencial no emulador Android 8.0 (API 26) |
| P3-4.5 | P3 | Lembretes num emulador Android 14 (alarme exato negado por padrão) e no Android 8.0 |
| Todos-4.6 | todos | TalkBack e fonte em 200% nas telas do próprio pacote |
| P5-4.7 | P5 | Network Inspector: nada sai em modo avião ou com dados móveis |
| Todos-4.8 | todos | Evidências guardadas e rascunho da revisão técnica adaptado (`revisao-tecnica.md`) |

### Os 5 testes automatizados oficiais (U2-17)

| # | Teste | Dono | Arquivo |
|---|---|---|---|
| T1 | Meta diária (RER × fator) | P1 | `test/nutricao/meta_diaria_test.dart` |
| T2 | Aderência ao plano + sugestão de petiscos | P2 | `test/diario/aderencia_e_petiscos_test.dart` |
| T3 | Agendamento dos lembretes + gasto de atividade | P3 | `test/lembretes/agendamento_test.dart` |
| T4 | Projeção adaptativa, limite e data prevista (com divisão por zero) | P4 | `test/evolucao/projecao_test.dart` |
| T5 | Sincronização em lote | P5 | `test/sync/lote_test.dart` |

**Fase 4 pronta quando:** todas as caixas dos 5 pacotes estiverem marcadas, os 5 testes oficiais passarem e cada integrante tiver as próprias evidências.
