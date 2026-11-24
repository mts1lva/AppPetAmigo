# Pacote 5 — Privacidade, cópia remota e sincronização

**Responsável:** ______________________

## Objetivo

Entregar os controles de privacidade e toda a **cópia remota opcional**: conta Firebase só para quem ativar, fila de sincronização que **só transmite por Wi-Fi**, estados visíveis, conflitos resolvidos pelo tutor e **exclusão integral** local e remota.

**Requisitos:** RF15, RF16, RF17, RNF04, RNF05, RNF08, RNF09 · **Unidade II:** U2-10 (todos os pets na cópia), U2-15, U2-16 (sincronização em lote via Wi-Fi), teste oficial T5.
**Depende de:** P1 (base, Firebase inicializado), P2 (Firebase Emulator Suite, P2-2.3, para testar regras e motor), P3 (`AgendadorNotificacoes.cancelarTodos` e `ReagendarTodos`). **Entrega para:** todos (o motor, que chama os mapeadores de cada pacote, e os testes de integração de todas as coleções rodando, P5-3.7). Os contratos `FilaSync` e `MapeadorSync` (P5-0.1) são feitos pelo P1 na etapa 1, porque todos gravam pela fila desde o início.

**Ordem de execução:** **etapa 5** do `plano-de-execucao.md`, na ordem das dependências (`dependencias.yaml`); várias tarefas dela dependem de todos os outros pacotes. Primeiro o motor é construído e testado contra um **remoto falso em memória** (T5); depois entra o Firebase real, já com os mapeadores de todos os pacotes prontos. A etapa fecha o projeto: testes de integração de todas as coleções e os 5 testes oficiais juntos.

## Componentes de código

| Arquivo | Responsabilidade |
|---|---|
| `data/sync/fila_sync.dart` | Implementa `FilaSync.enfileirar` (`comum/dados-e-sync.md`); com a cópia desligada, não faz nada |
| `data/sync/wifi.dart` | Stream `estaNoWifi` com `connectivity_plus`; liga e desliga a rede do Firestore |
| `data/sync/motor_sync.dart` | Ciclos de **envio em lote** (U2-16) e recebimento, versões, lápides, conflitos, novas tentativas (`dados-e-sync.md` → Envio em lote) |
| `data/sync/firebase_remoto.dart` | Única classe que fala com `cloud_firestore`, `firebase_auth` e `firebase_storage` (facilita usar um falso nos testes) |
| `data/sync/exclusao_integral.dart` | RF17 de ponta a ponta |
| `firestore.rules`, `storage.rules` | Regras de `comum/dados-e-sync.md`, publicadas com `firebase deploy --only firestore:rules,storage` |

Providers expostos: `estadoCopiaProvider` (desligada / pendente(n) / sincronizado(hora) / falha / conflito(n)), usado pelo card "Seu controle" do Início (P1).

## Telas

### 14 — Seus dados (`docs/design/telas/14-seus-dados.png`)

Diálogo aberto pelo Início. Título `Seus dados`, subtítulo `O uso essencial funciona sem conta.`
Texto: `Perfil, foto e registros servem ao acompanhamento de {nome}. Ficam neste aparelho. Você controla a exportação e a exclusão. Cópia remota é opcional.`
Botões: `primario` **Cópia remota opcional** → 15 · `primario` **Exportar dados** (usa o `GeradorExportacao` do P3 e o `share_plus`) · `perigo` **Excluir todos os dados** → 23 em modo integral · `secundario` **Voltar**.

### 15 — Cópia remota opcional (`15-copia-remota-opcional.png`)

Título `Cópia remota opcional`, subtítulo `A conta só é necessária para esta opção.`

| Situação | Campos | Botões |
|---|---|---|
| Desligada | E-mail (texto) · Senha (texto oculto, mínimo de 6 caracteres) | `primario` **Ativar e aguardar Wi-Fi** · `secundario` **Voltar** |
| Ligada | E-mail (somente leitura, o da conta) | `primario` **Ver situação da cópia** → 16 (botão novo, não está no protótipo; P-16) · `primario` **Desativar cópia** · `secundario` **Voltar** |

Texto: `Sincronização só por Wi-Fi; o uso local continua livre.` ("Autenticação simulada." era só do protótipo.)

**Ativar e aguardar Wi-Fi:**
1. Sem Wi-Fi: o campo E-mail não muda e aparece a mensagem `Conecte-se a um Wi-Fi para ativar.` Nada é enviado pela rede móvel.
2. Com Wi-Fi: `enableNetwork()`, depois `createUserWithEmailAndPassword`. Se o erro for `email-already-in-use`, usa `signInWithEmailAndPassword`. Testar os dois caminhos contra a proteção de enumeração de e-mails do Firebase.
3. Sucesso: grava `uid` e `copiaRemotaAtiva = true` em `config`. Se o banco local tem dados, **enfileira todos os registros de todos os pets** (primeiro envio, em lotes). Se está vazio e `exclusaoRemotaPendente = false`, faz o **pull completo** (restauração de todos os pets) e, no fim, chama `ReagendarTodos` (P3) para recriar os lembretes.
4. Abre o 16. A senha nunca é gravada.

**Desativar cópia** (P-09): abre uma confirmação (`PaDialogo`) com o título `Desativar cópia remota`, o texto `A cópia já enviada continua guardada na sua conta. Para apagá-la, use Excluir todos os dados.` e os botões `primario` **Desativar** e `secundario` **Cancelar**. Ao confirmar: `signOut`, limpa a fila, marca todos os registros como `estadoSync = 'local'` e grava `copiaRemotaAtiva = false`. Os dados locais não mudam. Reativar com a mesma conta envia de novo o que mudou, sem duplicar, porque os IDs são os mesmos.

### 16 — Cópia remota (`16-copia-remota.png`)

Título `Cópia remota`. Subtítulo: `Local salvo • {aguardando Wi-Fi | sincronizando | atualizado às HH:mm}`.
Texto fixo: `Pendente: alterações na fila.` / `Sincronizado: cópia atualizada.` / `Falha: dados locais preservados.`
- `primario` **Resolver conflito** → 17, só quando há conflito.
- **Uma** `PaMensagem` com o estado atual. No protótipo aparecem as três de uma vez só para demonstrar. Textos:
  - `pendente: {n} alterações na fila`
  - `sincronizado: cópia atualizada às {HH:mm}`
  - `falha: dados locais preservados. Nova tentativa no próximo Wi-Fi.`
- `primario` **Tentar agora**, só quando o estado é falha e há Wi-Fi (botão novo, não está no protótipo; P-16).
- `secundario` **Voltar**.

### 17 — Conferir versões (`17-conferir-versoes.png`)

Um conflito por vez. Título `Conferir versões`, subtítulo `A mesma {nomeRegistro} foi editada em dois aparelhos.`
Texto: `Neste aparelho: {resumoConflito(local)}` / `Na cópia: {resumoConflito(remoto)}` / `Escolha a versão. Exclusões confirmadas têm precedência.`
Botões: `primario` **Manter versão local** · `primario` **Usar versão da cópia** · `secundario` **Voltar** (o conflito continua pendente).
Comportamento das escolhas: `comum/dados-e-sync.md` → Conflito.

### Teste oficial T5 — envio em lote (U2-16)

`test/sync/lote_test.dart`, com o `FakeRemoto` em memória:
- 5 registros de 2 pets na fila → **um** commit com 5 escritas; fila vazia; todos `sincronizado`.
- O mesmo registro editado 3 vezes antes do ciclo → **uma** escrita só, com o conteúdo final.
- Falha no commit (o `FakeRemoto` lança exceção) → nenhum documento gravado, nenhum item sai da fila, todos `falha`, `tentativas = 1`.
- Repetir o lote depois de um commit que deu certo sem confirmação → nenhum documento duplicado e nenhum conflito falso (regra do `dispositivoId`).
- Item com versão remota de outro aparelho → vira conflito e **fica fora** do lote, sem impedir os outros.
- Mais de 500 operações → dividido em lotes de até 500.

### Exclusão integral (23 em modo integral)

1. 14 → **Excluir todos os dados** → `confirmarExclusao(integral: true)` (componente do P2).
2. Confirmou: executa o RF17 (`comum/dados-e-sync.md` → Exclusão integral).
3. O app volta ao **26 "Vamos começar?"**. Com remoção remota pendente, o 26 mostra também `Remoção da cópia remota pendente: será concluída no próximo Wi-Fi.` Quando confirmar: `Remoção da cópia remota concluída.`
4. Enquanto `exclusaoRemotaPendente = true`, ativar a cópia **não restaura nada**.

## Regras de transmissão (RNF09)

- `persistenceEnabled: false` e `disableNetwork()` na inicialização (feito pelo P1). **Só este pacote chama `enableNetwork()`**, e somente dentro de um ciclo no Wi-Fi.
- Wi-Fi caiu no meio do ciclo: `disableNetwork()`, cancela uploads do Storage, os itens continuam na fila e o próximo ciclo recomeça do primeiro item. IDs estáveis + versões garantem que **repetir não duplica**.
- Nova tentativa após falha: no próximo gatilho (Wi-Fi conectar, app voltar ao primeiro plano ou "Tentar agora"). Sem laço de repetição em segundo plano.

## Critérios de aceite

- [ ] Sem ativar a cópia, o app nunca fala com o Firebase (conferir com o Network Inspector do Android Studio).
- [ ] Ativar com dados móveis não envia nada e mostra a mensagem.
- [ ] Criar 3 registros offline → Wi-Fi → aparecem no Firestore, estado `sincronizado`.
- [ ] Derrubar o Wi-Fi no meio do envio e religar: nenhum documento duplicado.
- [ ] Editar o mesmo registro em dois aparelhos (ou no app e no console) → 17 aparece; as duas escolhas funcionam.
- [ ] Excluir num aparelho e editar no outro → a exclusão vence.
- [ ] Usuário A não lê nem grava em `usuarios/{uidB}` (teste das regras no Emulator Suite).
- [ ] Exclusão integral offline → local vazio na hora, remoto pendente; no Wi-Fi → remoto vazio, conta apagada e mensagem de conclusão.
- [ ] Depois da exclusão integral, ativar a cópia num aparelho novo não traz nada de volta.
- [ ] Logs de release sem e-mail, uid, nome do pet ou valores.
- [ ] Com 3 pets e 300 registros offline, ao conectar no Wi-Fi a cópia sobe em lotes (conferir no console que chegam juntos) e o estado fica `sincronizado`.
- [ ] Exclusão integral cancela todos os lembretes agendados (nenhuma notificação chega depois).
- [ ] T5 passa.

## Evidências para guardar

Testes do motor com o remoto falso; testes das regras no Firebase Emulator Suite; prints do Network Inspector em modo avião, dados móveis e Wi-Fi; print do console antes e depois da exclusão integral; vídeo do conflito; hash dos commits.

## Rascunho para a revisão técnica

> Rascunho escrito a partir do que este pacote prevê. **Substitua tudo o que está entre colchetes pelo que aconteceu de verdade** e apague o que você não fez.

**1. Código gerado por IA que precisou ser corrigido**
Pedi para a IA gerar a configuração do Firestore e o envio dos registros. O trecho que precisei corrigir foi [colar o trecho real]. [Exemplo do tipo de problema neste pacote: o código deixava a persistência offline do Firestore ligada, que é o padrão no Android, e gravava direto com `set()`. Com isso, o próprio SDK reenviava as alterações assim que aparecia qualquer rede, inclusive dados móveis, o que quebra o requisito de sincronizar só por Wi-Fi.] Ajustei [desligando a persistência, deixando a rede do Firestore desligada por padrão e ligando só dentro do ciclo de sync no Wi-Fi] e conferi [no Network Inspector com dados móveis: nenhum tráfego].

**2. Conhecimentos da disciplina aplicados**
Usei integração com backend em nuvem (Firebase Authentication, Firestore e Storage), persistência local com transações, programação assíncrona com `Future` e `Stream` (fila, estado da conexão, ciclo de sincronização) e segurança, com as regras de acesso por usuário. Também usei conceitos de conectividade em dispositivos móveis, tratando o app como offline-first. [Ajustar para os nomes da disciplina.]

**3. Solução para a dificuldade**
Montei uma fila própria no banco local, gravada na mesma transação de cada registro, e um motor que só liga a rede do Firestore quando o `connectivity_plus` informa Wi-Fi. O envio é em lote: leio as versões remotas de até 100 itens, separo os conflitos e gravo o resto num único `WriteBatch`, que é atômico (ou grava tudo, ou nada). Cada documento usa o mesmo ID do registro local e um número de versão, então reenviar não duplica, e uma versão diferente da esperada vira conflito em vez de sobrescrever. Verifiquei [derrubando o Wi-Fi no meio do envio, alternando para dados móveis e repetindo a fila: resultado].

**4. Maior dificuldade técnica**
A maior dificuldade foi garantir que a sincronização acontecesse só por Wi-Fi e sem duplicar nem perder dados. O Firestore foi feito para sincronizar sozinho em qualquer rede, e o requisito pede o contrário: tudo local primeiro e envio só no Wi-Fi, com os estados pendente, sincronizado e falha visíveis. Isso apareceu [quando liguei o motor de sync pela primeira vez] e [descrever o que aconteceu: envio por dados móveis, documentos duplicados, conflito sobrescrito etc.].

**5. Uso do Firebase**
No PetAmigo o Firebase é só a cópia remota opcional: sem ativá-la, o app nunca fala com a nuvem. Eu usei o Firebase Authentication com e-mail e senha para identificar o tutor que ativa a cópia, o Cloud Firestore para guardar a cópia dos registros em `usuarios/{uid}`, as regras de segurança para que cada usuário só acesse os próprios dados e o Cloud Storage na exclusão integral, para apagar a foto. [Citar o Emulator Suite se você usou nos testes.]

**6. Principal contribuição individual**
Fiz a cópia remota e a privacidade. O resultado concreto é que o app continua funcionando sem conta e sem internet, mas quem quiser pode guardar uma cópia que só sincroniza no Wi-Fi, ver se ela está pendente, sincronizada ou com falha, resolver conflitos entre aparelhos e apagar tudo, local e remoto, com a exclusão integral.

**7. Fluxo de dados com o Firebase**
Quando qualquer tela grava um registro, o repositório grava no banco local e, na mesma transação, chama a minha fila, que guarda tabela, ID e operação. Quando o Wi-Fi conecta, o motor liga a rede do Firestore e monta um lote com até 100 itens da fila, juntando edições repetidas do mesmo registro. Ele lê as versões remotas desses documentos, separa os que viraram conflito (versão remota diferente da esperada, que vão para a tela "Conferir versões") e grava todo o resto num único `WriteBatch`, usando o mapeador de cada tipo de registro. Se o commit falhar, nada é gravado e o lote inteiro continua na fila. Exclusões viram `excluido: true` e sempre vencem. No fim, desligo a rede de novo e atualizo o estado para "sincronizado" ou "falha". O caminho de volta (pull) lê os documentos alterados desde a última sincronização e aplica no banco local.

**8. Funcionalidades implementadas**
- Seus dados: explicação das finalidades e acesso a cópia remota, exportação e exclusão.
- Ativação e desativação da cópia remota com Firebase Authentication.
- Fila de sincronização e motor só no Wi-Fi, com envio em lote (`WriteBatch`), versões e novas tentativas, e o teste automatizado T5.
- Cópia de todos os pets do tutor, com restauração e reagendamento dos lembretes num celular novo.
- Estados pendente, sincronizado e falha, inclusive no Início.
- Conflitos entre aparelhos, com escolha da versão.
- Exclusão integral local e remota, com bloqueio de restauração enquanto estiver pendente.
- Regras de segurança do Firestore e do Storage.
[Apagar ou detalhar.]

**9. O que faria diferente**
Eu colocaria a sincronização para rodar também em segundo plano, com o `workmanager` e restrição de rede sem tarifação, para a cópia atualizar mesmo com o app fechado. [Ou outra melhoria real, como definir a política de retenção de backups.] Priorizaria isso porque hoje a cópia só atualiza com o app aberto, e o objetivo dela é não perder dados.

**10. Testes e evidências**
Testei o motor de sincronização com um remoto falso em testes unitários (envio, repetição sem duplicar, conflito, exclusão com precedência: [N] testes), incluindo o teste oficial T5 do envio em lote: um commit para vários registros, edições repetidas viram uma escrita, falha no commit mantém tudo na fila e repetição não duplica ([resultado]) e as regras de segurança no Firebase Emulator Suite, conferindo que um usuário não acessa os dados de outro. Manualmente, usei o Network Inspector para comprovar que nada sai em modo avião ou com dados móveis, derrubei o Wi-Fi no meio do envio e fiz a exclusão integral offline e depois online. Evidências: [prints do inspector e do console, vídeo do conflito, saída dos testes, commits].
