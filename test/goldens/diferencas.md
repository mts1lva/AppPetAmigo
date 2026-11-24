# Diferenças entre os goldens e os PNGs do protótipo

Comparação lado a lado de `test/goldens/arquivos/*.png` com `docs/design/telas/*.png` (os dois com 780 px de largura, 390 dp a 2x), como pede `design-system.md` → Verificação visual. Cada pacote acrescenta as suas telas aqui.

## 01 Início (P1-1.8, 24/11/2026)

Dados: Luna com foto, 5,4 kg, 30/09/2026 às 09:00, 108 kcal de ração e 12 de petiscos, Ração habitual (360 kcal/100 g).

| Diferença | Motivo |
|---|---|
| Título `Bom dia`, sem o nome do tutor | P-01 |
| Card Hoje: `Total: 120 de 397 kcal` em vez de `Total registrado: 120 kcal` | Unidade II: a meta está ativa (U2-01, R02) |
| Card Referência alimentar com a meta (`Meta de hoje: 397 kcal (≈ 110 g de Ração habitual)`), em 3 linhas, em vez de "Indisponível" | U2-01, R03 |
| Cards Lembretes e Sugestões a mais (abaixo da dobra de 844 dp; Sugestões só aparece com sugestão) | Unidade II (U2-09, U2-11) |
| Texto `corpo` cerca de 1 dp mais alto por linha (altura de linha 1,4 contra cerca de 21,5 dp do Figma), o que desloca os cards de baixo em poucos dp | Token `corpo` de `design-system.md` |

Corrigido nesta comparação: o cabeçalho estava centralizado na faixa de 80 dp; no Figma (`estrutura-page1.xml`), foto, nome e gato ficam alinhados ao topo.

## 05 Dados de Luna (P1-1.8, 24/11/2026)

| Diferença | Motivo |
|---|---|
| Campo **Sexo • Fêmea** a mais; o diálogo rola e "Voltar" fica abaixo da dobra | P-02 |
| `Peso inicial • 5,4 kg` com cerca de 4 dp a mais entre o número e a unidade | Largura do cursor do campo editável (o peso inicial é editável, U2-06) |
| O ponto `•` parece um pouco menor que no PNG | Renderização da Inter no teste contra a do Figma |

Corrigido nesta comparação: o campo de peso mostrava `5,4      kg`, porque a área de digitação tinha largura mínima de 48 dp mesmo com valor. Agora a largura mínima só vale com o campo vazio (`PaCampo`).
