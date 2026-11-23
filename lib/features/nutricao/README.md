# nutricao (P1)

Meta diária M1: RER, fator de atividade, MER e conversão para gramas (U2-01). Usada pelo diário (P2) e pela projeção (P4).

Camadas (as dependências apontam só para dentro, `docs/specs/comum/arquitetura.md`):

- `domain/` (entidades, repositorios, casos_de_uso): Dart puro: entidades, contratos de repositório (interfaces), casos de uso e modelos matemáticos. **Nunca importa Flutter, drift nem Firebase.**

Todo provider de dados é `.family` com o `petId` do pet atual.
