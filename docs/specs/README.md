# Specs de construção — PetAmigo

Especificação para implementar o PetAmigo em **Flutter + Dart**, com **Clean Architecture**, **Riverpod**, **banco local como fonte de verdade (offline-first)** e **Firebase apenas para a cópia remota opcional**. Preparada em 19 e 20/11/2026 a partir do protótipo de alta fidelidade, de `docs/requisitos.md` e do enunciado da **Unidade II** (`unidade-2.md`).

## Como ler

1. Todo mundo lê `unidade-2.md` e a pasta `comum/` antes de começar. Elas definem o que o professor exige e o que é compartilhado entre os pacotes: arquitetura, design system, navegação, dados, regras e modelos matemáticos.
2. Cada integrante assume **um pacote** em `pacotes/` e implementa só o que está nele, respeitando os contratos de `comum/`, **na sua etapa do `plano-de-execucao.md`** e na ordem das dependências (`dependencias.yaml`).
3. Antes de entregar, cada um confere os critérios de aceite do próprio pacote e guarda as evidências pedidas.
4. `revisao-tecnica.md` explica como cada pessoa se prepara para a revisão técnica individual, registrando durante o trabalho o que precisará relatar depois.

## Fontes, em ordem de prioridade

| Fonte | Uso |
|---|---|
| Enunciado da Unidade II (`unidade-2.md`) | Exigências do professor. **Prevalece** sobre todo o resto. |
| `docs/requisitos.md` | Comportamento (RF/RNF) onde a Unidade II não mudou nada. |
| `docs/design/telas/*.png` | Aparência de cada tela (exportação 2x, 780 px = 390 dp). |
| `docs/design/estrutura-page1.xml` | Posição e tamanho exatos de cada elemento no Figma. |
| `docs/design/tokens.json` | Cores, espaçamento, raio, tipografia e medidas. |
| `docs/design/assets/` | Gato sorrindo (SVG), gráfico de referência (SVG), foto demonstrativa. |
| `docs/justificativas.md`, `docs/pesquisa.md` | Decisões de interface e fontes (NRC, AAHA, WSAVA). |
| Figma (cópia `Sv9iWaNvirMIgqW5PlxVwi`) | Consulta pontual. A conta usada está no plano Starter e com cota esgotada, então tudo o que importa já foi exportado. |

## Estrutura

```
docs/specs/
├── README.md                 ← este arquivo
├── unidade-2.md              exigências da Unidade II (U2-01 a U2-18) e conflitos resolvidos
├── plano-de-execucao.md      etapas, tarefas numeradas, regras dos PRs e os 5 testes oficiais
├── dependencias.yaml         do que cada tarefa depende (lido por tool/dependencias.dart)
├── comum/
│   ├── arquitetura.md        stack, Clean Architecture, pastas, notificações, o que é o Firebase
│   ├── design-system.md      tokens → tema Flutter; 7 componentes; gráfico interativo
│   ├── navegacao.md          4 destinos, diálogos (inclusive N1–N3) e fluxos
│   ├── dados-e-sync.md       banco local (vários pets), Firestore, fila, envio em lote e contratos
│   ├── regras.md             validações, textos, formatos, PDF e lembretes
│   └── modelos-matematicos.md  M1–M10: meta, peso ideal, curvas, projeção, previsão, indicadores, sugestões
├── pacotes/
│   ├── pacote-1-base-e-inicio.md
│   ├── pacote-2-diario.md
│   ├── pacote-3-atividades-e-compartilhamento.md   (atividades, lembretes e PDF)
│   ├── pacote-4-evolucao.md
│   └── pacote-5-privacidade-e-copia-remota.md
├── pendencias.md             decisões (P-01 a P-22), parâmetros a confirmar com o professor, itens só do protótipo
└── revisao-tecnica.md        preparação individual para a revisão técnica
```

## Divisão em pacotes

| Pacote | Escopo | Telas (PNG e novos) | Unidade II | Parte Firebase | Teste oficial | Responsável |
|---|---|---|---|---|---|---|
| 1 | Base em Clean Architecture, design system, navegação, Início, vários pets, meta diária | 01, 05, 18, 23, 26, N1 | U2-01, U2-06, U2-10, U2-14 | Projeto Firebase, inicialização, mapeador dos pets, fotos no Firestore, teste de integração | T1 | Matheus Leão |
| 2 | Diário: refeições, petiscos, alimentos, atalho, meta no diário, aderência | 02, 06, 07, 08, 09, 19, 20, 21, 22 | U2-01, U2-06, U2-11 (S1), U2-12 | **Firebase Emulator Suite do grupo**; mapeadores do diário; teste de integração | T2 | _a definir_ |
| 3 | Atividades, dicas, **lembretes com o app fechado**, **PDF** e exportação | 03, 10, 13, N2 | U2-04, U2-09, U2-11 (S2), U2-18 | Mapeadores de atividades e lembretes; teste de integração com reagendamento | T3 | paulofontes-cyber |
| 4 | Evolução: pesagens, **peso ideal, curvas de 90 dias, projeção adaptativa, data prevista, gráfico interativo**, indicadores | 04, 11, 12, 25, N3 | U2-02 a U2-08, U2-11 (S3), U2-12 | Mapeadores de pesagens e referências; teste de integração | T4 | _a definir_ |
| 5 | Privacidade, cópia remota, **sincronização em lote**, conflitos e exclusão integral | 14, 15, 16, 17 | U2-15, U2-16 | Auth, motor com `WriteBatch`, regras de segurança, exclusão remota | T5 | _a definir_ |

Cada integrante **escolhe** o próprio pacote, um por pessoa. Na primeira tarefa, a skill `executar-entrega` explica os pacotes e pergunta qual a pessoa assume. Sem o Claude Code: `dart tool/dependencias.dart responsaveis` mostra quem pegou o quê (inclusive escolhas ainda em PR) e `dart tool/dependencias.dart assumir P2` registra a escolha nesta tabela. Se duas pessoas escolherem o mesmo pacote, vale a escolha que chegar primeiro à `dev`.

A tela 24 ("Recurso do aparelho") só existe no protótipo. No app, ela vira os seletores nativos de foto (pacote 1) e de compartilhamento (pacote 3). Veja `pendencias.md`.

## Ordem de execução

As tarefas numeradas e a lista "pronta para passar" de cada pacote estão em **`plano-de-execucao.md`**. A ordem vem das **dependências entre tarefas** (`dependencias.yaml`): uma tarefa de qualquer pacote pode ser feita quando tudo de que ela depende já está na `dev`, com o PR aceito. Cada integrante continua fazendo o próprio pacote inteiro (código, parte Firebase, testes e evidências). Para saber se uma tarefa está liberada, use a skill `executar-entrega` no Claude Code ou rode `dart tool/dependencias.dart verificar P2-1.3`. Etapas por pacote:

```
Etapa 1  P1  base (feita), contratos da fila, pets, Início, meta M1, mapeador do pet
Etapa 2  P2  diário, liga o card Hoje no Início, Firebase Emulator Suite do grupo
Etapa 3  P3  atividades, lembretes com o app fechado, PDF, liga o card Lembretes
Etapa 4  P4  evolução, gráfico interativo, projeção, liga S3 e as curvas no PDF
Etapa 5  P5  privacidade, sync em lote, Firebase real de todas as coleções, 5 testes juntos
```

Quem vem antes usa stubs para o que ainda não existe; quem vem depois troca o stub pelo real e liga os próprios dados nas telas que já existem. Não há etapa só de testes.

**Antes das tarefas do P2 em diante:** levar ao professor a tabela de parâmetros P-17 a P-22 (`pendencias.md`), que o enunciado não define.

Regra de convivência: nenhum pacote cria um componente visual próprio se existe um equivalente em `core/ui`. Se faltar alguma variante, peça ao pacote 1.

Estado da implementação do P3, contratos de integração e bloqueios: [entrega-p3.md](entrega-p3.md).
