---
name: executar-entrega
description: Verifica no GitHub se uma tarefa do plano do PetAmigo já pode ser feita (dependências em docs/specs/dependencias.yaml) e conduz a execução. Use SEMPRE que alguém pedir para fazer, implementar, executar, começar, continuar ou retomar uma tarefa do plano (código P1-1.6, P2-1.3 etc.), "a minha entrega", "a próxima tarefa" ou "o que posso fazer agora", antes de escrever qualquer código.
---

# Executar uma entrega do PetAmigo

As tarefas do `docs/specs/plano-de-execucao.md` não seguem mais uma fila fixa por pacote. Cada tarefa tem dependências diretas em `docs/specs/dependencias.yaml`, e só pode ser feita quando todas elas estiverem **na `origin/dev`** (PR aceito). Uma tarefa conta como feita quando o **título** de um commit na `origin/dev` tem o código dela.

## 1. Identificar a tarefa

- Se o pedido tem um código (`P2-1.3`), use-o. Mais de um código: verifique todos.
- Se não tem ("minha entrega", "próxima tarefa"), rode `dart tool/dependencias.dart proximas` (ou `proximas P2` se o pacote for conhecido), mostre a lista e pergunte qual fazer. Não escolha sozinho.

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

## 3. Avisar quando a tarefa é de outro pacote

O pacote é o prefixo do código (`P3-0.2` → pacote 3). Se a pessoa está fazendo uma tarefa de outro pacote, diga isso e lembre que a revisão técnica é individual (`plano-de-execucao.md` → Revisão técnica individual): o ideal é combinar com o dono, que está na tabela "Divisão em pacotes" do `docs/specs/README.md`. Isso não bloqueia.

## 4. Preparar

- **Branch**: trabalho novo parte da `dev` atualizada (`git switch -c p2/diario origin/dev`). Se a verificação deu "LIBERADA NESTE BRANCH", continue no branch atual. Nunca trabalhe direto na `dev` nem na `main`.
- **Specs**, na ordem do `CLAUDE.md`: `docs/specs/README.md` → `unidade-2.md` → `comum/` → o pacote da tarefa em `pacotes/` → a linha da tarefa no `plano-de-execucao.md` → `pendencias.md`. Se a spec não cobre algo ou está em conflito, pergunte.

## 5. Implementar

Siga o `CLAUDE.md` (arquitetura, convenções, textos de tela, testes). No fim:

- `flutter analyze` sem avisos e `flutter test` passando.
- Commit em Conventional Commits, em português, com **o código da tarefa no título**: `feat(diario): P2-1.3 formulário de refeição`. Sem o código no título, a tarefa nunca conta como feita.
- Tarefas de verificação manual (emulador, TalkBack, Network Inspector) também terminam com um commit que tenha o código no título, guardando a evidência.
- **Nunca dar push.** Quem envia é o usuário.

## 6. Fechar

Rode `dart tool/dependencias.dart verificar <código> --sem-fetch` para confirmar que aparece "JÁ FEITA NESTE BRANCH" e diga ao usuário:

- a tarefa só libera as que dependem dela quando o PR chegar à `dev`;
- quais tarefas ela vai liberar (as linhas do `dependencias.yaml` que a citam);
- a nota de passagem do PR (stubs criados ou trocados, pendências), como pede a regra 6 do plano.
