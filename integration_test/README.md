# Testes de integração no Firebase Emulator Suite

Os testes em `integration_test/` falam **só** com os emuladores locais de Authentication e Cloud Firestore. Nada vai para o projeto real (`pet-amigo-bac9e`). Sem Cloud Storage (decisão P-23).

## Uma vez na máquina

1. Instale o [Firebase CLI](https://firebase.google.com/docs/cli): `npm install -g firebase-tools`.
2. Confira: `firebase --version`.
3. Não precisa fazer login (`firebase login`) para os emuladores.

## Subir os emuladores

Na raiz do repositório:

```
# Linux / macOS
./emuladores.sh

# Windows
.\emuladores.ps1
```

Os scripts criam `emulador-dados/` (está no `.gitignore`) e rodam:

```
firebase emulators:start --import ./emulador-dados --export-on-exit
```

A interface fica em http://localhost:4000 (Auth na porta **9099**, Firestore na **8080**). Deixe este terminal aberto.

## Rodar os testes

Noutro terminal, com um emulador Android ligado (API 26 ou mais):

```
flutter test integration_test
```

Isso chama `usarEmuladores()` (`apoio_firebase.dart`): no aparelho Android o host é `10.0.2.2` (a máquina vista pelo emulador); no host, `127.0.0.1`. Em seguida `limparEmuladores()` e `criarUsuarioDeTeste(...)`. O build debug/profile permite HTTP claro só para esses testes (API 28+ bloqueia `10.0.2.2` por padrão); o release não.

O teste `emuladores_conexao_test.dart` chama `usarEmuladores()` de verdade (Auth + Firestore). O SDK nativo do Firebase precisa de um aparelho ou emulador Android; o `flutter-tester` não basta.

```
firebase emulators:exec --only auth,firestore --project pet-amigo-bac9e \
  "flutter test integration_test/emuladores_conexao_test.dart"
```

O job **Emuladores Firebase** da CI sobe um AVD API 29 e roda `flutter test integration_test`. Ele não entra no `flutter test` do Windows, que só cobre `test/`.

Os testes de cada coleção (`sync_pet_test.dart`, `sync_diario_test.dart`, …) só passam de ponta a ponta quando o motor de sync do P5 existir (etapa 5). Até lá, o ambiente já sobe e `usarEmuladores()` isola o projeto real.

## Conferir que nada aponta para o projeto real

1. Com os emuladores no ar, abra http://localhost:4000 e veja Auth + Firestore.
2. Rode um teste. Os documentos aparecem **só** na UI local.
3. No console do Firebase (projeto real) não entra documento novo.

Se `usarEmuladores()` não for chamado, o SDK tentaria o projeto real — e falharia de qualquer jeito, porque a rede do Firestore no app fica desligada (`inicializarFirebaseSemRede`).
