# relatorio (P3)

Resumo em PDF para o veterinário (R12, U2-18) e exportação JSON (R13).

Camadas (as dependências apontam só para dentro, `docs/specs/comum/arquitetura.md`):

- `domain/` (entidades, repositorios, casos_de_uso): Dart puro: entidades, contratos de repositório (interfaces), casos de uso e modelos matemáticos. **Nunca importa Flutter, drift nem Firebase.**
- `data/` (repositorios, mapeadores): Implementa o domínio: repositórios concretos (drift, sempre com `FilaSync.enfileirar` na mesma transação) e mapeadores do Firestore.

Todo provider de dados é `.family` com o `petId` do pet atual.
