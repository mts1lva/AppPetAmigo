# inicio (P1)

Tela 01 Início, card de sugestões (M8) e diálogos do Início que são do P1.

Camadas (as dependências apontam só para dentro, `docs/specs/comum/arquitetura.md`):

- `apresentacao/` (telas, widgets, providers): Telas, widgets e providers do Riverpod. Chama casos de uso; nunca o drift nem o Firebase direto. Usa só os componentes de `lib/core/ui/`.

Todo provider de dados é `.family` com o `petId` do pet atual.
