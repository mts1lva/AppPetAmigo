# Regras de domínio

Ficam na camada `domain` de cada funcionalidade (`arquitetura.md` → Clean Architecture), em Dart puro, cada uma com testes unitários. Os **modelos matemáticos da Unidade II** (meta diária, peso ideal, curvas, projeção, data prevista, indicadores e sugestões) estão em `modelos-matematicos.md` (M1–M10). Este arquivo cita esses modelos pelo código.

As regras marcadas **(P-xx)** não vêm dos requisitos nem do enunciado: são decisões técnicas registradas em `pendencias.md`. São limites para pegar erro de digitação e organizar a interface, **nunca critérios clínicos**.

Todas as regras valem **por pet**: recebem o `petId` (ou os registros já filtrados por ele) e a data de `hoje`.

## R01 — Energia da refeição

```
energiaKcal = quantidadeG × densidadeKcalPor100g / 100
```
- Exemplo do protótipo: 30 g × 360 kcal/100 g = **108 kcal**.
- Guarda `double`; mostra arredondado para inteiro ("108 kcal").
- A densidade usada fica copiada na refeição. Ao editar a quantidade, o recálculo usa **a densidade salva na refeição**, não a atual do alimento (`requisitos.md`, exemplo de CRUD).

**Petisco cadastrado (P-32):** `energiaKcal = unidades × kcalPorUnidade`. Ex.: 2 unidades × 3 kcal = **6 kcal**. O nome e a energia ficam copiados no extra; ao editar as unidades, o recálculo usa a energia por unidade da cópia (`energiaKcal ÷ unidades`), não a atual do petisco.

## R02 — Resumo do dia e comparação com a meta

Para o dia D (00:00 a 23:59 no fuso do aparelho):
```
racao  = Σ energiaKcal das refeições de D
extras = Σ energiaKcal dos extras de D
total  = racao + extras
parcelaExtras = total > 0 ? round(extras / total × 100) : —
meta   = MER (M1)
```
| Onde | Com meta disponível | Sem meta (sem pesagem) |
|---|---|---|
| Início, card "Hoje" | `Ração 108 kcal • Petiscos 12 kcal` / `Total: 120 de 397 kcal` | `… / Total registrado: 120 kcal` |
| Diário, card "Resumo do dia" | `120 de 397 kcal • Petiscos 10% dos registros` / `Faltam 277 kcal para a meta de hoje.` (acima da meta: `23 kcal acima da meta de hoje.`; igual à meta: só a primeira linha, P-30) | `120 kcal • Petiscos 10% dos registros` / `Registre uma pesagem para ver a meta.` |

- Nenhum texto usa culpa nem cor de alerta por estar acima ou abaixo da meta. A sugestão sobre petiscos é a S1 (M8), não um aviso no resumo.

## R03 — Meta diária (NRC) — U2-01

- Cálculo em **M1** (`modelos-matematicos.md`): `MER = 70 × P^0,75 × fator`.
- Card "Referência alimentar" do Início (título mantido do protótipo):
  `Meta de hoje: 397 kcal (≈ 110 g de Ração habitual)` / `RER × 1,6 (castrada). Estimativa educativa.`
  Sem pesagem: `Registre uma pesagem para calcular a meta.`
- Tela 18 passa a explicar o cálculo (título `Como a meta é calculada`), em `pacote-1`.

## R04 — Conversão para gramas — U2-01

`gramas = MER ÷ densidade × 100` (M1), com o alimento do atalho. Exibir arredondado ao grama, sempre com "≈". A conversão é uma referência, **não uma prescrição** (texto da tela 06 mantido).

## R05 — Validações

| Campo | Regra | Mensagem |
|---|---|---|
| Nome do pet | obrigatório, 1–40 caracteres | "Informe o nome." |
| Espécie | `cao` ou `gato` | — (escolha obrigatória) |
| Sexo | `macho` ou `femea` (P-02) | — (escolha obrigatória) |
| Idade | anos (0–30) + meses (0–11); total ≥ 1 mês (P-10) | "Informe a idade." |
| Peso / pesagem | > 0 e ≤ 150 kg (P-10) | "O valor precisa ser positivo." / "Confira o valor: acima de 150 kg." |
| Densidade | > 0 | Abre a tela 22 "Confira a densidade" |
| Quantidade (g) | > 0 | "A quantidade precisa ser positiva." |
| Energia do extra | > 0 | "Informe a energia em kcal." |
| Energia por unidade do petisco (P-32) | > 0 | "Informe a energia por unidade." |
| Unidades (petisco cadastrado e unidades habituais, P-32) | inteiro > 0 | "Informe um número inteiro de unidades." |
| Duração | inteiro > 0, ≤ 600 min (P-10) | "Informe a duração em minutos." |
| Data/hora de registro | não pode ser futura (P-10) | "Escolha uma data até hoje." |
| ECC | inteiro de 1 a 9 ou vazio (P-03) | — (escolha) |
| Objetivo (kg) | vazio ou > 0 e ≤ 150 | "O valor precisa ser positivo." |
| Horário de lembrete | 00:00–23:59, sem repetir horário do mesmo tipo no mesmo pet | "Já existe um lembrete nesse horário." |

Erro aparece no `PaCampo` (borda `erro` e mensagem embaixo). O botão de salvar continua habilitado e, ao tocar, leva o foco ao primeiro campo com erro.

Se a gravação no banco falhar (não é erro de validação), o diálogo continua aberto com os dados e mostra `Não foi possível salvar. Tente novamente.` (P-29).

## R06 — Pesagem suspeita (técnica, não clínica; P-10)

Compara com a pesagem anterior mais próxima no tempo (`anterior`):
```
razao = novo / anterior
suspeita  se razao ≥ 1,5  ou  razao ≤ 0,67
sugestão  se 8 ≤ razao ≤ 12   → "Corrigir para {novo / 10} kg"
          se 0,08 ≤ razao ≤ 0,125 → "Corrigir para {novo × 10} kg"
```
- Suspeita: em vez de salvar direto, abre **25 Conferir pesagem** com o campo em estado de erro e o texto "Anterior: X kg. Confira unidade e separador decimal…".
- "Corrigir para …" salva o valor sugerido. "Manter valor informado" salva o valor digitado com `conferida = true`. **Nada é descartado em silêncio** (RF09).
- Sem pesagem anterior, não há verificação.
- Vale também para a edição do **peso inicial** (U2-06), comparando com a pesagem seguinte.

## R07 — Gráfico de evolução — U2-02, U2-03, U2-04, U2-07

- Matemática em **M3, M4 e M6**; visual em `design-system.md` → Gráfico interativo; tela em `pacote-4`.
- Sem pesagens: estado vazio (M10), nunca desenhar zero.
- 1 pesagem: só o ponto do histórico; projeção e ideal aparecem se houver dados para eles.
- **Texto alternativo** obrigatório embaixo do gráfico (RNF02), em `legenda`:
  `16 set. 5,6 kg → 23 set. 5,5 kg → 30 set. 5,4 kg` /
  `Peso ideal 4,5 kg • Projeção para 29 dez.: 4,0 kg` /
  `Previsão para o peso ideal: 28 nov. 2026` (texto de M5).
- Lacuna de mais de 14 dias entre pesagens: acrescenta "Sem pesagens entre {d1} e {d2}." (F06).

## R08 — Mensagens de progresso e celebrações — RF19, briefing B-a

- Depois de salvar uma refeição (tela 20): `Salva neste aparelho.` + `O diário passa de {antes} para {depois} kcal. Ração {r} kcal • Petiscos {p} kcal. Continue no seu ritmo.`
- Depois de salvar uma pesagem: celebração de M8 quando o pet se aproxima ≥ 100 g do peso ideal ("Luna chegou 100 g mais perto do peso ideal!").
- **Nunca** celebrar sem peso ideal definido nem quando o pet se afasta dele. A frase do card "Acompanhar" do protótipo continua: `Uma mudança não define melhora.`
- Proibido: "Você esqueceu de registrar", contagem de sequência perdida, vermelho por "excesso", comparação entre pets.

## R09 — Dias sem registro (RF20)

- `Sem registros nesta data. Ausência de dados não significa consumo zero.`
- Botão `Retomar registro hoje` → volta o Diário para hoje.
- Não pedir preenchimento retroativo e não mostrar "0 kcal" para dia vazio: mostrar "—" ou o texto acima. Dias vazios **não entram** na aderência (M7) nem na média de ingestão da projeção (M4).

## R10 — Formatos (pt-BR, `intl`)

| Dado | Formato | Exemplo |
|---|---|---|
| Data curta | dia + mês abreviado + ano | `30 set. 2026` |
| Data no cabeçalho do Diário | dia + mês por extenso + ano | `30 setembro 2026` |
| Data no card do Início | `Hoje · {dia} {mês abreviado}` | `Hoje · 30 set.` |
| Hora | `HH:mm` | `08:00` |
| Peso | 1 casa decimal, vírgula (2 casas no gráfico interativo) | `5,4 kg` / `≈ 5,44 kg` |
| Energia | inteiro | `108 kcal` |
| Percentual | inteiro + `%` | `18%` |
| Entrada numérica | aceita `5,4` e `5.4` | — |

Chamar `initializeDateFormatting('pt_BR')` no `main`. Conferir as abreviações geradas pelo `intl` contra o protótipo ("set.") num teste.

## R11 — Saudação, pet atual e cabeçalho — U2-10

- `Bom dia` (05:00–11:59), `Boa tarde` (12:00–17:59), `Boa noite` (18:00–04:59). **Só a saudação, sem nome** (P-01).
- **Pet atual**: todas as telas mostram os dados do pet escolhido em `config.petAtualId`. Trocar de pet no Início troca as 4 abas.
- Espécie conforme o sexo (P-02):

| Espécie | Macho | Fêmea |
|---|---|---|
| `gato` | Gato | Gata |
| `cao` | Cão | Cadela |

  Castração: `castrado` / `castrada`; se não castrado(a): `não castrado` / `não castrada`.
- Linha do pet: `{nome}` / `{Espécie} • {idade}`. Idade: `{n} meses` (abaixo de 1 ano), `1 ano`, `{n} anos`. Idade atual = `idadeMeses + meses completos desde idadeInformadaEm`. Filhote (< 12 meses) aparece como `Gata filhote • 6 meses`.
- Sem foto (P-14): círculo `suave` de 64 com a inicial do nome em `secao`.
- Peso exibido no perfil: a **última pesagem**. Sem pesagem, `peso não informado`.

## R12 — Resumo em PDF para o veterinário — U2-18

Gerado no aparelho com o pacote `pdf`, para **um pet** e um período [início, fim]. Página A4, Inter, cores do design system em tons de cinza e verde (imprime bem em preto e branco).
1. Cabeçalho: "PetAmigo • Resumo para consulta", nome do pet, período e data de geração.
2. Perfil: espécie, sexo, idade, castração, nível de atividade.
3. **Indicadores** (M7): peso atual, peso ideal (com a origem), % de evolução, aderência ao plano.
4. **Meta diária** (M1): RER, fator, MER e a fórmula escrita.
5. **Gráfico** (`pw.Chart`): pesagens do período + projeção de 90 dias + curva ideal, com legenda em texto.
6. **Data prevista** (M5) e se a projeção foi limitada.
7. Alimentação por dia: ração, extras, total e meta. Dias sem registro aparecem como "sem registros" (lacuna), nunca como 0.
8. Atividades: data, tipo, duração e kcal estimadas.
9. Pesagens: data e peso, com "(valor conferido pelo tutor)" quando `conferida`.
10. ECC/objetivo e origem.
11. Rodapé em todas as páginas: "Estimativa educativa gerada pelo PetAmigo. Não substitui a avaliação do veterinário."

Abre o `share_plus` com o arquivo `.pdf` **somente** depois do toque em "Abrir compartilhamento". Nada é enviado automaticamente. O arquivo temporário é apagado em seguida.

## R13 — Exportação de dados (RF16, RNF05)

Arquivo JSON com todas as tabelas de domínio de **todos os pets** (sem as colunas de controle de sync) e versão do formato (`"formato": 2`), compartilhado pelo `share_plus`. As fotos não vão junto, para reduzir tamanho e exposição (P-15).

## R14 — Lembretes (notificações locais) — U2-09

- Título: `{tipo} de {nome}` → `Hora da refeição de Luna`, `Hora de pesar Luna`, `Hora de brincar com Luna`.
- Corpo: `Toque para registrar.` **Nunca** mostra peso, calorias ou meta (a tela de bloqueio é pública).
- Toque na notificação: abre o app **no pet do lembrete** (payload `petId`) e direto no diálogo de registro do tipo (06, 11 ou 10).
- Horários sugeridos ao criar o primeiro lembrete de refeição: 08:00, 14:00 e 20:00 (exemplo do enunciado), todos editáveis.
