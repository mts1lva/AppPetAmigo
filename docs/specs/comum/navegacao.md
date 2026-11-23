# Navegação

## Destinos principais (RNF10)

Quatro abas, nesta ordem, numa `StatefulShellRoute.indexedStack`. Cada aba guarda a própria posição de rolagem.

| Aba | Rota | Tela base | Pacote |
|---|---|---|---|
| Início | `/inicio` | 01 | P1 |
| Diário | `/diario` | 02 (layout único; o 21 só muda o título, ver P-05) | P2 |
| Atividades | `/atividades` | 03 | P3 |
| Evolução | `/evolucao` | 04 | P4 |

Não existe quinta tela, tela de configurações ou onboarding extenso. Todo o resto é **diálogo** (`PaDialogo`) aberto por cima da aba atual.

Exceção: sem pet cadastrado, a rota inicial mostra o estado vazio **26 "Vamos começar?"** no lugar do conteúdo do Início, e a navegação inferior **fica oculta** até o cadastro ser salvo.

## Mapa de diálogos

```
INÍCIO (01)
├─ Toque no cabeçalho do pet (foto/nome) ─► N1 Seus pets                                    [U2-10]
│                                     ├─ toque num pet ─► vira o pet atual; fecha
│                                     └─ Cadastrar outro pet ─► 05 Dados do pet (cadastro)
├─ Editar pet ─────────────────────► 05 Dados do pet ── Adicionar ou trocar foto ─► seletor nativo
│                                     └─ Excluir este pet (só com 2+ pets) ─► 23 Confirmar exclusão
├─ Registrar refeição ─────────────► 06 Registrar refeição
│                                     ├─ Confirmar refeição ─► 20 Refeição salva
│                                     │                          └─ Consultar diário atualizado ─► aba Diário, título "Diário atualizado"
│                                     └─ Alterar dados ──────► 07 Refeição (já preenchida)
├─ Sugestão (card) ── Ver ─────────► aba indicada (Diário, Atividades ou Evolução)            [U2-11]
│                  └─ Agora não ──► esconde por 7 dias
├─ Configurar lembretes ───────────► N2 Lembretes de {nome} ─ horário ─► time picker nativo  [U2-09]
├─ Entender a referência ──────────► 18 Como a meta é calculada ─ Voltar ao perfil ─► fecha  [U2-01]
└─ Privacidade e cópia remota ─────► 14 Seus dados
                                      ├─ Cópia remota opcional ─► 15 (desligada) ou 16 (ligada)
                                      │                           16 ─ Resolver conflito ─► 17 Conferir versões
                                      ├─ Exportar dados ────────► seletor nativo de compartilhamento
                                      └─ Excluir todos os dados ─► 23 Confirmar exclusão (modo integral)

DIÁRIO (02)
├─ Selecionar data ────────────────► date picker nativo ─► mostra a data escolhida
│                                     └─ sem registros ─► 19 Consultar outra data ─ Retomar registro hoje
├─ Linha de refeição / Editar refeição ─► 07 Refeição ─ Excluir registro ─► 23 Confirmar exclusão
├─ Linha de petisco / Editar petisco ──► 08 Petisco ou extra ─ Excluir registro ─► 23
├─ Adicionar petisco ──────────────► 08 Petisco ou extra (vazio)
├─ Adicionar refeição (dia sem refeição) ─► 07 Refeição (vazio)
└─ Gerenciar alimentos ────────────► 09 Alimentos e porções
                                      ├─ densidade inválida ─► 22 Confira a densidade
                                      └─ Excluir alimento e porção ─► 23

ATIVIDADES (03)
├─ Linha / Editar atividade ───────► 10 Passeio ou brincadeira ─ Excluir registro ─► 23
└─ Registrar atividade ────────────► 10 (vazio)

EVOLUÇÃO (04)
├─ Arrastar o dedo no gráfico ─────► mostra o valor do dia sob o dedo (sem abrir diálogo)       [U2-02]
├─ Linha / Editar pesagem ─────────► 11 Pesagem ─ Excluir registro ─► 23
│                                     ├─ variação suspeita ao salvar ─► 25 Conferir pesagem
│                                     └─ salvou e se aproximou ≥ 100 g do ideal ─► N3 Pesagem salva (celebração)
├─ Editar peso inicial ────────────► 11 Pesagem (primeira pesagem do pet)                       [U2-06]
├─ Registrar peso ─────────────────► 11 (vazio) → 25 se suspeita → N3 se celebrar
├─ Atualizar referências ──────────► 12 ECC e objetivo
└─ Compartilhar resumo ────────────► 13 Compartilhar resumo ─ Abrir compartilhamento ─► PDF no seletor nativo [U2-18]

NOTIFICAÇÃO (app fechado ou aberto)
└─ toque ─► abre o app no pet do lembrete ─► 06, 11 ou 10 conforme o tipo                       [U2-09]
```

Diálogos novos da Unidade II (não existem no protótipo; seguem o padrão do `PaDialogo`):

| Código | Diálogo | Pacote |
|---|---|---|
| N1 | Seus pets | P1 |
| N2 | Lembretes de {nome} | P3 |
| N3 | Pesagem salva (celebração) | P4 |

Diálogos abertos a partir de outro diálogo **substituem** o anterior: fecham o de origem e abrem o novo. Assim nunca há dois diálogos empilhados. A exceção é **23 Confirmar exclusão**, que abre por cima do formulário e, ao confirmar, fecha os dois.

## Fluxo habitual (RNF01): dois toques

```
Início ──(1) Registrar refeição──► 06 ──(2) Confirmar refeição──► grava ─► 20 Refeição salva
```

- Pré-condição: existe pelo menos um alimento não arquivado com porção configurada. O atalho usa o **alimento da refeição mais recente** ou, se ainda não houver refeição, o último alimento cadastrado (pacote 2).
- Sem nenhum alimento, o botão "Registrar refeição" abre direto o 09 Alimentos e porções, com o subtítulo "Cadastre o alimento para usar o atalho."
- Diário a partir do Início: um toque na aba (RNF01 pede no máximo três).

## Botão voltar do Android

| Situação | Comportamento |
|---|---|
| Diálogo aberto | Fecha o diálogo sem salvar |
| Aba ≠ Início | Vai para a aba Início |
| Aba Início | Sai do app |

## Estados que trocam a tela inteira

| Estado | O que aparece |
|---|---|
| Sem nenhum pet | 26 "Vamos começar?" sem navegação |
| Pet atual excluído (havia outros) | O pet atual passa a ser o primeiro da lista, por ordem de cadastro |
| Exclusão integral concluída localmente | Volta ao 26. Se a remoção remota estiver pendente, o 26 mostra a mensagem extra "Remoção da cópia remota pendente: será concluída no próximo Wi-Fi." (P5) |
