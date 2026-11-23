# pets (P1)

Cadastro do pet, vários pets por aparelho e pet atual (U2-10). É o **exemplo de referência** da Clean Architecture para o grupo.

Camadas (as dependências apontam só para dentro, `docs/specs/comum/arquitetura.md`):

- `domain/` (entidades, repositorios, casos_de_uso): Dart puro: entidades, contratos de repositório (interfaces), casos de uso e modelos matemáticos. **Nunca importa Flutter, drift nem Firebase.**
- `data/` (repositorios, mapeadores): Implementa o domínio: repositórios concretos (drift, sempre com `FilaSync.enfileirar` na mesma transação) e mapeadores do Firestore.
- `apresentacao/` (telas, widgets, providers): Telas, widgets e providers do Riverpod. Chama casos de uso; nunca o drift nem o Firebase direto. Usa só os componentes de `lib/core/ui/`.

Todo provider de dados é `.family` com o `petId` do pet atual.
