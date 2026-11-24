# Modelos matemáticos (Unidade II)

Todos ficam na camada de **domínio** (Dart puro, sem Flutter nem Firebase) e:
- recebem a data de **`hoje` como parâmetro** (nunca chamam `DateTime.now()` lá dentro), para os testes serem repetíveis;
- devolvem um **resultado selado** (`Disponivel(valor)` ou `Indisponivel(motivo)`) em vez de lançar exceção;
- conferem `isFinite` em todo `double` antes de devolver.

Os parâmetros que o enunciado não define estão marcados com **(P-xx)** e reunidos em `pendencias.md` para confirmar com o professor. Cada um fica numa constante única em `domain/parametros.dart`, para mudar num lugar só.

**Aviso fixo** em toda tela ou PDF que mostre estes números: `Estimativa educativa. Não substitui a avaliação do veterinário.`

---

## M1 — Meta diária de energia (U2-01)

```
RER = 70 × P^0,75           P = peso atual em kg (última pesagem)
MER = RER × fator           (meta diária, kcal/dia)
gramas = MER ÷ densidade × 100      (densidade do rótulo, kcal/100 g)
```

Fator de atividade, avaliado **nesta ordem** (o primeiro que se aplica vale):

| # | Condição | Fator | Origem |
|---|---|---|---|
| 1 | Filhote: `idadeMeses < 12` | 3,0 | Enunciado |
| 2 | `nivelAtividade == alta` | 2,0 | Enunciado ("ativos") |
| 3 | `castrado == true` | 1,6 | Enunciado |
| 4 | Adulto não castrado, atividade baixa ou moderada | 1,8 | **(P-17)**, não definido no enunciado |

Os mesmos fatores valem para cães e gatos, como no enunciado **(P-17)**.

| Caso de teste | Entrada | Saída esperada |
|---|---|---|
| Luna | 5,4 kg, gata adulta castrada, atividade moderada | RER **247,97**; fator 1,6; MER **396,75** → exibe `397 kcal/dia` |
| Conversão | MER 396,75; densidade 360 kcal/100 g | **110,2 g** → exibe `110 g` |
| Filhote | 5,4 kg, 6 meses | fator 3,0 → MER 743,9 |
| Sem pesagem | P = null | `Indisponivel('Registre uma pesagem para calcular a meta.')` |
| Densidade inválida | 0 kcal/100 g | MER disponível; gramas `Indisponivel` |

## M2 — Peso ideal (U2-12)

Prioridade:
1. **Objetivo informado** (`referencias.objetivoKg`, origem veterinário) → usa direto. Rótulo: `(objetivo informado)`.
2. **ECC informado** → estimativa pela escala de 9 pontos (WSAVA, citada em `pesquisa.md`), considerando cerca de 10% de diferença de peso por ponto **(P-18)**:
   ```
   ECC 4 ou 5  → ideal = P
   ECC ≥ 6     → ideal = P ÷ (1 + 0,10 × (ECC − 5))
   ECC ≤ 3     → ideal = P ÷ (1 − 0,10 × (4 − ECC))
   ```
   P = a pesagem **mais próxima da data do ECC**. Rótulo: `(estimado pelo ECC {n})`.
3. Nenhum dos dois → `Indisponivel('Informe o ECC ou o objetivo em Evolução.')`

| ECC (P = 5,4 kg) | 1 | 3 | 4 | 5 | 6 | 7 | 9 |
|---|---|---|---|---|---|---|---|
| Peso ideal (kg) | 7,71 | 6,00 | 5,40 | 5,40 | 4,91 | **4,50** | 3,86 |

## M3 — Curva ideal de 90 dias (U2-03)

Ritmo recomendado: **1% do peso por semana** **(P-19)**, dentro das faixas da diretriz AAHA 2021 citada em `pesquisa.md`.
```
d = 0 (hoje) … 90;  P0 = última pesagem;  Pi = peso ideal (M2)
perda:      ideal(d) = max(Pi, P0 × 0,99^(d/7))
ganho:      ideal(d) = min(Pi, P0 × 1,01^(d/7))
manutenção (|P0 − Pi| ≤ 1% de Pi): ideal(d) = Pi
```
Caso: P0 = 5,4, Pi = 4,5 → `ideal(30) = 5,172`, `ideal(90) = 4,745` (não chega a 4,5 em 90 dias).

## M4 — Projeção adaptativa de 90 dias (U2-04)

Combina o que o **peso realmente fez** com o que a **alimentação e a atividade indicam**. Quanto mais pesagens recentes, mais peso tem a tendência observada. Por isso é "adaptativa".

**a) Tendência observada** (kg/dia): regressão linear (mínimos quadrados) das pesagens dos **últimos 30 dias**.
```
x = dias desde a primeira pesagem da janela; y = kg
Sxx = Σ(x − x̄)²;  Sxy = Σ(x − x̄)(y − ȳ)
obs = Sxy ÷ Sxx        (exige n ≥ 2 e Sxx > 0; senão, obs = null)
```
Ficam **fora da regressão** (mas aparecem no gráfico): a pesagem com `conferida = true` que, comparada com a anterior, passa do limite de 2% do peso por semana (item d). Assim um erro de digitação mantido pelo tutor não distorce a projeção. Pesagens no mesmo dia: vale a última.

**b) Tendência energética** (kg/dia): janela dos **últimos 14 dias**, usando só os dias com registro alimentar (exige pelo menos 3).
```
ingestão  = média de kcal/dia (ração + extras) nos dias com registro
atividade = Σ kcal das atividades na janela ÷ 14
   kcal de uma atividade = (RER ÷ 24) × (MET − 1) × horas
   MET: passeio 3,0; brincadeira 4,0                               (P-21)
gasto     = MER (M1) + atividade
en        = (ingestão − gasto) ÷ 7.700 kcal/kg                     (P-20)
```
Observação: a MER já supõe um nível típico de atividade, então somar a atividade registrada superestima um pouco o gasto. A parte observada (a) corrige isso com o tempo. Vale citar essa simplificação na apresentação.

**c) Combinação**
```
w = min(1, nPesagens30d ÷ 4)
ambos   → kgDia = w × obs + (1 − w) × en
um só   → kgDia = o disponível
nenhum  → Indisponivel('Registre pesagens ou refeições para ver a projeção.')
```

**d) Limite de segurança**: `|kgDia| ≤ 0,02 × P0 ÷ 7` (2% do peso por semana). Se passar, corta no limite e marca `limitada = true`. A tela mostra "projeção limitada ao ritmo máximo seguro".

**e) Curva**: `proj(d) = max(0,1; P0 + kgDia × d)` para d = 0 … 90.

**Caso de teste completo** (`hoje = 30/09/2026`):
- Pesagens: 5,6 (16/09), 5,5 (23/09), 5,4 (30/09).
- Refeições: 120 kcal/dia em 28, 29 e 30/09.
- Atividade: brincadeira de 10 min em 28, 29 e 30/09.

| Etapa | Valor esperado |
|---|---|
| obs | −0,014286 kg/dia |
| kcal de cada brincadeira | 5,166 kcal |
| atividade (média em 14 dias) | 1,107 kcal/dia |
| en | −0,036085 kg/dia |
| w | 0,75 |
| kgDia antes do limite | −0,019736 |
| limite | 0,015429 → **kgDia = −0,015429, limitada = true** |
| proj(30) / proj(90) | 4,937 kg / 4,011 kg |

## M5 — Data prevista (U2-08)

Usa `kgDia` (M4, já limitado), `P0` e `Pi` (M2):

| Condição (nesta ordem) | Resultado |
|---|---|
| Pi indisponível | "Defina o ECC ou o objetivo para estimar." |
| \|P0 − Pi\| ≤ 1% de Pi | "Peso ideal alcançado." |
| kgDia indisponível | "Registre pesagens ou refeições para estimar." |
| \|kgDia\| < 0,000001 **ou** sinal contrário a (Pi − P0) | "Com o ritmo atual, o peso ideal não é alcançado." |
| dias > 365 | "Mais de 1 ano com o ritmo atual." |
| senão | `hoje + dias`, com `dias = ceil(round((Pi − P0) ÷ kgDia, 6))` |

O `round(…, 6)` antes do `ceil` é obrigatório: `(4,5 − 5,4) ÷ −0,014286` dá `63,00000000000002` em ponto flutuante, e sem o arredondamento o `ceil` daria 64 dias.

| Caso | kgDia | Esperado |
|---|---|---|
| Caso completo do M4 | −0,015429 | 59 dias → **28 nov. 2026** |
| Só pesagens (sem refeições) | −0,014286 | 63 dias → **02 dez. 2026** (teste do arredondamento) |
| Peso estável | 0 | "não é alcançado" (sem divisão por zero) |
| Ganhando peso com objetivo de perda | +0,01 | "não é alcançado" |

## M6 — Gráfico interativo: matemática (U2-02, U2-07)

- **Eixo X**: de `hoje − 30` (ou da primeira pesagem, se for mais recente) até `hoje + 90`.
- **Eixo Y**: mínimo e máximo de todas as séries visíveis, com margem de 10%. Se `max == min`: ±0,5 kg (evita divisão por zero no mapeamento).
- **Séries**: histórico (pesagens reais), projeção (M4), curva ideal (M3), linha horizontal do peso ideal (M2).
- **Valor sob o dedo** (dia `x`):
  - dia com pesagem → `30 set. • 5,4 kg (pesagem)`, que é o "peso exato";
  - dia passado sem pesagem → interpolação linear entre as pesagens vizinhas: `27 set. • ≈ 5,44 kg (estimado)`;
  - dia futuro → `15 nov. • Projeção 4,70 kg • Ideal 4,94 kg`.
- **Sem nenhuma pesagem**: não desenha eixo nem linha. Mostra o estado vazio (M10).

## M7 — Percentual de evolução e aderência (U2-12)

**Evolução**
```
Pinicial = primeira pesagem do pet ("peso inicial", editável)
evolucao = (Pinicial − Patual) ÷ (Pinicial − Pi) × 100, limitado a [0, 100]
```
- `|Pinicial − Pi| < 0,01` → "—" com o texto "O peso inicial já era o ideal."
- Resultado acima de 100 (passou do ideal) → mostra 100% e dispara a S3 (M8).
- Caso: 5,6 → 5,4, Pi 4,5 → **18,2%** → exibe `18%`.

**Aderência ao plano alimentar**
```
janela: últimos 14 dias; só dias com registro (dia vazio não conta, RF20)
dia aderente: 0,9 × MER ≤ total do dia ≤ 1,1 × MER
aderencia = aderentes ÷ diasComRegistro × 100
```
- Sem dias com registro → "Sem registros nos últimos 14 dias."
- MER indisponível → "Disponível depois da primeira pesagem."
- Caso (MER 396,75 → faixa 357,1 a 436,4): totais 380, 400, 120, 228, 410, —, 390 → **4 de 6 dias = 67%** → exibe `67% (4 de 6 dias com registro)`.

## M8 — Sugestões e celebrações (U2-11, briefing B-a)

Cada regra é uma função pura que devolve `Sugestao?`. No máximo **2 sugestões** aparecem ao mesmo tempo, na prioridade S3 > S1 > S2. "Agora não" esconde aquela sugestão por 7 dias.

| Regra | Dono | Condição | Texto |
|---|---|---|---|
| S1 Reduzir petiscos | P2 | Em ≥ 3 dos últimos 7 dias com registro, extras > **10%** do total (AAHA/WSAVA, `pesquisa.md`) | "Os petiscos passaram de 10% das calorias em {n} dias. Que tal trocar alguns por um momento de brincadeira?" |
| S2 Aumentar exercícios | P3 | Média de atividade nos últimos 7 dias < **30 min/dia (cão)** ou **15 min/dia (gato)** **(P-21)** e o objetivo é perda (Pi < Patual) | "Mais {falta} minutos de passeio ou brincadeira por dia ajudam {nome}. Veja ideias em Atividades." |
| S3 Mudar objetivo nutricional | P4 | (a) \|Patual − Pi\| ≤ 2% de Pi; **ou** (b) M5 = "não é alcançado" ou > 180 dias, com ≥ 14 dias de dados | (a) "{nome} está perto do peso ideal. Converse com o veterinário sobre passar para manutenção." (b) "Com o ritmo atual, o objetivo está distante. Vale revisar o objetivo com o veterinário." |

**Celebração** (dona: P4): ao salvar uma pesagem, se Pi existe e a distância até Pi **diminuiu pelo menos 100 g** em relação à pesagem anterior:
"{nome} chegou {diferença arredondada a 10 g} g mais perto do peso ideal!"
- Nunca celebrar quando se afasta do ideal. Nunca celebrar sem Pi. Nunca usar culpa ("você esqueceu", "falhou").
- Caso: anterior 5,5, nova 5,4, Pi 4,5 → "Luna chegou 100 g mais perto do peso ideal!"

## M9 — Recálculo em tempo real (U2-05, U2-06)

```
pesagensProvider(petId) ─┐
refeicoesProvider(petId) ─┼─► metaProvider(petId)          (M1)
extrasProvider(petId) ────┤   pesoIdealProvider(petId)      (M2)
atividadesProvider(petId) ┤   curvaIdealProvider(petId)     (M3)
referenciaProvider(petId) ┘   projecaoProvider(petId)       (M4)
                              dataPrevistaProvider(petId)   (M5)
                              indicadoresProvider(petId)    (M7)
                              sugestoesProvider(petId)      (M8)
```
- Os providers de entrada são **streams do drift**. Qualquer gravação (nova refeição, peso editado, peso inicial alterado, atividade registrada) emite um valor novo e recalcula a cadeia **sozinha**, sem "atualizar" manual.
- Os modelos são O(n) e devem levar < 50 ms com 1.000 registros (medir na P2-4.3 e na P4-4.3).

## M10 — Exceções e estados vazios (U2-07)

| Situação | Onde quebraria | Tratamento |
|---|---|---|
| Nenhuma pesagem | M1, M2, M3, M4, M6, M7 | Estado vazio no gráfico: gato sorrindo + "Ainda não há pesagens de {nome}. Registre a primeira para ver o gráfico." + botão `primario` **Registrar peso** |
| Uma pesagem só | regressão (Sxx = 0) | obs = null; o gráfico mostra o ponto; projeção só pela parte energética, se houver |
| Pesagens no mesmo dia | Sxx = 0 | Usa a última do dia; se sobrar uma, igual ao caso anterior |
| Peso ≤ 0 ou absurdo | RER (potência), M4 | Bloqueado na entrada (R05/R06) |
| Densidade ≤ 0 | gramas | Gramas indisponíveis (tela 22) |
| Pinicial == Pi | % evolução | "—" |
| kgDia == 0 | data prevista | "não é alcançado" |
| Menos de 3 dias com registro | parte energética | en = null |
| Nenhum dia com registro | aderência | "Sem registros…" |
| `max == min` no eixo Y | mapeamento do gráfico | ±0,5 kg |
| `NaN`/`Infinity` | qualquer conta | `assert(v.isFinite)` em debug; `Indisponivel` em release |

## Testes oficiais da Unidade II (U2-17)

Cada pacote é dono de **um** dos 5 testes automatizados que o grupo apresenta como oficiais. Todos usam os casos deste arquivo.

| # | Teste | Pacote | Arquivo |
|---|---|---|---|
| T1 | M1: RER, fator e MER da Luna, filhote e sem pesagem | P1 | `test/nutricao/meta_diaria_test.dart` |
| T2 | M7 aderência + S1 petiscos | P2 | `test/diario/aderencia_e_petiscos_test.dart` |
| T3 | Agendamento dos lembretes (3 horários → 3 notificações diárias, ids por pet) + kcal de atividade | P3 | `test/lembretes/agendamento_test.dart` |
| T4 | M4 + M5: caso completo, limite, data prevista e divisão por zero | P4 | `test/evolucao/projecao_test.dart` |
| T5 | Envio em lote: repetir o mesmo lote não duplica; uma falha no lote mantém todos os itens na fila | P5 | `test/sync/lote_test.dart` |
