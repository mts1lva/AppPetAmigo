# Arquitetura

## Plataforma

- **Flutter** estável e **Dart 3**. O alvo é **Android 8.0 ou superior** (`minSdkVersion 26`, RNF07). iOS está fora do escopo desta versão.
- **Offline-first** (U2-15): o app funciona por completo **sem internet e sem conta** (RF14, RNF09). O Firebase só entra quando o tutor ativa a cópia remota (RF15, RF16).
- **Vários pets** por aparelho (U2-10). Todo dado de registro pertence a um `petId`, e as telas mostram sempre o **pet atual**.
- Unidades: no Flutter, 1 pixel lógico corresponde a 1 dp. As medidas do Figma (frame de 390 × 844) valem diretamente como pixels lógicos.

## Dependências

Adicionar com `flutter pub add`, usando a versão estável atual de cada uma. Nenhuma biblioteca além destas sem combinar com o grupo.

| Pacote | Para quê | Quem usa mais |
|---|---|---|
| `flutter_riverpod` | Estado, injeção de dependências e recálculo em tempo real (U2-05, U2-13) | todos |
| `go_router` | Rotas e as 4 abas (`StatefulShellRoute.indexedStack`) | P1 |
| `drift`, `drift_flutter` (+ `drift_dev`, `build_runner` em dev) | Banco SQLite local, transações e streams reativos | todos |
| `uuid` | IDs estáveis (v4), gerados no aparelho e reutilizados no Firestore | todos |
| `intl` + `flutter_localizations` | Datas e números em pt-BR | todos |
| `flutter_svg` | Gato sorrindo (`assets/img/gato_sorrindo.svg`) | P1 |
| `image_picker`, `path_provider` | Escolher a foto e copiá-la para a área privada do app | P1 |
| `flutter_local_notifications`, `timezone`, `flutter_timezone` | Lembretes locais agendados, inclusive com o app fechado (U2-09) | P3 |
| `pdf` | Gerar o resumo em PDF para o veterinário (U2-18) | P3 |
| `share_plus` | Seletor nativo de compartilhamento (PDF e exportação) | P3 |
| `connectivity_plus` | Saber se a conexão atual é Wi-Fi | P5 |
| `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` | Cópia remota opcional | P1 (core), P5 (resto) |

O gráfico é feito com `CustomPainter` + `GestureDetector`, sem biblioteca de gráficos (briefing: "gráficos leves"; RNF07).

## Clean Architecture (U2-14)

Cada funcionalidade é dividida em três camadas. **A dependência só aponta para dentro**: a apresentação conhece o domínio, os dados implementam o domínio, e o domínio não conhece ninguém.

```
┌──────────────────────── apresentacao ────────────────────────┐
│ telas, widgets, providers (Riverpod)                          │
│ chamam casos de uso; nunca o drift nem o Firebase direto      │
└───────────────┬──────────────────────────────────────────────┘
                ▼
┌──────────────────────────── domain ──────────────────────────┐
│ entidades (Pet, Refeicao, Pesagem…), contratos de repositório │
│ (interfaces), casos de uso e modelos matemáticos (M1–M10)     │
│ Dart puro: sem Flutter, sem drift, sem Firebase               │
└───────────────▲──────────────────────────────────────────────┘
                │ implementa
┌──────────────────────────── data ────────────────────────────┐
│ repositórios concretos (drift), DAOs, mapeadores Firestore    │
└──────────────────────────────────────────────────────────────┘
```

- **Casos de uso** são classes pequenas com um método `call`, ex.: `RegistrarRefeicao`, `CalcularMetaDiaria`, `ProjetarPeso`, `AgendarLembretes`.
- **Injeção**: providers do Riverpod criam as implementações (`refeicaoRepositorioProvider`). Nos testes, `ProviderScope(overrides: […])` troca por falsos.
- O `FilaSync` e o motor de sync ficam em `core/sync`, porque são infraestrutura usada por todas as funcionalidades.

Regras de ouro:
1. **A confirmação de salvamento só aparece depois que a transação do drift terminar** (RF14). Nada de UI otimista para gravação.
2. **Toda gravação de registro chama `FilaSync.enfileirar` na mesma transação** (`dados-e-sync.md`). Se a cópia remota estiver desligada, a fila ignora a chamada.
3. **Domínio não importa Flutter, drift nem Firebase.** Assim as regras e os modelos podem ser testados com `dart test`.
4. **Todo provider de dados recebe o `petId`** (`.family`), para cada pet ter histórico, metas, gráfico e lembretes próprios.

## Estrutura de pastas

```
lib/
├── main.dart                         inicializa drift, fuso horário, notificações, Firebase (sem rede) e ProviderScope
├── app/
│   ├── app.dart                      MaterialApp.router, tema, locale pt_BR
│   ├── router.dart                   rotas e shell das 4 abas
│   └── tema/                         cores, espacos, tipografia, tema
├── core/
│   ├── ui/                           os 7 componentes + confirmarExclusao (design-system.md)
│   ├── formato/                      datas, numeros (R10)
│   ├── resultado.dart                Disponivel / Indisponivel (modelos-matematicos.md)
│   ├── banco/                        database.dart (todas as tabelas), daos/
│   └── sync/                         fila_sync, motor_sync, wifi, firebase_remoto
└── features/
    ├── pets/            P1   domain/ data/ apresentacao/   (cadastro, vários pets, pet atual)
    ├── nutricao/        P1   domain/                       (M1: RER, fator, MER, gramas)
    ├── inicio/          P1   apresentacao/                 (tela Início, card de sugestões)
    ├── diario/          P2   domain/ data/ apresentacao/   (refeições, petiscos, alimentos, aderência, S1)
    ├── atividades/      P3   domain/ data/ apresentacao/   (atividades, dicas, kcal de atividade, S2)
    ├── lembretes/       P3   domain/ data/ apresentacao/   (notificações locais)
    ├── relatorio/       P3   domain/ data/                 (resumo em PDF, exportação JSON)
    ├── evolucao/        P4   domain/ data/ apresentacao/   (pesagens, M2–M8, gráfico interativo)
    └── privacidade/     P5   domain/ data/ apresentacao/   (cópia remota, exclusão integral)
    (cada pasta: domain/{entidades,repositorios,casos_de_uso}, data/{repositorios,mapeadores}, apresentacao/{telas,widgets,providers})
assets/
├── fonts/Inter-*.ttf                 fonte empacotada (licença OFL)
├── img/gato_sorrindo.svg
└── conteudo/dicas.json               dicas por espécie (RF18)
test/                                 espelha lib/
integration_test/                     testes no Firebase Emulator (P3 prepara)
```

Onde um pacote cita um caminho antigo (`domain/energia.dart`, `data/repos/…`, `data/sync/…`), vale este mapeamento:

| Caminho antigo | Caminho na Clean Architecture |
|---|---|
| `domain/energia.dart`, `domain/resumo_dia.dart` | `features/diario/domain/…` (a meta M1 fica em `features/nutricao/domain/`) |
| `domain/pesagem.dart` | `features/evolucao/domain/…` |
| `domain/referencia_nrc.dart` | `features/nutricao/domain/meta_diaria.dart` |
| `data/repos/<x>_repo.dart` | `features/<funcionalidade>/data/repositorios/` (interface em `domain/repositorios/`) |
| `data/sync/mapeadores/` | `features/<funcionalidade>/data/mapeadores/` |
| `data/sync/fila_sync.dart` etc. | `core/sync/` |
| `data/local/database.dart` | `core/banco/database.dart` |

## Lembretes com o app fechado (U2-09)

- `flutter_local_notifications` com `zonedSchedule(..., matchDateTimeComponents: DateTimeComponents.time)`: o Android (AlarmManager) dispara todo dia no horário, **sem o app estar aberto**.
- Modo `AndroidScheduleMode.exactAllowWhileIdle` quando a permissão de alarme exato for concedida; senão, `inexactAllowWhileIdle`, com o aviso "pode atrasar alguns minutos".
- `AndroidManifest.xml`: `POST_NOTIFICATIONS` (Android 13+), `SCHEDULE_EXACT_ALARM` (Android 12+), `RECEIVE_BOOT_COMPLETED` e os receivers do plugin, que reagendam depois de reiniciar o celular.
- Gradle: `coreLibraryDesugaringEnabled true`, exigido pelo plugin.
- Detalhes e textos em `pacote-3`.

## Firebase

### O que é (resumo para o grupo)

O Firebase é uma plataforma do Google com serviços prontos de nuvem para apps, sem que a equipe precise criar ou manter um servidor. O PetAmigo usa três:

| Serviço | O que faz | Uso no PetAmigo |
|---|---|---|
| **Authentication** | Login de usuários | E-mail e senha do tutor que ativa a cópia remota |
| **Cloud Firestore** | Banco de dados na nuvem (coleções e documentos) | Cópia dos registros em `usuarios/{uid}/…` |
| **Cloud Storage** | Armazenamento de arquivos | Fotos dos pets |

Em desenvolvimento, o **Firebase Local Emulator Suite** roda esses três serviços no computador, para testar sem mexer no projeto real.

**O Firebase não é o banco do app.** O banco principal é o SQLite no celular (offline-first). O Firebase guarda só uma **cópia remota opcional**, enviada **em lotes e apenas pelo Wi-Fi** quando o tutor ativa essa opção. Ela serve para não perder dados ao trocar de celular e para usar o app em mais de um aparelho.

### Configuração

- Um projeto Firebase do grupo, configurado com `flutterfire configure`, que gera `lib/firebase_options.dart`. Região do Firestore e do Storage: **`southamerica-east1`** (São Paulo).
- Serviços usados: **Authentication (e-mail/senha)**, **Cloud Firestore** e **Cloud Storage**. Nenhum outro: sem Analytics nem Crashlytics, pela minimização de dados (RNF04). As notificações são **locais** e não usam o Firebase Cloud Messaging.
- Em desenvolvimento: **Firebase Local Emulator Suite** (Auth, Firestore, Storage), configurado pelo P2. Todos os testes de sincronização rodam nele (`integration_test/`, pacote `integration_test` do SDK); o projeto real só é usado para a conferência final (Todos-3.7).
- **Persistência offline do Firestore desligada** (`Settings(persistenceEnabled: false)`) e **rede do Firestore desligada por padrão** (`disableNetwork()` logo após a inicialização). O motor de sync só chama `enableNetwork()` enquanto há Wi-Fi. Detalhes em `dados-e-sync.md`.
  Motivo: com o cache ligado, o SDK reenvia gravações pendentes sozinho assim que houver qualquer rede, inclusive dados móveis, o que viola RF15/RNF09.
- Configuração da cópia remota (auth, regras, envio em lote, exclusão): pacote 5. Inicialização e Storage da foto: pacote 1.

## Desempenho (RNF06)

Meta: em Android 8.0 com 2 GB de RAM e 1.000 registros, salvar em até 1 s e abrir o resumo ou o gráfico em até 2 s, em pelo menos 95% de 20 execuções. Os modelos matemáticos (M1–M8) devem levar menos de 50 ms.
- Índices no drift em `dataHora` e `petId`.
- As consultas filtram pelo pet e pelo intervalo de datas, nunca carregam tudo.
- Medir em modo `--profile` num aparelho real e registrar os resultados (evidência para a revisão).

## Privacidade e segurança (RNF04, RNF05)

- Banco e fotos na área privada do app (`getApplicationDocumentsDirectory`).
- Logs (`debugPrint`/`log`) nunca imprimem nome do pet, foto, e-mail ou valores de registros em build de release.
- Senha nunca é gravada. O app guarda apenas o `uid` do Firebase.
- O texto das notificações mostra só o nome do pet e o tipo de lembrete, nunca pesos ou calorias (a tela de bloqueio é pública).
