---
name: executar-entrega
description: Prepara o ambiente, ajuda a pessoa a escolher o pacote, verifica no GitHub se uma tarefa do plano do PetAmigo já pode ser feita (dependências em docs/specs/dependencias.yaml) e conduz a execução. Use SEMPRE que alguém pedir para fazer, implementar, executar, começar, continuar ou retomar uma tarefa do plano (código P1-1.6, P2-1.3 etc.), "a minha entrega", "quero começar", "a próxima tarefa" ou "o que posso fazer agora", antes de escrever qualquer código.
---

# Executar uma entrega do PetAmigo

As tarefas do `docs/specs/plano-de-execucao.md` não seguem mais uma fila fixa por pacote. Cada tarefa tem dependências diretas em `docs/specs/dependencias.yaml`, e só pode ser feita quando todas elas estiverem **na `origin/dev`** (PR aceito). Uma tarefa conta como feita quando o **título** de um commit na `origin/dev` tem o código dela.

## Antes de tudo: preparar o ambiente

Rode `flutter --version` e `git config user.name`.

**Flutter ausente** ("command not found" ou "não é reconhecido") **ou em outra versão**: não siga adiante. A versão do grupo e da CI é a **3.50.1 (stable)**. Pergunte o sistema da pessoa, se não souber, e explique a instalação em passos curtos, um de cada vez, esperando a pessoa confirmar:

- **Windows**
  1. Baixar o zip do Flutter **3.50.1** para Windows em https://docs.flutter.dev/release/archive (aba Windows, canal stable).
  2. Extrair para uma pasta **sem espaços nem acentos**, por exemplo `C:\dev\flutter`. Caminho com acento ou espaço (como uma pasta de usuário com "ã") quebra o Gradle do Android.
  3. Pôr `C:\dev\flutter\bin` no Path: menu Iniciar → "Editar as variáveis de ambiente para sua conta" → Path → Editar → Novo.
  4. Fechar e abrir de novo o terminal **e o Claude Code**, e conferir `flutter --version`.
- **macOS**: baixar o zip 3.50.1 do macOS (Apple Silicon ou Intel) na mesma página, extrair em `~/dev/flutter`, acrescentar `export PATH="$HOME/dev/flutter/bin:$PATH"` ao `~/.zshrc` e abrir um terminal novo.
- **Linux**: baixar o `.tar.xz` 3.50.1, extrair em `~/dev/flutter` e pôr `~/dev/flutter/bin` no PATH do `~/.bashrc`.

Se a pessoa preferir, ofereça fazer os passos por ela, pedindo permissão para cada comando (o download tem cerca de 1 GB).

Com o Flutter certo:
- Rode `flutter pub get` na pasta do projeto.
- O Android SDK e o emulador **não** são necessários agora: os testes rodam sem eles. Avisos do `flutter doctor` sobre o Android podem ser ignorados até a pessoa querer abrir o app no emulador.
- **`git config user.name` vazio**: pergunte o nome da pessoa e rode `git config user.name "Nome"` (é o nome que vai para a tabela de responsáveis). Confira também o `git config user.email`.
- O `gh` (GitHub CLI) é opcional para verificar tarefas, mas necessário para abrir PR. Se faltar, explique na hora do PR (passo 7): instalar em https://cli.github.com e rodar `gh auth login`.

## 0. Seu pacote

Cada integrante escolhe o pacote pelo qual se responsabiliza. Ninguém recebe um pacote pronto. Antes de qualquer tarefa, rode:

```
dart tool/dependencias.dart responsaveis
```

A última linha diz quem é a pessoa (pelo `git config user.name`) e o pacote dela.

- **`VOCÊ (Nome): P2`**: siga para o passo 1.
- **`VOCÊ (Nome): sem pacote`**: **não execute nada ainda.** Primeiro apresente os pacotes e pergunte qual ela assume:
  1. Para **cada pacote**, explique em 2 ou 3 linhas simples, sem jargão: o que ele constrói (escopo), as telas, a parte Firebase, o teste oficial, o progresso e se já tem responsável. Use a saída do `responsaveis`. Se precisar de mais contexto, leia o começo do `docs/specs/pacotes/pacote-N-*.md` (linhas "Requisitos", "Depende de" e "Entrega para").
  2. Diga que cada pessoa assume **um** pacote e responde sozinha à revisão técnica sobre ele (código, parte Firebase, testes e evidências).
  3. Pergunte qual pacote a pessoa assume, oferecendo **só os livres**. Use a ferramenta de perguntas se houver até 4 livres; se houver mais, pergunte em texto. Pacote com escolha "pendente" em outro branch ou PR já está tomado. Não escolha pela pessoa.
  4. Confirme o nome que vai para o README (o do `git config user.name`, ou outro que a pessoa disser) e registre:
     ```
     dart tool/dependencias.dart assumir P2 ["Nome"]
     ```
     O script recusa pacote já escolhido por outra pessoa e segunda escolha da mesma pessoa.
  5. Faça o commit `docs(specs): <Nome> assume o pacote N` e dê push no branch, para os colegas verem a escolha pelo `responsaveis` mesmo antes do merge. Ela vai junto no PR do branch.
- **`CONFLITO`** num pacote: duas pessoas o escolheram em branches diferentes. Avise e peça para combinarem; vale a escolha que chegar primeiro à `dev`.

## 1. Identificar a tarefa

- Se o pedido tem um código (`P2-1.3`), use-o. Mais de um código: verifique todos.
- Se não tem ("minha entrega", "próxima tarefa"), rode `dart tool/dependencias.dart proximas <pacote da pessoa>`, mostre a lista e pergunte qual fazer. Não escolha sozinho.

## 2. Verificar no GitHub

```
dart tool/dependencias.dart verificar <código>
```

O script atualiza do GitHub (`git fetch`), confere a `origin/dev`, o branch atual e os branches remotos, e usa o `gh` para mostrar os PRs abertos. Mostre a saída ao usuário e siga pelo código de saída:

| Saída | Significado | O que fazer |
|---|---|---|
| 0, `LIBERADA` | Todas as dependências na dev | Seguir para o passo 3 |
| 0, `LIBERADA NESTE BRANCH` | Alguma dependência só está no branch atual | Seguir, **neste branch**, avisando que quem depender desta tarefa só começa depois do merge |
| 1, `BLOQUEADA` | Falta dependência | **Parar. Não implementar nada**, nem parte da tarefa, nem um stub "para adiantar". Dizer o que falta e onde está cada dependência (PR aberto, outro branch, não iniciada) e rodar `proximas <pacote>` para sugerir o que está liberado |
| 2, `JÁ FEITA` | A tarefa já está na dev ou neste branch | Avisar e parar. Se o usuário quer corrigir algo nela, é um `fix(...)` com o mesmo código, não uma nova execução |
| 64 ou 70 | Uso errado ou erro de git | Mostrar o erro. Se faltar a `origin/dev`, rodar `git fetch origin` |

Se o aviso "sem rede" aparecer, diga que a verificação usou o último estado baixado.

Se uma dependência parecer errada (a tarefa claramente não precisa dela), **não ignore o bloqueio**: aponte o problema e proponha mudar a linha no `dependencias.yaml`, o que é uma decisão do grupo.

## 3. Tarefa de outro pacote

O pacote é o prefixo do código (`P3-0.2` → P3). Se não é o pacote da pessoa (passo 0):

- **Tem responsável**: diga de quem é e pergunte se foi combinado com essa pessoa. A revisão técnica é individual, então fazer a tarefa de um colega tira dele o que mostrar. Só siga se a pessoa confirmar.
- **Sem responsável**: avise que a tarefa é de um pacote que ninguém assumiu e pergunte se ela quer seguir mesmo assim.

## 4. Preparar

- **Branch**: trabalho novo parte da `dev` atualizada (`git switch -c p2/diario origin/dev`). Se a verificação deu "LIBERADA NESTE BRANCH", continue no branch atual. Nunca trabalhe direto na `dev` nem na `main`.
- **Specs**, na ordem do `CLAUDE.md`: `docs/specs/README.md` → `unidade-2.md` → `comum/` → o pacote da tarefa em `pacotes/` → a linha da tarefa no `plano-de-execucao.md` → `pendencias.md`. Se a spec não cobre algo ou está em conflito, pergunte.

## 5. Implementar

Siga o `CLAUDE.md` (arquitetura, convenções, textos de tela, testes). No fim:

- `flutter analyze` sem avisos e `flutter test` passando.
- Commit em Conventional Commits, em português, com **o código da tarefa no título** do commit que a **conclui**: `feat(diario): P2-1.3 formulário de refeição`. Sem o código no título, a tarefa nunca conta como feita.
- Se a tarefa for dividida em vários commits, os intermediários levam `(parcial)` no título (`feat(diario): P2-1.3 (parcial) validação`). Eles não contam como conclusão, então não liberam quem depende da tarefa antes da hora.
- Tarefas de verificação manual (emulador, TalkBack, Network Inspector) também terminam com um commit que tenha o código no título, guardando a evidência.
- Sem assinatura do Claude no commit (nada de `Co-Authored-By`).

## 6. Diário de bordo

A revisão técnica é individual e pede, na pergunta 1, o código gerado por IA e o que foi corrigido nele (`docs/specs/revisao-tecnica.md` → Diário de bordo). Como este código saiu do Claude, **ofereça a entrada pronta** para a pessoa colar no diário dela, em `notas/diario-<nome>.md` (não crie o arquivo sem ela pedir).

**O diário é individual e nunca vai para o GitHub.** A pasta `notas/` está no `.gitignore`. Nunca faça commit dela (nem com `git add -f`) e nunca copie o conteúdo para `docs/` ou para a descrição do PR. Antes de cada commit, confira com `git status` que nada de `notas/` aparece.

Modelo:

```markdown
## AAAA-MM-DD
- O que fiz: <tarefa e o que foi entregue>
- Commit(s): <hashes>
- Problema que apareceu: <o que deu errado de verdade nesta sessão>
- Como resolvi / o que testei: <testes rodados e resultado>
- Evidência (print, saída de teste): <o que guardar>

### Código gerado por IA — <arquivo principal>
- O que pedi:
- O que veio (trecho):
- O que estava errado:
- Como corrigi (trecho final):
- Como verifiquei:
```

Preencha só com o que aconteceu na sessão: erros reais de análise, testes que falharam, correções feitas. Se nada deu errado, diga isso em vez de inventar um problema.

## 7. Fechar e abrir o PR

1. Rode `dart tool/dependencias.dart verificar <código> --sem-fetch` e confira que aparece "JÁ FEITA NESTE BRANCH".
2. Liste o que a tarefa libera: as linhas do `dependencias.yaml` que citam o código.
3. **PR para a `dev`.** Push do branch e abertura ou atualização do PR podem ser feitos (o `gh` precisa de uma conta com escrita). Se o branch já tem PR aberto, atualize a descrição em vez de abrir outro. A descrição leva a **nota de passagem** (regra 6 do plano):

   ```markdown
   ## Tarefas entregues
   | Tarefa | O que entrou |
   ## Stubs criados ou trocados
   ## O que estas tarefas liberam
   ## Pendências
   ## Como testar
   flutter analyze / flutter test / dart tool/dependencias.dart validar
   ```

   Lembre na descrição que o PR deve ser aceito com "Create a merge commit" ou "Rebase and merge", **nunca "Squash and merge"**.
4. **Nunca fazer merge.** Quem aceita o PR é o grupo. Diga ao usuário que as tarefas só liberam quem depende delas depois do merge na `dev`.
