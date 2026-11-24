# PetAmigo

App Android de saúde animal: alimentação, petiscos, atividades e peso de cães e gatos (vários pets por aparelho). Projeto de faculdade em grupo, com 5 integrantes e 5 pacotes de trabalho.

## Antes de implementar qualquer coisa

As specs em `docs/specs/` são a fonte da verdade. Leia nesta ordem:
1. `docs/specs/README.md`: visão geral, divisão em pacotes e prioridade das fontes.
2. `docs/specs/unidade-2.md`: exigências do professor (U2-01 a U2-18). **Prevalece sobre tudo**, inclusive sobre `docs/requisitos.md`.
3. `docs/specs/comum/`: contratos compartilhados (arquitetura, design system, navegação, dados e sync, regras, modelos matemáticos M1–M10).
4. O pacote da tarefa em `docs/specs/pacotes/` e a etapa correspondente em `docs/specs/plano-de-execucao.md`. A ordem vem das dependências em `docs/specs/dependencias.yaml`: uma tarefa só pode ser feita quando todas as dependências estão na `origin/dev`. **Antes de executar qualquer tarefa, use a skill `executar-entrega`**, que confere isso no GitHub; se estiver bloqueada, não implemente.
5. `docs/specs/pendencias.md`, para decisões já tomadas (P-01…) e parâmetros ainda em aberto.

Se a spec não cobre algo ou está em conflito, pergunte. Não invente comportamento, texto de tela nem parâmetro numérico.

Documentos antigos (`docs/justificativas.md` etc.) citam "Android nativo". Isso foi substituído pela stack abaixo.

## Stack

- Flutter estável + Dart 3, só Android, `minSdkVersion 26` (Android 8.0). iOS fora do escopo.
- Riverpod (estado/DI), go_router (4 abas com `StatefulShellRoute.indexedStack`), drift (SQLite local).
- Firebase (Auth, Firestore, Storage) **só para a cópia remota opcional**, enviada em lote e apenas pelo Wi-Fi.
- Nenhuma dependência além da lista em `docs/specs/comum/arquitetura.md` sem combinar com o grupo. O gráfico é `CustomPainter`, sem biblioteca.

## Regras de arquitetura (não negociáveis)

- **Offline-first**: o banco local é a fonte de verdade e o app funciona inteiro sem internet e sem conta.
- **Clean Architecture** por funcionalidade (`features/<x>/{domain,data,apresentacao}`), com dependências apontando só para dentro.
- **O domínio é Dart puro**: nunca importa Flutter, drift nem Firebase.
- Confirmação de salvamento só depois que a transação do drift terminar (sem UI otimista).
- Toda gravação chama `FilaSync.enfileirar` **na mesma transação**.
- Todo provider de dados é `.family` com `petId`.
- Persistência offline do Firestore desligada, e a rede do Firestore só é ligada pelo motor de sync quando há Wi-Fi.
- Nenhum componente visual novo se já existe equivalente em `lib/core/ui/`.
- Logs e notificações nunca expõem nome do pet, e-mail, pesos ou calorias (na notificação, só o nome do pet e o tipo de lembrete).

## Convenções

- Código, nomes de arquivos, classes e textos em **português** (ex.: `resultado.dart`, `apresentacao/`, `RegistrarRefeicao`), seguindo os nomes já usados nas specs.
- Textos de tela, formatos de data/número e mensagens seguem `docs/specs/comum/regras.md` exatamente.
- Aparência: `docs/design/telas/*.png` (exportação 2x, 780 px = 390 dp), medidas exatas em `docs/design/estrutura-page1.xml` e tokens em `docs/design/tokens.json`. Evite chamar o Figma: a conta está no plano Starter, sem cota, e tudo já foi exportado para `docs/design/`.
- Commits em [Conventional Commits](https://www.conventionalcommits.org/pt-br/), em português: `tipo(escopo): descrição`, com o código da tarefa do plano **no título** quando houver: `feat(diario): P2-1.3 formulário de refeição`. É pelo título que o `tool/dependencias.dart` sabe que a tarefa foi feita, então o código só vai **sozinho** no título do commit que conclui a tarefa. Commits intermediários levam `(parcial)` no título e não contam: `feat(diario): P2-1.3 (parcial) validação do formulário`. Tipos:

  | Tipo | Quando usar |
  |---|---|
  | `feat` | Funcionalidade nova |
  | `fix` | Correção de defeito |
  | `hotfix` | Correção urgente de algo que já está na `main` (a versão entregue), feita num branch `hotfix/<descrição>` a partir da `main` |
  | `refactor` | Mudança de código sem mudar comportamento |
  | `perf` | Melhoria de desempenho |
  | `test` | Só testes |
  | `docs` | Só documentação e specs |
  | `style` | Formatação, sem mudar código |
  | `build` | Gradle, `pubspec.yaml`, dependências |
  | `ci` | Integração contínua |
  | `chore` | Manutenção que não entra nos outros tipos |
  | `revert` | Desfaz um commit anterior |

  O escopo é a funcionalidade (`pets`, `diario`, `ui`, `banco`, `sync`…). Mudança incompatível leva `!` depois do escopo (`feat(banco)!: …`) e um rodapé `BREAKING CHANGE: …`.

## Testes

- `flutter test` precisa passar, incluindo os 5 testes oficiais T1–T5 (tabela no fim de `plano-de-execucao.md`).
- O domínio tem testes unitários, os componentes têm widget tests e as telas principais têm golden tests (390 × 844, fonte Inter carregada).
- Os testes de sincronização rodam no Firebase Local Emulator Suite (`integration_test/`), nunca no projeto real.

## Git

- Commits, push do branch de trabalho e abertura ou atualização de PR para a `dev` podem ser feitos.
- **Nunca fazer merge** de PR, nem push direto na `dev` ou na `main`. Quem aceita o PR é o grupo.
- **Material individual da revisão técnica fica só no computador de cada um:** diário de bordo, respostas das 10 perguntas e evidências pessoais vão na pasta `notas/` (ignorada pelo Git) e **nunca** são commitados, enviados ao GitHub nem copiados para `docs/` ou para a descrição de PR. Nunca use `git add -f` em `notas/`.
- **Sem assinatura do Claude** em commits e PRs: nada de `Co-Authored-By: Claude`, "Generated with Claude Code" ou equivalente.
- Para abrir ou editar PR, o `gh` precisa estar com uma conta que tenha escrita no repositório.
