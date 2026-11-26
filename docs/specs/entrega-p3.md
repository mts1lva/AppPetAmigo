# Entrega do P3 — atividades, lembretes e exportação

Branch: `p3/paulo-atividades-lembretes`, criada a partir de `origin/dev`.
Responsável: paulofontes-cyber. Estado em 25/11/2026.

## Tarefas na branch

| Tarefa | Entrega |
|---|---|
| P3-0.1 | Domínio em Dart puro: atividades, gasto M4, sugestão S2, contratos de lembretes, reagendamento e T3 |
| P3-0.2 | Seis dicas locais, três por espécie, com fonte e situação `em_revisao` |
| P3-1.1 | Repositórios drift com isolamento por pet, validação, versões, lápides e fila na mesma transação |
| P3-1.2 | Formulário de passeio/brincadeira, validação de duração e data, edição e exclusão confirmada |
| P3-1.3 | Aba Atividades real, registros de hoje, anteriores, estado vazio e dicas por espécie |
| P3-1.4 | Agendador Android diário, permissões, receivers de reinício, troca de pet e abertura por notificação; contratos para destinos de outros pacotes abaixo |
| P3-1.5 | Lista N2, horários sugeridos, criação/edição, pausa, exclusão e estados de permissão |
| P3-1.8 | Gerador JSON formato 2 com todas as tabelas de domínio, todos os pets ativos e sem fotos ou colunas de sync; compartilhador com limpeza do arquivo |
| P3-1.9 | Goldens da aba Atividades em 100% e 200%, comparados com o protótipo |
| P3-2.1 | Lembretes reais e botão N2 no Início; providers de gasto e S2 ligados; peso ideal aguarda M2 do P4 |
| P3-3.1 | Mapeadores de atividades/lembretes, validação de documentos e testes de ida e volta |

Os códigos nos commits representam a implementação desta branch. A liberação para os colegas acontece depois do merge na `dev`.

## Tarefas que ainda não podem ser concluídas

| Tarefa | O que falta |
|---|---|
| P3-1.6 | Teste manual de notificação com o app fechado pelo sistema, modo soneca e reinício |
| P3-1.7 | `P2-1.1` na `dev`: o PDF deve usar o diário real. Nenhum PDF ou formulário de compartilhamento provisório foi implementado |
| P3-3.2 | `P2-2.3` na `dev`: infraestrutura Firebase Emulator Suite; o teste com o motor real também roda na etapa do P5 |
| P3-4.5 | P3-1.6 e execução em Android 8.0/API 26 e Android 14/API 34 |
| P3-4.6 | P3-1.7 e conferência manual do TalkBack nas telas do pacote; testes automatizados de fonte 200% já existem |

`flutter doctor -v` não encontrou Android SDK nem dispositivo/emulador Android neste computador. Não houve build de APK, teste em aparelho ou execução dos cenários manuais. Essas tarefas não têm commit de conclusão.

## Contratos para os próximos pacotes

- **P2 e P4 — toque na notificação:** `lib/app/coordenador_lembretes.dart` expõe `abridoresLembreteProvider` e `registroLembretePendenteProvider`. Atividade já abre o formulário real. Refeição e pesagem selecionam o pet e a aba correspondente, preservando o destino pendente. Os donos devem registrar os abridores dos diálogos 06 e 11 e consumir esse destino, inclusive em abertura a frio. A navegação completa desses dois tipos ainda depende desses formulários.
- **P4 — S2 e gasto:** `indicadores_atividade_provider.dart` expõe `gastoAtividadeProvider(petId)` como `Resultado<double>?`, média diária de kcal nos últimos 14 dias. `null` indica leitura em andamento; `Indisponivel` indica ausência da pesagem necessária ao RER. `pesoIdealAtividadeProvider(petId)` é o único stub novo: retorna `null` até o P4 ligá-lo ao M2. A regra S2 é testada e ligada ao Início, mas permanece oculta sem esse peso ideal.
- **P5 — exportação:** `geradorExportacaoProvider` fornece `GeradorExportacao.gerarJson()`. Somente a ação explícita do tutor deve gerar o arquivo e chamar `compartilharArquivo(..., tipoMime: 'application/json')`. O gerador não chama Firebase.
- **P5 — lembretes:** `reagendarTodosProvider` fornece o caso de uso a chamar depois de aplicar a restauração. Usa todos os pets, preserva pausas e compartilha o serializador com as gravações locais.
- **P5 — mapeamento:** `LembreteMapeador` recebe `notificacaoIdLocal(id)`. O motor deve fornecer um id único/estável deste aparelho, alocado ou recuperado do banco; esse valor não é transmitido no Firestore. Os mapeadores não fazem rede nem aplicam documentos diretamente ao banco.

## Verificação

Ambiente: Flutter 3.50.1 / Dart 3.14.0, Windows. Executar na raiz:

```text
flutter pub get
flutter analyze
flutter test
dart tool/dependencias.dart validar
dart tool/dependencias.dart proximas P3
```

A suíte completa passou com 261 testes, incluindo T1, T3, rollback de gravação em falha da fila, isolamento entre pets, repetição de horários, falha do agendador sem perda do registro, toque na notificação, exportação JSON e goldens. T2, T4 e T5 ainda dependem da integração dos pacotes correspondentes.

Os testes do plugin usam o canal Android simulado; eles não substituem a observação de notificações em aparelho. As diferenças visuais estão em `test/goldens/diferencas.md`.

Após instalar o SDK e iniciar um emulador, conferir o roteiro do pacote usando `adb shell am kill br.com.petamigo.petamigo`, `adb shell dumpsys deviceidle force-idle`, `adb shell dumpsys deviceidle unforce` e reinício. Programar um lembrete próximo antes de fechar o app e guardar a evidência individual localmente. "Forçar parada" pelas configurações não equivale ao encerramento pelo sistema e cancela os alarmes até reabrir o app.

O PR deve entrar com **Create a merge commit** ou **Rebase and merge**, preservando os códigos das tarefas nos títulos. Não usar squash.
