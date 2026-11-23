# Preparação para a revisão técnica individual

Cada pacote termina com um **rascunho das 10 respostas**, escrito a partir do que aquele pacote prevê. Ele serve de ponto de partida, não para ser entregue como está.

## Como adaptar o rascunho

1. **Troque tudo o que está entre colchetes** pelo que aconteceu com você: o trecho de código real, o resultado real do teste, a dificuldade que você teve de fato. Os exemplos entre colchetes só mostram o tipo de coisa que costuma aparecer naquele pacote. Se não aconteceu com você, não use.
2. **Apague o que você não fez.** Se uma funcionalidade da lista ficou com outra pessoa, tire.
3. **Confira contra as evidências.** Cada frase do tipo "testei" ou "verifiquei" precisa ter um print, uma saída de teste ou um commit seu que comprove.
4. **Reescreva com o seu jeito de falar.** Os rascunhos dos cinco pacotes têm a mesma estrutura; se ninguém mudar o texto, as cinco respostas vão parecer iguais.
5. **Pergunta 5 (Firebase):** cite só os serviços que você usou. Cada rascunho já cita apenas os serviços do próprio pacote.
6. **Perguntas 3 e 4:** a 3 depende da 4. Escreva a dificuldade (4) primeiro e depois a solução (3).

## Diário de bordo (preencher durante o trabalho)

Crie um arquivo seu (por exemplo `notas/diario-<nome>.md`, fora do app) e anote a cada sessão:

```markdown
## 2026-MM-DD
- O que fiz:
- Commit(s):
- Problema que apareceu:
- Como resolvi / o que testei:
- Evidência (print, saída de teste):
```

E sempre que usar IA para gerar código:

```markdown
### Código gerado por IA — <arquivo>
- O que pedi:
- O que veio (trecho):
- O que estava errado:
- Como corrigi (trecho final):
- Como verifiquei:
```

Com isso preenchido, as perguntas 1, 3, 4 e 10 praticamente se respondem sozinhas.

## Checklist para revisar código gerado por IA neste projeto

Pontos que já se sabe que vão contra os requisitos do PetAmigo. Vale conferir em todo código gerado.

| Conferir | Por quê |
|---|---|
| `height:` fixa em botão, campo ou navegação | Quebra com a fonte em 200% (RNF02). Use altura mínima |
| `maxLines: 1` ou `overflow: ellipsis` em rótulos | Esconde texto com fonte grande |
| Persistência do Firestore ligada, ou `set()` fora do motor de sync | Envia por dados móveis (RF15, RNF09) |
| Gravação sem transação, ou fila fora da transação | Pode perder dados ou deixar a fila inconsistente (RNF08) |
| `DELETE` direto de registro sincronizável | Precisa de lápide para a exclusão vencer (RF17) |
| Recalcular a refeição com a densidade atual do alimento | Altera o histórico (RF04) |
| Fórmula de meta diferente de `70 × P^0,75 × fator`, ou fatores fora da tabela de M1 | U2-01; os números precisam bater com o T1 |
| Divisão sem conferir o divisor (`Sxx`, `kgDia`, `Pinicial − Pi`, `max − min`) | U2-07: divisão por zero gera `Infinity`/`NaN` e quebra o gráfico |
| `ceil`/`floor` direto em resultado de ponto flutuante | `63,00000000000002` vira 64 dias (M5): arredonde para 6 casas antes |
| `DateTime.now()` dentro do domínio | Os testes deixam de ser repetíveis: receba `hoje` por parâmetro |
| Domínio importando Flutter, drift ou Firebase | Quebra a Clean Architecture (U2-14) |
| Provider sem `petId` ou tela lendo o "primeiro pet" | Mistura dados de pets diferentes (U2-10) |
| Botão "atualizar" ou `setState` manual para recalcular projeção | O recálculo deve vir dos streams (U2-05, M9) |
| `zonedSchedule` sem inicializar o fuso, ou lembrete com `Future.delayed`/`Timer` | Notificação no horário errado ou que morre com o app fechado (U2-09) |
| Texto de notificação com peso, kcal ou meta | Aparece na tela de bloqueio (R14) |
| Envio item por item com `set()` em vez de `WriteBatch` | U2-16 pede lote; e o lote precisa ser atômico |
| Dias vazios somados como 0 | Ausência de dados não é consumo zero (RF20); também distorce a aderência e a projeção |
| `double.parse("5,4")` | Falha com vírgula: normalize antes (R10) |
| `DateFormat` sem `initializeDateFormatting('pt_BR')` | Datas em inglês ou exceção |
| `print`/`log` com nome, e-mail ou valores | RNF04 |
| Celebração quando o pet se **afasta** do peso ideal, ou sem peso ideal | M8, RNF12 |
| Biblioteca nova não listada em `comum/arquitetura.md` (ex.: biblioteca de gráficos) | Combinar com o grupo antes; o gráfico deve ser leve |

## Evidências mínimas por pessoa

- Hash dos seus commits (`git log --author="<seu nome>" --oneline`).
- Saída de `flutter test` com os seus testes.
- Pelo menos um print ou vídeo de cada funcionalidade do seu pacote funcionando.
- Os prints pedidos em "Evidências para guardar" do seu pacote.
