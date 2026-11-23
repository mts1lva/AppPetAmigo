# Pacote 3 — Atividades, lembretes e relatório em PDF

**Responsável:** ______________________

## Objetivo

Entregar a aba **Atividades** (passeios e brincadeiras, com dicas por espécie e o gasto estimado que alimenta a projeção), os **lembretes locais** que disparam mesmo com o app fechado, o **resumo em PDF** para o veterinário e a **exportação dos dados**. Arquivos só saem do aparelho quando o tutor pede.

**Requisitos:** RF12, RF13, RF16 (exportação), RF18, RNF05, RNF07 (sem GPS), RNF10 · **Unidade II:** U2-04 (gasto de atividade na projeção), U2-09, U2-11 (S2), U2-18, teste oficial T3.
**Depende de:** P1 (base e todas as tabelas, criadas na Fase 0). O PDF lê as tabelas e os providers do P2 e do P4; até a Fase 2, os testes populam dados de exemplo. **Entrega para:** P1 (`lembretesProvider`, card Lembretes), P4 (`gastoAtividadeProvider` e diálogo 13), P5 (`GeradorExportacao` e `AgendadorNotificacoes.cancelarTodos` na exclusão integral).

**Ordem de execução:** tarefas `P3-0.x` → `P3-1.x` → `P3-2.x` → `P3-3.x` → `P3-4.x` do `plano-de-execucao.md`. Comece pelo domínio dos lembretes e pelo gasto de atividade (Fase 0, Dart puro).

## Dados e regras

- Tabelas `atividades` e `lembretes` (`comum/dados-e-sync.md`), ambas por pet.
- Regras: R05 (duração e horário), R10, R12 (PDF), R13 (exportação), R14 (textos dos lembretes); M4 (kcal de atividade) e M8 (S2).
- **A atividade não muda a meta diária** (para não "liberar" petisco por causa do passeio), mas **entra na projeção de peso** do P4 (U2-04).
- Dicas: `assets/conteudo/dicas.json`, lido localmente, então funciona offline (RF18):

```json
[
  { "id": "gato-brincadeira-1", "especie": "gato",
    "texto": "Reserve um momento de brincadeira.",
    "fonte": "pesquisa do projeto", "revisadoEm": "2026-09", "situacao": "em_revisao" }
]
```
  A dica do dia é `dicas_da_especie[diaDoAno % total]`. O grupo escreve as demais com base em `docs/pesquisa.md`. Enquanto não houver revisão profissional, todas ficam como `em_revisao`.

## Telas

### 03 — Atividades (`docs/design/telas/03-atividades.png`)

Tela principal do **pet atual**. Título `Atividades`, subtítulo `Pequenos momentos juntos.`

| Card | Conteúdo | Botão |
|---|---|---|
| Hoje | `PaHistorico` por atividade de hoje: `18:00 • Brincadeira • 10 min`. Vazio: `Nenhuma atividade hoje.` | `secundario` **Editar atividade** → 10 com a mais recente de hoje. Vazio: sem botão |
| Anteriores (card novo, não está no protótipo; P-08) | Últimos 7 dias, uma linha `PaHistorico` por registro: `29 set. • 18:00 • Passeio • 20 min`. Só aparece se houver registros | — |
| Novo momento | `Passeio ou brincadeira, sem GPS.` | `secundario` **Registrar atividade** → 10 em branco |
| Dica para gatos / Dica para cães | `{texto}` / `Conteúdo educativo em revisão.` (se `em_revisao`) / `Fonte: {fonte} • {mês abreviado} {ano}` | — |

### 10 — Passeio ou brincadeira (`10-passeio-ou-brincadeira.png`)

Título `Passeio ou brincadeira`, subtítulo `Um formulário para criar e editar.`
Campos: Tipo (escolha: Passeio / Brincadeira) · Duração (número, exibe `10 minutos`) · Data · Horário.
Texto: `Atividades não mudam a meta de calorias. Elas entram na projeção de peso.` (o protótipo dizia "não descontam calorias da alimentação"; a Unidade II passou a usá-las na projeção).
Botões: `primario` **Salvar atividade**, `perigo` **Excluir registro** (só ao editar) → 23, `secundario` **Voltar**.

### N2 — Lembretes de {nome} (diálogo novo, U2-09)

Aberto pelo card **Lembretes** do Início (P1).
- Título `Lembretes de {nome}`. Subtítulo `Avisos neste aparelho, mesmo com o app fechado.`
- Uma `PaHistorico` por lembrete, em ordem de horário: `08:00 • Refeição` (pausado: `08:00 • Refeição • pausado`). Toque → diálogo **Lembrete** (abaixo).
- Sem lembretes: texto `Nenhum lembrete ainda.` e o botão `primario` **Usar 08:00, 14:00 e 20:00** (exemplo do enunciado; cria três lembretes de refeição).
- Avisos de permissão, quando for o caso:
  - Notificações negadas: `As notificações estão desligadas para o PetAmigo.` + `primario` **Permitir notificações** (pede `POST_NOTIFICATIONS`; se já foi negado de vez, abre as configurações do app).
  - Alarme exato não permitido: `Os avisos podem atrasar alguns minutos.` + `secundario` **Permitir horário exato** (`requestExactAlarmsPermission()`).
- Botões: `primario` **Adicionar lembrete**, `secundario` **Voltar**.

**Lembrete** (diálogo de edição, substitui o N2 e volta para ele ao salvar):
- Campos: Horário (hora, time picker nativo) · Tipo (escolha: Refeição / Pesagem / Atividade) · Ativo (escolha: Sim / Não).
- Botões: `primario` **Salvar lembrete**, `perigo` **Excluir lembrete** (ao editar) → 23, `secundario` **Voltar**.

### 13 — Compartilhar resumo (`13-compartilhar-resumo.png`), agora em PDF (U2-18)

Aberto pelo botão "Compartilhar resumo" da Evolução (P4), sempre para o **pet atual**.
Título `Compartilhar resumo`, subtítulo `Somente quando você solicitar.`
Campos: Início (data, padrão 30 dias atrás) · Fim (data, padrão hoje). Validação: início ≤ fim.
Texto: `Gera um PDF com perfil, meta, indicadores, gráfico, alimentação, atividades, pesagens e lacunas. Revise antes de enviar.`
Botões: `primario` **Abrir compartilhamento** (gera o PDF da R12 e chama o `share_plus`; durante a geração, o botão mostra "Gerando PDF…"), `secundario` **Voltar**.

### 24 — Recurso do aparelho (só no protótipo)

Não é implementada. No app, **Abrir compartilhamento** e **Exportar dados** abrem direto a folha de compartilhamento do Android.

## Lembretes com o app fechado (U2-09)

Camadas (Clean Architecture):
```dart
// domain
abstract interface class AgendadorNotificacoes {
  Future<void> agendarDiario(Lembrete l, {required String nomePet});
  Future<void> cancelar(int notificacaoId);
  Future<void> cancelarTodos();
}
class ReagendarTodos { /* cancela tudo e agenda os lembretes ativos de todos os pets */ }

// data
class AgendadorLocal implements AgendadorNotificacoes { /* flutter_local_notifications */ }
```
- `agendarDiario` usa `zonedSchedule` com `matchDateTimeComponents: DateTimeComponents.time`, `AndroidScheduleMode.exactAllowWhileIdle` (ou `inexactAllowWhileIdle` sem permissão de alarme exato) e `payload: '{petId}|{tipo}'`.
- **Fuso horário**: no `main`, `tz.initializeTimeZones()` e `tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()))`. Sem isso, os avisos saem no horário UTC.
- **`ReagendarTodos`** roda ao abrir o app, depois de restaurar a cópia remota e depois de editar um pet (o nome entra no texto). É idempotente.
- Reinício do celular: os receivers do plugin no `AndroidManifest.xml` reagendam sozinhos.
- Toque na notificação: `onDidReceiveNotificationResponse` (app aberto ou em segundo plano) e `getNotificationAppLaunchDetails()` (app fechado). Os dois trocam o pet atual para o do payload e abrem o diálogo do tipo (06, 11 ou 10), conforme R14.
- Excluir um pet cancela os lembretes dele. A exclusão integral chama `cancelarTodos()`.
- Limite técnico: se o usuário usar **"Forçar parada"** nas configurações do Android, o sistema cancela os alarmes do app até ele ser aberto de novo. Isso é diferente do sistema fechar o app para economizar bateria, caso em que os avisos continuam. Explicar essa diferença na apresentação.

## Gasto de atividade e sugestão S2 (U2-04, U2-11)

- `features/atividades/domain/gasto_atividade.dart`: kcal de uma atividade = `(RER ÷ 24) × (MET − 1) × horas`, com MET de passeio 3,0 e brincadeira 4,0 (M4, P-21).
- `gastoAtividadeProvider(petId)`: média diária de kcal de atividade nos últimos 14 dias, usada pelo P4 na projeção.
- `sugestao_exercicios.dart`: regra S2 de M8. Ação do botão: "Ver atividades" → aba Atividades.

## Geradores de arquivo

```dart
class GeradorPdf {          // R12 (U2-18)
  Future<File> gerar(String petId, DateTime inicio, DateTime fim, DateTime hoje);
}
class GeradorExportacao {   // R13
  Future<File> gerarJson(); // todos os pets
}
```
- O PDF usa o pacote `pdf`, a Inter carregada com `pw.Font.ttf(await rootBundle.load(...))` e `pw.Chart` para o gráfico (pesagens + projeção + curva ideal, com os valores dos providers do P4).
- Os dois leem só do banco local e dos providers. **Nenhum dos dois envia nada para o Firebase.**
- Dias sem registro aparecem no PDF como `sem registros`, nunca como 0 kcal.
- Arquivos temporários (`getTemporaryDirectory()`) são apagados depois de compartilhar.

## Teste oficial T3

`test/lembretes/agendamento_test.dart`, com um `AgendadorNotificacoes` falso que registra as chamadas:
- Criar os 3 lembretes sugeridos (08:00, 14:00, 20:00) para a Luna → 3 agendamentos diários, com ids distintos, horários certos e payload com o `petId` da Luna.
- Pausar um → 1 cancelamento; reativar → 1 agendamento.
- Excluir a Luna → os 3 ids cancelados; os lembretes de outro pet continuam.
- `ReagendarTodos` duas vezes seguidas → mesmo resultado (idempotente).
- Gasto de atividade: brincadeira de 10 min da Luna (RER 247,97) = **5,166 kcal**; duração 0 → bloqueada antes (R05).

## Parte Firebase

- `AtividadeMapeador` e `LembreteMapeador` (com `petId`, `hora`, `tipo`, `ativo`; o `notificacaoId` **não** vai para o Firestore, porque é do aparelho) com testes de ida e volta.
- P3-3.2: `integration_test/sync_atividades_lembretes_test.dart` no Firebase Emulator Suite (configurado pelo P2). **Ida:** criar, editar e excluir uma atividade e um lembrete → motor → ler `usuarios/{uid}/atividades/{id}` e `usuarios/{uid}/lembretes/{id}` com `FirebaseFirestore.instance` e conferir campos, `versao` e `excluido`. **Volta:** gravar um lembrete direto no emulador → pull → conferir o registro local **e** que `ReagendarTodos` agendou a notificação (agendador falso).
- Conferir que gerar e compartilhar o PDF **não cria nada** no Firestore.

## Critérios de aceite

- [ ] Criar, editar e excluir uma atividade, com a lista de hoje atualizada na hora e a projeção do P4 recalculada.
- [ ] Nenhuma tela diz que a atividade "libera" calorias; a meta diária não muda com atividade.
- [ ] A dica aparece no modo avião e muda conforme a espécie do pet atual.
- [ ] Lembrete das 08:00 dispara no horário com o app **fechado pelo sistema**. Testar com `adb shell am kill <pacote>` e com o modo soneca forçado (`adb shell dumpsys deviceidle force-idle`).
- [ ] Toque na notificação de outro pet abre o app nesse pet e no diálogo certo.
- [ ] Depois de reiniciar o emulador, os lembretes continuam agendados.
- [ ] O PDF de um período com dias vazios lista esses dias como `sem registros`, traz meta, indicadores, gráfico e o aviso no rodapé, e abre num leitor de PDF.
- [ ] Sem tocar em "Abrir compartilhamento", nada é gerado nem compartilhado.
- [ ] A exportação gera um JSON válido, com `"formato": 2` e todos os pets, que pode ser lido de volta num teste.
- [ ] Golden test do 03 comparado com o PNG.
- [ ] T3 passa; `sync_atividades_lembretes_test.dart` passa (ida e volta).

## Evidências para guardar

Vídeo ou print da notificação chegando com o app fechado (com o comando `adb` usado); PDF de exemplo (com dados demonstrativos, nunca de pet real); JSON de exportação de exemplo; saída do T3 e do teste de integração; print do Firestore real com uma atividade e um lembrete; hash dos commits.

## Rascunho para a revisão técnica

> Rascunho escrito a partir do que este pacote prevê. **Substitua tudo o que está entre colchetes pelo que aconteceu de verdade** e apague o que você não fez.

**1. Código gerado por IA que precisou ser corrigido**
Usei IA para gerar o agendamento das notificações. O trecho que precisei corrigir foi [colar o trecho real]. [Exemplo do tipo de problema neste pacote: o código usava `zonedSchedule` com `tz.local` sem inicializar o fuso horário do aparelho, então o lembrete das 08:00 chegava às 05:00 (horário UTC); ou usava `Future.delayed`, que morre quando o sistema fecha o app.] Ajustei [inicializando o fuso com o `flutter_timezone` e agendando pelo AlarmManager com `exactAllowWhileIdle`] e conferi [fechando o app com `adb shell am kill` e esperando o aviso chegar].

**2. Conhecimentos da disciplina aplicados**
Usei recursos do sistema operacional móvel: notificações locais, permissões em tempo de execução (notificações no Android 13 e alarme exato no Android 12), o ciclo de vida do app (o sistema pode fechá-lo a qualquer momento) e o compartilhamento nativo. Também usei Clean Architecture, deixando o agendador como uma interface no domínio para poder testar sem o plugin, persistência local e geração de arquivo (PDF). [Ajustar para os nomes da disciplina.]

**3. Solução para a dificuldade**
Em vez de depender do app aberto, passei o agendamento para o próprio Android, com notificações diárias agendadas pelo AlarmManager por meio do `flutter_local_notifications`. Também passei a reagendar tudo ao abrir o app e ao restaurar a cópia remota, e deixei os receivers do plugin reagendarem depois de reiniciar o celular. Verifiquei [fechando o app pelo sistema, forçando o modo soneca com `adb` e reiniciando o emulador: resultado].

**4. Maior dificuldade técnica**
A maior dificuldade foi fazer os lembretes dispararem mesmo com o app fechado pelo sistema para economizar bateria, como o enunciado pede. O Android fecha apps em segundo plano, adia alarmes no modo soneca e, desde o Android 12, exige permissão para alarme exato. Isso apareceu [quando testei o primeiro lembrete e ele não chegou com o app fechado / chegou atrasado / chegou no horário errado].

**5. Uso do Firebase**
No PetAmigo o Firebase é só a cópia remota opcional; o app funciona sem conta, e as notificações são locais, sem Firebase. Eu usei o Cloud Firestore: escrevi o mapeamento das atividades e dos lembretes para documentos em `usuarios/{uid}`, de modo que os lembretes de cada pet sejam restaurados num celular novo, e o teste de integração dessas coleções no Firebase Local Emulator Suite.

**6. Principal contribuição individual**
Fiz a aba Atividades, os lembretes e o relatório em PDF. O resultado é que o tutor registra passeios e brincadeiras sem GPS nem coleira (e eles entram na projeção de peso), recebe avisos nos horários que escolheu para cada pet mesmo com o app fechado, e leva ao veterinário um PDF organizado do período.

**7. Fluxo de dados com o Firebase**
Quando o tutor cria um lembrete, ele é gravado no banco local, agendado no Android e colocado na fila de sincronização. Se a cópia remota estiver ativa, no Wi-Fi o motor de sync usa o meu `LembreteMapeador` para gravar o documento em `usuarios/{uid}/lembretes/{id}`, sem o id da notificação, que é do aparelho. Num celular novo, o pull traz o documento de volta para o banco local, e o `ReagendarTodos` agenda a notificação de novo. Conferi esse caminho com o teste de integração no emulador ([resultado]).

**8. Funcionalidades implementadas**
- Atividades: criar, editar e excluir passeio ou brincadeira, com o gasto estimado usado na projeção de peso.
- Dicas por espécie: conteúdo local com fonte e data de revisão, disponível offline.
- Lembretes por pet: horários definidos pelo tutor, disparando com o app fechado, com o teste automatizado T3.
- Sugestão de aumentar exercícios.
- Resumo em PDF para o veterinário: perfil, meta, indicadores, gráfico, alimentação, atividades, pesagens e lacunas.
- Exportação dos dados em JSON, usada pela tela "Seus dados".
[Apagar ou detalhar.]

**9. O que faria diferente**
Eu faria o lembrete de refeição ser inteligente: se a refeição daquele horário já foi registrada, o aviso não aparece. [Ou outra melhoria real.] Priorizaria isso porque aviso desnecessário faz o tutor desligar as notificações, e aí ele perde justamente os lembretes que ajudam a manter a rotina.

**10. Testes e evidências**
O teste oficial T3 usa um agendador falso para conferir os três horários, a pausa, a exclusão do pet e o reagendamento sem duplicar ([resultado]). Também escrevi o teste de ida e volta dos mapeadores e o teste de integração no Firebase Emulator ([resultado]). Manualmente, testei a notificação com o app fechado pelo sistema (`adb shell am kill`), no modo soneca forçado e depois de reiniciar o emulador, e abri o PDF gerado num leitor. Evidências: [vídeo da notificação, PDF de exemplo, saída dos testes, commits].
