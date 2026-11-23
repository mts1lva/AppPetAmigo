# Pacote 4 — Evolução, projeção e gráfico interativo

**Responsável:** ______________________

## Objetivo

Entregar a aba **Evolução** com a matemática da Unidade II: peso ideal, curva ideal de 90 dias, **projeção adaptativa** de 90 dias, **data prevista**, percentual de evolução e **gráfico interativo**, além das pesagens com conferência de valores suspeitos e do ECC/objetivo informados pelo veterinário. Tudo recalculado em tempo real e sem culpar o tutor.

**Requisitos:** RF09, RF10, RF11, RF19, RNF02 (gráfico não depende de cor), RNF06, RNF07 (gráfico leve), RNF11, RNF12 · **Unidade II:** U2-02, U2-03, U2-04, U2-05, U2-06 (peso inicial), U2-07, U2-08, U2-11 (S3), U2-12, briefing B-a (celebração), teste oficial T4.
**Depende de:** P1 (base, `metaProvider` de M1). Lê `aderenciaProvider` e a ingestão diária do P2 e o `gastoAtividadeProvider` do P3, que já existem quando chega a sua vez (**etapa 4** do `plano-de-execucao.md`). **Entrega para:** P1 (`ultimaPesagemProvider`, regra S3 para o card de sugestões), P3 (valores das curvas para o gráfico do PDF).

Observação: a primeira pesagem, criada junto com o pet, é inserida pelo P1 direto na tabela `pesagens`. Ela é o **peso inicial** (M7) e precisa aparecer normalmente na Evolução, no gráfico e na conferência de variação.

**Ordem de execução:** tarefas `P4-0.x` → `P4-1.x` → `P4-2.x` → `P4-3.x` → `P4-4.x` do `plano-de-execucao.md`. Comece pelos modelos M2 a M8 em Dart puro (Fase 0), com os casos de teste de `modelos-matematicos.md`. Eles são o coração deste pacote.

## Dados e regras

- Tabelas `pesagens` (`petId`, `pesoKg`, `dataHora`, `conferida`) e `referencias` (`petId`, `ecc`, `objetivoKg`, `origem`, `data`; uma linha vigente por pet).
- Regras: R05, R06 (pesagem suspeita), R07 (gráfico), R08 (celebração), R10; **modelos M2 a M8 e M10** em `comum/modelos-matematicos.md`.
- **Remover referências não apaga pesagens** (RF10).
- Escala do ECC (P-03): **1 a 9, da WSAVA**. Com o ECC, o app **estima o peso ideal** (M2), sempre com o rótulo "(estimado pelo ECC n)" e o aviso de estimativa educativa. Um objetivo informado pelo veterinário tem prioridade.

### Domínio (`features/evolucao/domain/`)

| Arquivo | Conteúdo |
|---|---|
| `peso_ideal.dart` | M2 |
| `curva_ideal.dart` | M3 |
| `projecao.dart` | M4 (regressão, parte energética, combinação, limite) |
| `data_prevista.dart` | M5 (com o `round(…, 6)` antes do `ceil`) |
| `grafico_dados.dart` | M6 (domínio X/Y, interpolação, texto sob o dedo) |
| `indicadores.dart` | M7 (evolução); a aderência vem do P2 |
| `sugestao_objetivo.dart` e `celebracao.dart` | M8 (S3 e celebração) |

Providers: os de M9 (`pesoIdealProvider`, `curvaIdealProvider`, `projecaoProvider`, `dataPrevistaProvider`, `indicadoresProvider`), todos `.family` por `petId`, montados sobre os streams do drift. **Nenhum botão "atualizar"**: nova refeição, peso editado ou atividade registrada recalculam tudo sozinhos.

## Telas

### 04 — Evolução (`docs/design/telas/04-evolucao.png`)

Tela principal do **pet atual**. Título `Evolução`, subtítulo `Peso é uma parte do acompanhamento.`

| Card | Conteúdo | Botão |
|---|---|---|
| Gráfico (`destaque`, sem título) | **Gráfico interativo** de 180 de altura (`design-system.md` → Gráfico interativo) + legenda + texto alternativo (R07). Sem pesagens: estado vazio (M10) | No estado vazio: `primario` **Registrar peso** → 11 |
| **Indicadores** (novo, `padrao`) | `Peso atual • 5,4 kg` / `Peso ideal • 4,5 kg (estimado pelo ECC 7)` / `Evolução • 18% do caminho` / `Aderência ao plano • 67% (4 de 6 dias com registro)` / `Previsão • 28 nov. 2026` (ou o texto de M5). Linha `legenda`: `Estimativa educativa. Não substitui a avaliação do veterinário.` | — |
| Última pesagem | `{peso} • {data}` / `Anterior: {peso} • {data curta sem ano}`. Sem pesagem: `Nenhuma pesagem registrada.` | `secundario` **Editar pesagem** → 11 com a última. Sem pesagem: sem botão |
| Pesagens anteriores (card novo; P-08) | `PaHistorico` por pesagem, da mais recente para a mais antiga (exceto as duas acima), até 10 + "Ver mais". A **primeira de todas** termina com ` • peso inicial`. Só aparece com 3 ou mais pesagens | — |
| Acompanhar | `Uma mudança não define melhora.` | `secundario` **Registrar peso** → 11 em branco |
| ECC e objetivo | `ECC {"7 de 9" ou "não informado"} • Objetivo {x kg ou "não informado"}`. Se houver: `Informado por {origem} em {data}.` | `secundario` **Atualizar referências** → 12 |
| Resumo para consulta | `Você escolhe quando compartilhar.` | `secundario` **Compartilhar resumo** → 13 (diálogo do P3, gera PDF) |

Sem peso ideal (sem ECC nem objetivo), o card Indicadores mostra `Peso ideal • Informe o ECC ou o objetivo` e as linhas Evolução e Previsão com o texto correspondente de M5/M7. A curva ideal e a linha do peso ideal não aparecem; a projeção aparece mesmo assim.

#### Gráfico interativo (U2-02)

- `CustomPainter` + `GestureDetector`, sem biblioteca (gráficos leves). A pintura recebe um objeto pronto de `grafico_dados.dart` (pontos já mapeados), então o painter **não faz conta** e pode ser testado com golden.
- Séries, estilos, balão e acessibilidade: `design-system.md` → Gráfico interativo.
- Arrastar o dedo mostra o valor do dia (M6): pesagem exata, estimativa interpolada (passado) ou projeção e ideal (futuro).
- O gráfico é refeito em menos de 1 frame quando chega um valor novo do provider (U2-05). Medir na P4-4.3.

### 11 — Pesagem (`11-pesagem.png`)

Título `Pesagem`, subtítulo `Valores positivos em quilogramas.`
Campos: Peso (número, kg, aceita vírgula) · Data · Horário.
Texto: `Variações suspeitas exigem conferência; o registro não é descartado silenciosamente.`
Botões: `primario` **Salvar peso**, `perigo` **Excluir registro** (só ao editar; **não aparece no peso inicial**, que só pode ser editado) → 23, `secundario` **Voltar**.
- O botão "Conferir variação" do protótipo **não existe no app**. O 25 aparece sozinho ao salvar, quando R06 detecta suspeita.
- Editar o **peso inicial** (U2-06) usa este mesmo diálogo, com o título `Peso inicial`.
- Depois de salvar: se M8 indicar celebração → **N3**; senão, fecha.

### N3 — Pesagem salva (diálogo novo, celebração)

Mesmo layout da tela 20 (Refeição salva). Título `Pesagem salva`, subtítulo `Salva neste aparelho.`, gato sorrindo de 64 e o texto de M8: `Luna chegou 100 g mais perto do peso ideal!` / `Continue no seu ritmo.` Botões: `primario` **Ver evolução** (fecha e rola até o gráfico), `secundario` **Voltar**.

### 25 — Conferir pesagem (`25-conferir-pesagem.png`)

Título `Conferir pesagem`, subtítulo `Valor fora do esperado.` (o "no exemplo" do protótipo sai).
Campo `Peso informado • {valor} kg` em **estado de erro**, somente leitura.
Texto: `Anterior: {anterior} kg. Confira unidade e separador decimal. Corrija ou mantenha o valor; nenhum dado será descartado silenciosamente.`
Botões:
- `primario` **Corrigir para {sugestão} kg**, se R06 tiver sugestão. Senão, `primario` **Corrigir valor**, que volta ao 11 com foco no peso.
- `primario` **Manter valor informado**: salva com `conferida = true`. Uma pesagem conferida entra no gráfico, mas **fica fora da regressão** de M4 se estiver fora do limite de 2%/semana, para um erro de digitação mantido não distorcer a projeção.
- `secundario` **Voltar**: volta ao 11 sem salvar.

### 12 — ECC e objetivo (`12-ecc-e-objetivo.png`)

Título `ECC e objetivo`, subtítulo `Informações orientadas pelo veterinário.`
Campos: ECC informado (escolha: `Não informado`, `1` a `9`; exibe `7 de 9`) · Objetivo (kg) (número, opcional) · Origem (escolha: `Veterinário / consulta`, `Outro profissional`, `Tutor`; P-13) · Data.
Texto: `ECC é o escore de condição corporal. Precisa de avaliação profissional; peso isolado não diagnostica.` + linha nova, quando houver ECC e não houver objetivo: `Peso ideal estimado pelo ECC: 4,5 kg.`
Botões: `primario` **Salvar referências**, `primario` **Remover referências** (→ 23; apaga só a referência), `secundario` **Voltar**.

## Teste oficial T4

`test/evolucao/projecao_test.dart`, com `hoje = 30/09/2026` e os dados de M4:
- **Caso completo**: obs −0,014286; en −0,036085; combinação −0,019736; limite → −0,015429 e `limitada = true`; proj(30) 4,937; proj(90) 4,011; data prevista **28 nov. 2026**.
- **Só pesagens**: kgDia −0,014286 → **63 dias → 02 dez. 2026** (falha sem o `round(…, 6)`).
- **Divisão por zero**: uma pesagem só (Sxx = 0) → obs indisponível sem exceção; peso estável (kgDia = 0) → "não é alcançado"; `Pinicial == Pi` → evolução "—".
- **Sem dados**: nenhuma pesagem e nenhuma refeição → projeção indisponível com o texto de M4.
- **Curva ideal**: ideal(90) = 4,745 para P0 5,4 e Pi 4,5.

## Parte Firebase

- `PesagemMapeador` (inclui `conferida`) e `ReferenciaMapeador`, com testes de ida e volta.
- P4-3.2: `integration_test/sync_evolucao_test.dart` no Firebase Emulator Suite (configurado pelo P2). **Ida:** salvar uma pesagem suspeita mantida → conferir `conferida: true` no documento; remover referências → conferir lápide em `referencias` e **nenhuma alteração** em `pesagens`. **Volta:** gravar 3 pesagens e um ECC 7 direto no emulador → pull → conferir que o gráfico, o peso ideal (4,5) e a projeção foram recalculados sozinhos.
- Com a cópia ativa no projeto real, repetir uma vez e tirar print do console.

## Critérios de aceite

- [ ] Pesagens 5,6 / 5,5 / 5,4 kg em 16, 23 e 30 set. e ECC 7 → Indicadores `Peso ideal • 4,5 kg (estimado pelo ECC 7)`, `Evolução • 18%`, e as três séries no gráfico.
- [ ] Arrastar o dedo no dia 30 set. mostra `5,4 kg (pesagem)`; no dia 27 set., `≈ 5,44 kg (estimado)`; num dia futuro, projeção e ideal.
- [ ] Registrar uma refeição, editar um peso ou registrar uma atividade muda a projeção e a previsão **sem sair da tela** (U2-05).
- [ ] Editar o peso inicial atualiza a evolução e o gráfico na hora (U2-06).
- [ ] Nenhuma pesagem → estado vazio amigável, sem exceção e sem desenhar zero (U2-07). Uma pesagem → só o ponto.
- [ ] Digitar 54 com anterior 5,4 → abre o 25 com "Corrigir para 5,4 kg". Manter → salva 54 com `conferida`, e a projeção não despenca.
- [ ] Pesagem que aproxima 100 g do ideal → N3 com a celebração; pesagem que afasta → nenhuma celebração e nenhuma mensagem de culpa.
- [ ] Remover referências mantém todas as pesagens.
- [ ] TalkBack lê o texto alternativo do gráfico e o valor ao soltar o dedo.
- [ ] RNF06: abrir a Evolução com 1.000 pesagens em até 2 s, medido 20 vezes; recalcular os modelos em menos de 50 ms.
- [ ] T4 passa.

## Evidências para guardar

Vídeo arrastando o dedo no gráfico; vídeo de uma refeição registrada mudando a previsão; golden do 04 (com dados e vazio) ao lado do PNG; saída do T4; medições de tempo; print do Firestore com `conferida: true`; hash dos commits.

## Rascunho para a revisão técnica

> Rascunho escrito a partir do que este pacote prevê. **Substitua tudo o que está entre colchetes pelo que aconteceu de verdade** e apague o que você não fez.

**1. Código gerado por IA que precisou ser corrigido**
Usei IA para gerar a primeira versão do cálculo da data prevista. O trecho que precisei corrigir foi [colar o trecho real]. [Exemplo do tipo de problema neste pacote: o código fazia `(ideal - atual) / kgDia` direto, então com o peso estável dava divisão por zero e `Infinity`; e o `ceil` de `63,00000000000002` dava 64 dias em vez de 63, por erro de ponto flutuante.] Ajustei [tratando ritmo zero ou na direção contrária antes da divisão e arredondando para 6 casas antes do `ceil`] e conferi com o teste T4, que [cobre o caso de 63 dias e o de peso estável].

**2. Conhecimentos da disciplina aplicados**
Usei gerenciamento de estado com Riverpod para o gráfico e os indicadores se recalcularem sozinhos quando muda qualquer dado, Clean Architecture para deixar toda a matemática no domínio, em Dart puro e testável, desenho customizado com `CustomPainter` e gestos com `GestureDetector` para o gráfico interativo, e acessibilidade, com a alternativa em texto lida pelo TalkBack. [Ajustar para os nomes da disciplina.]

**3. Solução para a dificuldade**
Separei o modelo em partes pequenas e testáveis: tendência observada (regressão linear das pesagens), tendência energética (ingestão menos gasto, dividido por 7.700 kcal/kg), combinação pelo número de pesagens recentes e um limite de segurança de 2% do peso por semana. Cada parte devolve "disponível" ou "indisponível" em vez de lançar erro. Verifiquei com os casos de teste calculados à mão no T4 e no app, [registrando refeições e pesos e vendo a previsão mudar: resultado].

**4. Maior dificuldade técnica**
A maior dificuldade foi a projeção adaptativa e a data prevista. O modelo precisava usar alimentação, atividade e pesagens reais, mudar sozinho a cada registro e nunca quebrar com dados faltando: nenhuma pesagem, uma só, peso estável, peso digitado errado. Isso apareceu [quando liguei a projeção aos dados reais e ela deu valores absurdos / quebrou com uma pesagem só / ficou instável].

**5. Uso do Firebase**
O Firebase no PetAmigo serve só para a cópia remota opcional; o app funciona offline. A minha parte foi no Cloud Firestore: escrevi os mapeadores das pesagens e das referências de ECC e objetivo para documentos em `usuarios/{uid}` e o teste de integração no Firebase Local Emulator Suite, que confere que uma pesagem mantida como suspeita chega com `conferida: true`, que remover as referências não apaga as pesagens e que, depois de restaurar, o gráfico e a projeção são recalculados sozinhos.

**6. Principal contribuição individual**
Fiz a aba Evolução e a matemática da Unidade II: peso ideal, curva ideal e projeção adaptativa de 90 dias, data prevista, percentual de evolução e o gráfico interativo. O resultado é que o tutor arrasta o dedo no gráfico e vê o peso de cada dia, compara para onde o pet está indo com o caminho recomendado e tem uma previsão que muda a cada refeição, pesagem ou atividade registrada.

**7. Fluxo de dados com o Firebase**
Quando o tutor salva uma pesagem, ela passa primeiro pela verificação de variação. Depois de confirmada, é gravada no banco local junto com o item da fila de sincronização, e os providers recalculam gráfico e projeção na hora. Com a cópia remota ativa e Wi-Fi, o motor de sync usa o meu `PesagemMapeador` para gerar o documento (peso, data como `Timestamp`, `conferida` e versão) e grava em `usuarios/{uid}/pesagens/{id}`. Na restauração, os documentos voltam para o banco local, e a projeção é recalculada a partir deles sem nenhum passo extra.

**8. Funcionalidades implementadas**
- Pesagens: criar, editar (inclusive o peso inicial) e excluir, com conferência de variação suspeita.
- Peso ideal pelo objetivo do veterinário ou estimado pelo ECC.
- Curva ideal e projeção adaptativa de 90 dias, com limite de segurança.
- Data prevista para atingir o peso ideal, sem divisão por zero.
- Indicadores: peso atual, peso ideal, percentual de evolução e aderência.
- Gráfico interativo com o valor do dia sob o dedo e estado vazio.
- Sugestão de mudar o objetivo e celebração ao se aproximar do peso ideal.
- Teste automatizado T4 da projeção e da data prevista.
[Apagar ou detalhar.]

**9. O que faria diferente**
Eu calibraria o modelo com dados reais: comparar a projeção de 30 dias com o peso que o pet realmente teve e ajustar a constante de 7.700 kcal/kg e os fatores de atividade, que hoje são valores da literatura e decisões do grupo. [Ou outra melhoria real.] Priorizaria isso porque a data prevista é o número que mais motiva o tutor, e ela só merece confiança se for conferida contra a realidade.

**10. Testes e evidências**
O teste oficial T4 confere o caso completo da projeção, o limite de segurança, a data prevista (inclusive o caso de 63 dias que falhava por arredondamento) e os casos de divisão por zero ([resultado]). Também fiz golden tests do gráfico com e sem dados, os testes da conferência de pesagem e o teste de integração no Firebase Emulator. Manualmente, gravei um vídeo arrastando o dedo no gráfico e registrando uma refeição para mostrar a previsão mudando, e medi o tempo de abrir a Evolução com 1.000 pesagens: [resultado]. Evidências: [vídeos, prints, saída dos testes, commits].
