# Pacote 1 — Base do app, design system e Início

**Responsável:** ______________________

## Objetivo

Criar o esqueleto que os outros quatro pacotes usam (projeto Flutter em **Clean Architecture**, tema, os 7 componentes, navegação, banco local e Firebase inicializado) e entregar a aba **Início**, o cadastro de **vários pets** e o cálculo da **meta diária (RER × fator)**.

**Requisitos:** RF01, RF02, RF03, RNF02, RNF03, RNF07, RNF10, RNF12 · **Unidade II:** U2-01 (domínio M1), U2-06 (peso inicial), U2-10, U2-14, teste oficial T1.
**Entrega para:** todos. **Depende de:** nada (é o primeiro).

## Ordem de execução

Siga as tarefas `P1-0.x` → `P1-1.x` → `P1-2.x` → `P1-3.x` → `P1-4.x` do `plano-de-execucao.md`. A Fase 0 inteira é deste pacote (exceto os contratos do P5 e as regras puras do P2, P3 e P4), e **os outros pacotes só montam telas quando ela fechar**.

## Entregas da base (Fase 0)

- [ ] `flutter create` com `minSdkVersion 26`, locale `pt_BR`, Inter em `assets/fonts` e gato em `assets/img`.
- [ ] `lib/app/tema/*` exatamente como em `comum/design-system.md`.
- [ ] Componentes `PaBotao`, `PaCampo`, `PaCard`, `PaMensagem`, `PaDialogo`, `PaNavegacao` e `PaHistorico`, mais a função `confirmarExclusao()` (tela 23, abaixo), cada um com um widget test (altura mínima, semântica e variantes).
- [ ] `router.dart` com as 4 abas e o estado "sem pet" (`comum/navegacao.md`).
- [ ] `database.dart` do drift com **todas** as tabelas de `comum/dados-e-sync.md` (domínio e controle) e os índices; migração versão 1. Assim ninguém espera ninguém para ter onde gravar. Mudanças de esquema depois disso só com migração e combinadas com o grupo.
- [ ] `core/formato/` com as regras R10 e R11, e testes.
- [ ] Projeto Firebase criado, `flutterfire configure`, inicialização no `main` com `persistenceEnabled: false` e `disableNetwork()`.
- [ ] Infraestrutura de golden test (carregar a Inter no teste, tamanho 390 × 844) com um exemplo pronto para os colegas copiarem.

## Telas

### 01 — Início (`docs/design/telas/01-inicio.png`)

Layout de tela principal (`design-system.md`). Os números entre parênteses são do Figma (x, y, largura × altura dentro do conteúdo).

| # | Elemento | Detalhe |
|---|---|---|
| 1 | Título | `titulo`: só a saudação, conforme R11, ex.: `Bom dia` (sem o nome do tutor, P-01) (20, 20, 350 × 36) |
| 2 | Subtítulo | `legenda`: "Um cuidado de cada vez." |
| 3 | Cabeçalho do pet (350 × 80) | Linha: foto em círculo de 64 → 12 → coluna com `{nome}` e `{Espécie} • {idade}` em `secao` (176 de largura) → espaço flexível → gato sorrindo 64 × 64 com 22 de margem à direita. Sem foto: círculo `suave` com a inicial do nome em `secao` (P-14). Espécie flexionada pelo sexo (R11): `Gata • 6 anos` |
| 4 | Card `padrao` "{nome}" | Texto: `{Espécie} • {idade} • {castrado/castrada}` / `Atividade {nível em minúsculas} • {peso}`, ex.: `Gata • 6 anos • castrada` / `Atividade moderada • 5,4 kg`. Botão `secundario` **Editar pet** → 05 |
| 5 | Card `destaque` "Hoje · {dia} {mês}" | Texto de R02: `Ração {r} kcal • Petiscos {p} kcal` / `Total: {t} de {meta} kcal`. Sem registros hoje: `Ainda sem registros hoje.` Botão `primario` **Registrar refeição** → 06 (diálogo do P2). Dados de `resumoDiaProvider(petId, hoje)`, do P2 |
| 5a | Card `destaque` **Sugestões** (Unidade II, novo) | Até 2 sugestões de `sugestoesProvider(petId)` (M8; regras do P2, P3 e P4), cada uma com o botão `secundario` da ação ("Ver diário", "Ver atividades", "Ver evolução") e `secundario` **Agora não**. Sem sugestões: o card não aparece |
| 6 | Card "Referência alimentar" | Texto de R03: `Meta de hoje: 397 kcal (≈ 110 g de Ração habitual)` / `RER × 1,6 (castrada). Estimativa educativa.` Sem pesagem: `Registre uma pesagem para calcular a meta.` Botão `secundario` **Entender a referência** → 18 |
| 6a | Card **Lembretes** (Unidade II, novo) | `08:00 • 14:00 • 20:00` ou `Nenhum lembrete ativo.` (`lembretesProvider(petId)`, do P3). Botão `secundario` **Configurar lembretes** → N2 (diálogo do P3) |
| 7 | Card "Seu controle" | Cópia desligada: `Dados salvos neste aparelho.` Ligada: `Cópia remota: {pendente/sincronizado/falha}` (provider do P5). Botão `secundario` **Privacidade e cópia remota** → 14 (diálogo do P5) |
| 8 | Navegação | Início ativo |

Tocar no cabeçalho do pet (item 3) abre **N1 Seus pets**. Com 2 ou mais pets, aparece abaixo do nome, em `legenda`, o texto `Trocar de pet` (dica visual de que o cabeçalho é tocável).

Peso no card 4: última pesagem (`ultimaPesagemProvider`, do P4). Sem pesagem: `peso não informado`.

Até a Fase 2, os providers do P2 (`resumoDiaProvider`), do P3 (`lembretesProvider`), do P4 (`ultimaPesagemProvider`), do P5 (`estadoCopiaProvider`) e o `sugestoesProvider` (que junta S1, S2 e S3) são **stubs** com a assinatura final (`plano-de-execucao.md` → Stubs). Monte o Início com eles; nenhum código do Início muda quando forem trocados.

### 05 — Dados do pet (`05-dados-do-pet.png`)

Diálogo. Título `Dados de {nome}` (ou `Dados do pet` no cadastro). Subtítulo: `Cadastro e edição no mesmo formulário.`

| Campo | Tipo | Valores |
|---|---|---|
| Nome | texto | 1–40 caracteres |
| Espécie | escolha | Cão / Gato |
| Sexo | escolha | Macho / Fêmea. **Campo novo**, que não está no protótipo (P-02): permite escrever "Gata" e "castrada" como no Início do PNG. Fica logo abaixo de Espécie, e o diálogo passa a ter 824 de altura, com rolagem |
| Idade | escolha | anos (0–30) + meses (0–11), guardada como `idadeMeses` (B-c). Exibe `6 anos` ou `6 meses`. Abaixo de 12 meses o pet é **filhote** (fator 3,0 em M1) |
| Castração | escolha | Sim / Não |
| Atividade | escolha | Baixa / Moderada / Alta |
| Peso inicial | número (kg) | Só no **cadastro**: o `PetRepo` grava o pet e **insere a primeira linha na tabela `pesagens`** na mesma transação, sem depender do código do P4. Na **edição**: continua `Peso inicial • {primeira pesagem}` e **é editável** (U2-06, P-04 revista). Salvar altera essa pesagem (com a conferência R06), e meta, gráfico, evolução e projeção se recalculam na hora pelos streams (M9) |

Botões: `primario` **Adicionar ou trocar foto**, `primario` **Salvar pet**, `perigo` **Excluir este pet** (só na edição e com 2 ou mais pets → 23 → apaga o pet, os registros dele e os lembretes), `secundario` **Voltar**.

- Foto: `image_picker` (galeria, `maxWidth: 1024`, `imageQuality: 85`). O arquivo é copiado para a área privada do app e o caminho vai para `fotoArquivo`. A foto antiga é apagada ao trocar.
- Validação: R05. Salvar só fecha o diálogo depois da transação terminar.

### 18 — Como a meta é calculada (`18-referencia-indisponivel.png`, layout reaproveitado)

A Unidade II **ativa o cálculo** (U2-01). O diálogo mantém o layout do PNG, com textos novos:
- Título `Como a meta é calculada`. Subtítulo `Fórmula veterinária (NRC).`
- Texto, com os números do pet atual:
  `RER = 70 × peso^0,75 = 70 × 5,4^0,75 = 248 kcal` /
  `Fator 1,6 (castrada) → meta de 397 kcal por dia` /
  `Com Ração habitual (360 kcal/100 g): ≈ 110 g por dia.` /
  `Estimativa educativa. Não substitui a avaliação do veterinário.`
- Sem pesagem: `Registre uma pesagem para calcular a meta.`
- Botões `primario` **Voltar ao perfil** (fecha) e `secundario` **Voltar** (fecha).
- Por trás: caso de uso `CalcularMetaDiaria` em `features/nutricao/domain/` (M1), usado também pelo P2 (diário) e pelo P4 (projeção).

### 26 — Vamos começar? (`26-vamos-comecar.png`)

Estado sem pet: fundo `superficie`, sem navegação. Bloco com padding de 16 (como diálogo, mas sem véu): título `Vamos começar?`, subtítulo `Cadastre seu cão ou gato.` (o protótipo dizia "um único"; a Unidade II permite vários), texto `Não há pet nem registros neste aparelho.`, botão `primario` **Cadastrar pet** → 05 em modo cadastro.

### 23 — Confirmar exclusão (`23-confirmar-exclusao.png`): componente compartilhado

Faz parte da base (Fase 0) porque os pacotes 2, 3, 4 e 5 dependem dele.
`Future<bool> confirmarExclusao(BuildContext c, {bool integral = false})` em `core/ui/`.
- Título `Confirmar exclusão`. Subtítulo `Ação sobre o item selecionado.` (integral: `Ação sobre todos os dados.`)
- Texto, modo item: `Exclui apenas o item escolhido e atualiza os totais.` Modo integral: `Remove pet, foto, metas e todos os registros deste aparelho. A remoção da cópia remota pode ficar pendente até o próximo Wi-Fi.`
- Botões: `primario` **Confirmar exclusão** e `secundario` **Cancelar**. No PNG, "Cancelar" está verde; no app ele segue o padrão dos outros botões de cancelar (P-06).
- Abre por cima do formulário que chamou. Devolve `true` ao confirmar; quem chamou fecha o próprio diálogo e executa a exclusão.

## Unidade II

### Clean Architecture (U2-14)

Na Fase 0, o P1 cria o esqueleto de pastas de `arquitetura.md` → Clean Architecture para todas as funcionalidades (pastas vazias com um `README` curto), e implementa a funcionalidade `pets` completa como **exemplo de referência** para os colegas: entidade `Pet`, interface `PetRepositorio`, casos de uso `CadastrarPet`, `EditarPet`, `ExcluirPet`, `TrocarPetAtual`, implementação drift e providers.

### Vários pets (U2-10)

- `petAtualIdProvider` (`StreamProvider<String?>` lendo `config.petAtualId`). **Todos** os providers de dados dos outros pacotes recebem esse id (`.family`).
- Cadastrar o primeiro pet o torna o pet atual. Cadastrar outro pelo N1 também o torna atual.
- Excluir o pet atual (havendo outros) passa para o primeiro da lista. Excluir o último leva ao 26.

### N1 — Seus pets (diálogo novo)

- Título `Seus pets`. Subtítulo `Cada pet tem histórico, metas e lembretes próprios.`
- Uma `PaHistorico` por pet: `{nome} • {Espécie} • {idade}`; o atual termina com ` • atual`. Toque → vira o pet atual e fecha.
- Botões: `primario` **Cadastrar outro pet** → 05 em modo cadastro; `secundario` **Voltar**.

### Meta diária — M1 (U2-01) e teste oficial T1

- `features/nutricao/domain/meta_diaria.dart`: `rer(peso)`, `fatorAtividade(pet, hoje)`, `metaDiaria(pet, ultimaPesagem, hoje)` e `gramas(meta, densidade)`, devolvendo `Disponivel`/`Indisponivel` (`core/resultado.dart`).
- Provider `metaProvider(petId)` recalcula sozinho quando muda a pesagem, a idade, a castração ou a atividade (M9).
- **T1** (`test/nutricao/meta_diaria_test.dart`): todos os casos da tabela de M1 (Luna 247,97 / 396,75 / 110,2 g; filhote 743,9; sem pesagem → indisponível; densidade 0 → gramas indisponíveis) e a ordem dos fatores (filhote castrado = 3,0; castrado com atividade alta = 2,0).

## Parte Firebase

1. Criar o projeto no console (região `southamerica-east1`) e ativar Authentication (e-mail/senha), Firestore e Storage. As regras ficam com o P5.
2. `flutterfire configure` → `lib/firebase_options.dart`.
3. `main.dart`: `Firebase.initializeApp`, `Settings(persistenceEnabled: false)` e `disableNetwork()`.
4. `PetMapeador` (`data/sync/mapeadores/pet_mapeador.dart`) com o teste de ida e volta.
5. Fotos na cópia remota: `enviarFoto(uid, petId, arquivo)` → `usuarios/{uid}/pets/{petId}.jpg`, e `baixarFoto(...)` para a restauração. O motor do P5 chama essas funções.
6. P1-3.2: `integration_test/sync_pet_test.dart` no emulador (preparado pelo P2). **Ida:** cadastrar **dois pets** com foto e editar um → motor → ler `usuarios/{uid}/pets/{id}` com `FirebaseFirestore.instance` e conferir os campos (inclusive `idadeMeses`); conferir que os dois arquivos existem no emulador do Storage. **Volta:** apagar o banco local → pull → conferir os dois pets e as fotos restaurados.

## Critérios de aceite

- [ ] Abrir o app sem pet mostra o 26. Cadastrar leva ao Início com os dados certos.
- [ ] Gata fêmea castrada aparece como `Gata • 6 anos • castrada`; cão macho como `Cão • … • castrado`.
- [ ] O título do Início mostra só a saudação do horário (`Bom dia`, `Boa tarde`, `Boa noite`).
- [ ] O Início fica igual ao PNG 01 no golden test. Diferenças esperadas: título sem o nome "Marina" (P-01), texto do card "Referência alimentar" com a meta e os cards novos Sugestões e Lembretes (Unidade II). Qualquer outra deve ser anotada.
- [ ] Com fonte do sistema em 200%, nada corta: botões, campos e navegação crescem em altura.
- [ ] TalkBack lê os 4 destinos com estado "selecionado" e lê os rótulos dos campos do 05.
- [ ] Trocar a foto apaga o arquivo antigo da área privada.
- [ ] Modo avião: cadastro e edição funcionam.
- [ ] Instala e roda num emulador com Android 8.0 (API 26).
- [ ] Com dois pets, trocar no N1 troca Início, Diário, Atividades e Evolução; nenhum dado de um pet aparece no outro.
- [ ] Editar o peso inicial no 05 atualiza a meta do card "Referência alimentar" e o gráfico da Evolução sem sair e voltar da tela.
- [ ] Luna (5,4 kg, castrada) mostra `Meta de hoje: 397 kcal (≈ 110 g …)`; um filhote de 6 meses com o mesmo peso mostra 744 kcal.
- [ ] T1 passa.
- [ ] A estrutura de pastas segue a Clean Architecture e o domínio de `pets` e `nutricao` não importa Flutter, drift nem Firebase.

## Evidências para guardar

Prints do Início lado a lado com o PNG 01; print com fonte em 200%; saída de `flutter test` (com T1); vídeo curto do cadastro em modo avião e da troca de pet; print da tela 18 com o cálculo; print do console do Firebase com o projeto e o Storage; hash dos seus commits.

## Rascunho para a revisão técnica

> Rascunho escrito a partir do que este pacote prevê. **Substitua tudo o que está entre colchetes pelo que aconteceu de verdade** e apague o que você não fez. As respostas precisam bater com seus commits e evidências.

**1. Código gerado por IA que precisou ser corrigido**
Usei IA para gerar a primeira versão dos componentes do design system. Um trecho que precisei corrigir foi [colar o trecho real]. [Exemplo do tipo de problema que costuma aparecer aqui: o `PaBotao` veio com `SizedBox(height: 52)`, ou seja, altura fixa, e com a fonte do Android em 200% o texto ficava cortado.] Eu ajustei [trocando por `ConstrainedBox(constraints: BoxConstraints(minHeight: 52))`] e conferi [abrindo o app com a fonte no máximo e rodando o widget test que mede a altura].

**2. Conhecimentos da disciplina aplicados**
O que mais usei foi composição de widgets e layout: as telas do Figma viraram `Column`, `Expanded` e `SingleChildScrollView`, com os cards repetindo o mesmo padrão. Também usei tema (`ThemeData` e constantes de cor e tipografia) para não espalhar valores pelo código, navegação com abas e rotas para os quatro destinos, persistência local com SQLite (drift) para o app funcionar offline, e acessibilidade com `Semantics` e área de toque mínima de 48 dp. [Ajustar para os nomes dos conteúdos como a disciplina chamou.]

**3. Solução para a dificuldade**
Para resolver isso, troquei todas as alturas fixas por alturas mínimas e deixei os textos quebrarem linha. Depois criei golden tests das telas no tamanho 390 × 844 para comparar com os PNGs exportados do Figma. Verifiquei que funcionou [rodando os golden tests e comparando lado a lado com o PNG, e testando no emulador com fonte em 200%: resultado].

**4. Maior dificuldade técnica**
A maior dificuldade foi deixar as telas fiéis ao Figma sem quebrar a acessibilidade. O protótipo tem medidas exatas (botão de 52, campo de 64, navegação de 87 × 56), mas o requisito pede que tudo continue utilizável com a fonte em 200%. Isso aconteceu [quando montei os componentes, na primeira semana], e [descrever o que quebrou: textos cortados, navegação estourando etc.].

**5. Uso do Firebase**
No PetAmigo o Firebase não é o banco principal: o app funciona offline e sem conta, e o Firebase só guarda uma cópia quando o tutor ativa a cópia remota. Pessoalmente, criei o projeto no console, configurei o app com o `flutterfire configure` e deixei a inicialização no `main` com a rede do Firestore desligada por padrão, para nada sair do aparelho sem o tutor pedir. Também escrevi o mapeamento do pet para o documento do Firestore e usei o Cloud Storage para guardar a foto do pet na cópia remota. Testei essas duas partes no Firebase Local Emulator Suite antes de usar o projeto real.

**6. Principal contribuição individual**
Minha principal contribuição foi a base do app: a estrutura em Clean Architecture, o tema e os sete componentes (botão, campo, card, mensagem, diálogo, navegação e histórico), a navegação, o banco local, o suporte a vários pets e o cálculo da meta diária (RER × fator), que o diário e a evolução usam. O resultado foi que os colegas montaram as telas deles reaproveitando esses componentes e seguindo a funcionalidade `pets` como exemplo, então o app ficou consistente e parecido com o protótipo sem cada um refazer estilo ou arquitetura. [Citar um número real, se tiver: quantas telas usam os componentes, quanto tempo economizou etc.]

**7. Fluxo de dados com o Firebase**
O fluxo que fiz foi o da foto do pet. Quando o tutor escolhe a foto, o app copia o arquivo para a pasta privada e grava o caminho na tabela `pets`, tudo local. Se a cópia remota estiver ativa, essa alteração entra na fila de sincronização; quando houver Wi-Fi, o motor de sync chama o meu mapeador, que transforma cada pet num documento em `usuarios/{uid}/pets/{id}`, e a minha função de upload envia a imagem para `usuarios/{uid}/pets/{id}.jpg` no Storage. Na restauração em outro aparelho acontece o caminho inverso: o documento é lido e a foto é baixada para a pasta local.

**8. Funcionalidades implementadas**
- Design system: tema e os sete componentes reutilizáveis usados em todas as telas, mais a confirmação de exclusão usada por todos os pacotes.
- Clean Architecture: o esqueleto de pastas e a funcionalidade `pets` como exemplo de domínio, dados e apresentação.
- Navegação: as quatro abas fixas e a regra de mostrar "Vamos começar?" quando não há pet.
- Vários pets: cadastro, troca do pet atual e exclusão de um pet com os registros dele.
- Cadastro e edição do pet: formulário único, idade em anos e meses (para identificar filhote), foto pela galeria, primeira pesagem no cadastro e peso inicial editável.
- Meta diária: RER = 70 × peso^0,75 multiplicado pelo fator (filhote 3,0, ativo 2,0, castrado 1,6), com conversão para gramas e o teste automatizado T1.
- Tela Início: cabeçalho com foto e gato sorrindo e os cards de perfil, resumo do dia com a meta, sugestões, referência alimentar, lembretes e controle dos dados.
[Apagar o que não fez e detalhar o que fez.]

**9. O que faria diferente**
Eu priorizaria testar o Início e o cadastro com tutores de verdade e com o TalkBack ligado desde o começo, em vez de só no fim. [Ou outra melhoria real.] O Início é a tela mais vista do app e o design system é usado por todas as outras, então um problema de acessibilidade nele se espalha por todo o app.

**10. Testes e evidências**
Testei de três formas. Widget tests para cada componente, verificando altura mínima, semântica e variantes ([N] testes passando), e o teste oficial T1 da meta diária, com os valores calculados à mão para a Luna (RER 247,97 e meta 396,75 kcal), o filhote e o caso sem pesagem ([resultado]). Golden test da tela Início comparado com o PNG do Figma ([resultado/diferenças]). E testes manuais no emulador Android 8.0: cadastro em modo avião, fonte em 200% e navegação com TalkBack ([resultado]). Na parte do Firebase, escrevi um teste de integração no emulador que cadastra o pet com foto, sincroniza e confere o documento no Firestore e o arquivo no Storage, e depois restaura tudo num banco vazio ([resultado]). As evidências são [prints, saída do `flutter test`, vídeo, commits].
