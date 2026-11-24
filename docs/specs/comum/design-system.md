# Design system

Fonte: variáveis do Figma, `docs/design/estrutura-page1.xml` e cores medidas nos PNGs. Os valores marcados com **(medido)** foram lidos dos pixels exportados. Os tamanhos de fonte foram confirmados no PDF de alta fidelidade.

## Tokens

### Cores

| Token | Hex | Uso |
|---|---|---|
| `verde` | `#236447` | Botão primário, linha e pontos do gráfico, traço do gato |
| `fundo` | `#F6F8F4` | Fundo das 4 telas principais |
| `superficie` | `#FFFFFF` | Cards, campos, botões secundários, diálogos, barra de navegação **(medido)** |
| `suave` | `#E4EEE5` | Card em destaque ("Hoje", gráfico), destino ativo da navegação, preenchimento do gato |
| `texto` | `#1F3029` | Todo o texto sobre fundo claro |
| `borda` | `#CBD7CC` | Borda de campos, botões secundários e itens da navegação; eixos do gráfico |
| `erro` | `#8F342D` | Borda do botão de perigo e do campo com erro; texto de erro |
| `veu` | preto com 18% de opacidade (`#2E000000`) | Fundo escurecido atrás dos diálogos **(medido: `#F6F8F4` → `#CACBC8`)** |

Contraste verificado no `justificativas.md`: `texto` sobre `superficie` 13,88:1, sobre `fundo` 12,99:1, sobre `suave` 11,67:1; branco sobre `verde` 7,03:1. `erro` sobre branco dá aproximadamente 7,8:1.

### Espaço, raio e borda

| Token | Valor | Onde aparece |
|---|---|---|
| `espaco` | **12** | Entre cards, entre elementos dentro de card e diálogo, entre título e subtítulo |
| `margemTela` | 20 | Margem lateral e superior do conteúdo das 4 telas principais |
| `paddingCard` | 12 | Padding interno dos cards |
| `paddingDialogo` | 16 | Padding interno dos diálogos |
| `raio` | **16** | Cards, botões, campos, itens da navegação, diálogos |
| `bordaLargura` | 1 | Borda de campos, botões e itens da navegação (2 px no PNG 2x) |

### Tipografia: Inter (empacotada em `assets/fonts`)

| Estilo | Tamanho | Altura de linha | Peso | Uso |
|---|---|---|---|---|
| `titulo` | 26 | 36 | 700 | Título de tela e de diálogo |
| `secao` | 18 | 25 | 700 | Título de card; nome e espécie no cabeçalho do Início |
| `corpo` | 16 | 22 (1,4) | 400 | Texto de cards, rótulos de botões e campos |
| `legenda` | 14 | 20 | 400 | Subtítulo de tela e de diálogo, texto alternativo do gráfico |
| `navegacao` | 12 | 16 | 400 | Rótulo dos 4 destinos |

Cor do texto: `texto`, exceto no botão primário (branco) e nas mensagens de erro (`erro`).

O peso 700 de `titulo` e `secao` foi conferido visualmente nos PNGs. O PDF embute a fonte como desenho, sem o nome do peso. Se alguém tiver acesso ao Figma, vale confirmar (P-12).

### Medidas

| Elemento | Medida |
|---|---|
| Botão | altura **mínima** 52 |
| Campo | altura **mínima** 64 |
| Mensagem de estado | altura mínima 62 |
| Item da navegação | 87 × 56 no frame de 390 (na prática, largura igual por `Expanded`), altura mínima 56 |
| Barra de navegação | altura 72 (padding 8, espaço de 8 entre itens) |
| Foto do pet (Início) | círculo de 64 |
| Gato sorrindo | 64 × 64 |
| Diálogo | largura 350 (margens de 20 numa tela de 390) |

As alturas são **mínimas**: com fonte a 200%, tudo cresce em altura e quebra linha (RNF02). Nunca use `maxLines: 1` em rótulos de campo ou botão, nem `height` fixa.

### Código de referência

```dart
// lib/app/tema/cores.dart
abstract final class PaCores {
  static const verde = Color(0xFF236447);
  static const fundo = Color(0xFFF6F8F4);
  static const superficie = Color(0xFFFFFFFF);
  static const suave = Color(0xFFE4EEE5);
  static const texto = Color(0xFF1F3029);
  static const borda = Color(0xFFCBD7CC);
  static const erro = Color(0xFF8F342D);
  static const veu = Color(0x2E000000);
}

// lib/app/tema/espacos.dart
abstract final class PaEspaco {
  static const s = 12.0;          // token "espaco"
  static const margemTela = 20.0;
  static const paddingCard = 12.0;
  static const paddingDialogo = 16.0;
  static const raio = 16.0;
}

// lib/app/tema/tipografia.dart
abstract final class PaTexto {
  static const _f = 'Inter';
  static const titulo = TextStyle(fontFamily: _f, fontSize: 26, height: 36 / 26, fontWeight: FontWeight.w700, color: PaCores.texto);
  static const secao = TextStyle(fontFamily: _f, fontSize: 18, height: 25 / 18, fontWeight: FontWeight.w700, color: PaCores.texto);
  static const corpo = TextStyle(fontFamily: _f, fontSize: 16, height: 1.4, fontWeight: FontWeight.w400, color: PaCores.texto);
  static const legenda = TextStyle(fontFamily: _f, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: PaCores.texto);
  static const navegacao = TextStyle(fontFamily: _f, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, color: PaCores.texto);
}
```

O `ThemeData` usa `scaffoldBackgroundColor: PaCores.fundo`, `fontFamily: 'Inter'` e `useMaterial3: true`. Desligue `splashFactory` e mantenha o highlight discreto: o protótipo não tem ondulação.

## Componentes (`lib/core/ui/`)

São as sete famílias da biblioteca do Figma. Todas as telas usam somente estes componentes.

### 1. `PaBotao`

| Variante | Fundo | Borda | Texto | Onde |
|---|---|---|---|---|
| `primario` | `verde` | `verde` | branco | **Nos diálogos:** todas as ações exceto voltar, cancelar e excluir ("Salvar …", "Confirmar …", "Alterar dados", "Adicionar ou trocar foto", "Manter versão local", "Usar versão da cópia" etc.). **Nos cards das telas principais:** só "Registrar refeição" (telas 01 e 21) |
| `secundario` | `superficie` | `borda` | `texto` | Todos os outros botões de card das telas principais ("Editar pet", "Selecionar data", "Gerenciar alimentos"…) e "Voltar"/"Cancelar" nos diálogos |
| `perigo` | `superficie` | `erro` | `texto` | "Excluir registro", "Excluir todos os dados", "Excluir alimento e porção" |

Conferido nos PNGs 01, 02, 04, 05, 06, 07, 09, 14, 16, 17, 21, 23 e 25.

Diferença intencional em relação ao protótipo: na tela **23 Confirmar exclusão**, o PNG mostra "Cancelar" em `primario`. No app, "Cancelar" é `secundario`, como todo botão de voltar ou cancelar, e "Confirmar exclusão" continua `primario` (P-06).

- Largura total do contêiner; altura mínima 52; raio 16.
- Texto `corpo`, **alinhado à esquerda**, com padding horizontal de 12 e centralizado na vertical. Não há ícones.
- Desabilitado: opacidade de 40% e sem toque. Em carregamento: troca o texto por "Salvando…" e bloqueia novo toque (sem spinner, para não haver toque duplo).
- Acessibilidade: `Semantics(button: true, label: texto)`; área de toque de pelo menos 48 × 48 (garantida pela altura de 52).

### 2. `PaCampo`

Visual: caixa `superficie`, borda `borda` de 1, raio 16, altura mínima 64 e padding horizontal de 12. O conteúdo é uma linha **"Rótulo • valor"** em `corpo` (ex.: `Quantidade • 30 g`).

| Tipo | Interação |
|---|---|
| `texto` / `numero` | O valor é um `TextField` sem decoração depois do prefixo fixo "Rótulo • ". O teclado `numero` aceita vírgula e ponto (R10). |
| `escolha` | Toque abre um diálogo `PaDialogo` com as opções como botões `secundario`; a escolhida fica `primario`. Ex.: Espécie, Castração, Atividade, Tipo, Alimento, Origem. |
| `data` / `hora` | Toque abre o `showDatePicker`/`showTimePicker` nativo com locale pt-BR. |

- Estado de erro: borda `erro` e, abaixo da caixa, a mensagem em `legenda` com cor `erro`. Exemplo visual: tela 25, "Peso informado • 54 kg".
- O rótulo nunca some, nem com valor preenchido nem com fonte ampliada (RNF02). Com pouco espaço, o valor quebra para a linha de baixo.
- Acessibilidade: `Semantics(label: rótulo, value: valor, textField: true)`.

### 3. `PaCard`

| Variante | Fundo | Uso |
|---|---|---|
| `padrao` | `superficie` | Todos os cards |
| `destaque` | `suave` | "Hoje · 30 set." no Início e o card do gráfico na Evolução |

- Sem borda, raio 16, padding 12, largura total (350 no frame de 390).
- Conteúdo em coluna com espaço de 12: título (`secao`), texto (`corpo`) e um botão opcional.
- Medidas do Figma: título com 25 de altura, texto a partir de y 49 e botão logo depois do texto + 12.

### 4. `PaMensagem`

Estado de sincronização: `pendente`, `sincronizado`, `falha`.
- Caixa igual à do `PaCampo` (superfície, borda `borda`, raio 16, altura mínima 62, padding 12) com a palavra do estado em `corpo`.
- As três variantes são visualmente idênticas, como no protótipo (P-11). O significado vem do texto, nunca da cor (RNF02).

### 5. `PaDialogo`

Todos os formulários, confirmações e painéis abrem por cima da tela atual (RNF10: sem quinta tela principal).
- `showDialog` com `barrierColor: PaCores.veu`, `insetPadding` horizontal de 20, fundo `superficie`, raio 16, padding 16, largura máxima de 350.
- Ordem do conteúdo, com espaço de 12: título (`titulo`), subtítulo (`legenda`), texto explicativo (`corpo`, opcional), campos, botões.
- Ordem dos botões: **primário(s) → perigo → secundário ("Voltar"/"Cancelar") por último**.
- Se o conteúdo passar da altura disponível, ele rola dentro do diálogo (ex.: "Dados de Luna" tem 748 de altura).
- "Voltar" e o botão voltar do Android fecham o diálogo sem salvar.
- Acessibilidade: o foco vai para o título quando o diálogo abre (`Semantics(header: true)`).

### 6. `PaNavegacao`

Barra inferior fixa, sempre visível nas 4 telas principais e também por baixo dos diálogos.
- Fundo `superficie`, altura 72, padding 8, quatro itens com `Expanded` e espaço de 8 entre eles.
- Item: altura mínima 56, raio 16, borda `borda`; texto `navegacao` centralizado. **Sem ícones.**
- Ativo: fundo `suave`. Inativo: fundo `superficie`.
- Acessibilidade: `Semantics(selected: ativo, button: true, label: 'Início')`. Com fonte grande, a barra cresce em altura em vez de cortar o texto.

### 7. `PaHistorico`

Linha de registro dentro de um card (ex.: `08:00 • Ração habitual • 30 g • 108 kcal`).
- Texto `corpo`, altura mínima 48, toque em toda a largura abre o formulário de edição daquele registro.
- Sem divisórias. Várias linhas ficam empilhadas sem espaço extra, como em "Diário atualizado" (tela 21).
- Acessibilidade: `Semantics(button: true, label: 'Editar registro: 08:00, Ração habitual, 30 gramas, 108 quilocalorias')`.

## Layout das telas principais

```
SafeArea
└── Column
    ├── Expanded → SingleChildScrollView
    │     padding: esquerda/direita/topo 20, base 20
    │     ├── Text título  (titulo)
    │     ├── 12
    │     ├── Text subtítulo  (legenda)
    │     ├── 12
    │     └── PaCard, 12, PaCard, 12, …
    └── PaNavegacao (fixa)
```

No Figma, o conteúdo começa em y = 24 por causa da barra de status. No app, isso fica a cargo do `SafeArea`.

## Gráfico interativo (U2-02)

O protótipo só tem o gráfico estático de 310 × 92 (tela 04). Para a Unidade II, o gráfico cresce e ganha séries e interação, mas continua no card `destaque` e usa só os tokens deste arquivo. A matemática está em `modelos-matematicos.md` (M3, M4, M6).

| Elemento | Estilo | Como se distingue sem cor |
|---|---|---|
| Área | largura do card − 24; **altura 180** (era 92 no protótipo) | — |
| Eixos | `borda`, traço 2, como no protótipo | — |
| Histórico (pesagens) | `verde`, traço 3, pontos de raio 5 | linha **contínua** com pontos |
| Projeção (90 dias) | `verde`, traço 2, tracejado 6/4 | linha **tracejada** |
| Curva ideal (90 dias) | `texto`, traço 2, pontilhado 2/4 | linha **pontilhada** |
| Peso ideal | `texto`, traço 1, horizontal, com o rótulo `ideal 4,5 kg` em `legenda` na ponta direita | rótulo escrito |
| Hoje | linha vertical `borda`, traço 1, com o rótulo `hoje` | rótulo escrito |
| Legenda | linha abaixo do gráfico em `legenda`: `── pesagens   - - projeção   ··· curva ideal` | desenho do traço + palavra |

**Interação**
- `GestureDetector` com `onHorizontalDragStart/Update/End` e `onTapDown` em toda a área.
- Sob o dedo: linha vertical `texto` de 1 dp + **balão** `superficie` com borda `borda`, raio 12 e padding 8, com o texto de M6 em `legenda` (ex.: `30 set. • 5,4 kg (pesagem)`). O balão nunca sai da área: inverte o lado perto das bordas.
- Ao soltar o dedo, o balão fica visível por 2 s e some.
- Vibração leve (`HapticFeedback.selectionClick`) ao passar por um dia com pesagem.
- **Acessibilidade**: o desenho tem `ExcludeSemantics`. O leitor de tela lê o texto alternativo (R07), que está sempre visível. O balão é anunciado com `SemanticsService.announce` ao soltar o dedo.

**Estado vazio** (M10): no lugar do gráfico, o gato sorrindo de 64, o texto `Ainda não há pesagens de {nome}. Registre a primeira para ver o gráfico.` em `corpo` e o botão `primario` **Registrar peso**.

## Cards novos da Unidade II

Todos usam `PaCard` + `PaHistorico`/texto, sem componente novo:
- **Indicadores** (Evolução, `padrao`): quatro linhas `corpo`: `Peso atual • 5,4 kg`, `Peso ideal • 4,5 kg (estimado pelo ECC 7)`, `Evolução • 18% do caminho`, `Aderência ao plano • 67% (4 de 6 dias com registro)`.
- **Sugestões** (Início, `destaque`): até 2 sugestões, cada uma com o texto em `corpo`, um botão `secundario` com a ação ("Ver atividades") e um botão `secundario` **Agora não**.
- **Lembretes** (Início, `padrao`): `08:00 • 14:00 • 20:00` ou `Nenhum lembrete ativo.` + botão `secundario` **Configurar lembretes**.

## Verificação visual

Cada pacote deve criar um **teste golden** por tela principal (`matchesGoldenFile`), com tamanho 390 × 844, dados demonstrativos da Luna e a fonte Inter carregada no teste. Compare lado a lado com o PNG correspondente de `docs/design/telas/` e anote as diferenças que continuarem.
