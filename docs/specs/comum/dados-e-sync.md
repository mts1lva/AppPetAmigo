# Dados e sincronização

## Princípios

1. **O banco local (drift/SQLite) é a fonte de verdade.** O Firestore é só uma cópia.
2. **IDs estáveis**: UUID v4 gerado no aparelho na criação e reutilizado como ID do documento no Firestore. Repetir um envio nunca duplica (RF15).
3. **Gravações atômicas**: cada ação do usuário é uma transação do drift (RNF08). A fila de sincronização é gravada na mesma transação.
4. **Valores históricos preservados**: a refeição guarda uma cópia do nome, da densidade e da quantidade usados na ocasião. Editar ou excluir o alimento depois não altera os registros antigos (RF04).
5. **Exclusão confirmada tem precedência**: um registro excluído vira "lápide" (`excluido = true`) até a sincronização terminar, e nenhum outro aparelho consegue restaurá-lo.

## Tabelas locais (drift)

Toda tabela sincronizável tem as **colunas de controle**:

| Coluna | Tipo | Significado |
|---|---|---|
| `id` | TEXT PK | UUID v4 |
| `criadoEm`, `atualizadoEm` | DATETIME | Hora local do aparelho |
| `versao` | INT | Começa em 1 e soma 1 a cada alteração local |
| `versaoRemota` | INT? | Última versão confirmada no Firestore (`null` = nunca enviado) |
| `estadoSync` | TEXT | `local` (cópia desligada), `pendente`, `sincronizado`, `falha`, `conflito` |
| `excluido` | BOOL | Lápide. As consultas da UI sempre filtram `excluido = false` |

### Tabelas de domínio

| Tabela | Campos (além dos de controle) | Pacote |
|---|---|---|
| `pets` | `nome` TEXT, `especie` TEXT (`cao`/`gato`), `sexo` TEXT (`macho`/`femea`), `idadeMeses` INT, `idadeInformadaEm` DATE, `castrado` BOOL, `nivelAtividade` TEXT (`baixa`/`moderada`/`alta`), `fotoArquivo` TEXT? | P1 |
| `alimentos` | `petId`, `nome` TEXT, `densidadeKcalPor100g` REAL, `porcaoPadraoG` REAL, `arquivado` BOOL (excluído do cadastro, preservado para as refeições antigas) | P2 |
| `refeicoes` | `petId`, `alimentoId` TEXT?, `alimentoNome` TEXT (cópia), `densidadeKcalPor100g` REAL (cópia), `quantidadeG` REAL, `energiaKcal` REAL, `dataHora` DATETIME | P2 |
| `extras` | `petId`, `descricao` TEXT, `quantidadeG` REAL?, `energiaKcal` REAL, `dataHora` DATETIME | P2 |
| `atividades` | `petId`, `tipo` TEXT (`passeio`/`brincadeira`), `duracaoMin` INT, `dataHora` DATETIME | P3 |
| `lembretes` | `petId`, `hora` INT (minutos desde 00:00), `tipo` TEXT (`refeicao`/`pesagem`/`atividade`), `ativo` BOOL, `notificacaoId` INT (único, estável) | P3 |
| `pesagens` | `petId`, `pesoKg` REAL, `dataHora` DATETIME, `conferida` BOOL (usuário manteve um valor suspeito) | P4 |
| `referencias` | `petId`, `ecc` INT? (1–9, escala WSAVA), `objetivoKg` REAL?, `origem` TEXT, `data` DATE. Uma linha vigente por pet | P4 |

**Vários pets (U2-10):** todas as tabelas de registro têm `petId` (TEXT, FK para `pets.id`). Cada pet tem histórico, alimentos, metas, gráfico e lembretes próprios. O pet que aparece nas telas é o **pet atual**, guardado em `config.petAtualId`.
- **Idade em meses** (briefing B-c): necessária para identificar filhote (< 12 meses, fator 3,0). Idade exibida: `{n} meses` abaixo de 1 ano; `1 ano` / `{n} anos` a partir daí. Idade atual = `idadeMeses + meses completos desde idadeInformadaEm`.
- **Peso inicial** (U2-06) é a primeira pesagem do pet, e editar o peso inicial é editar essa pesagem.
- **Excluir um pet** apaga em cascata (lápide) todos os registros com aquele `petId` e cancela os lembretes dele.

### Tabelas de controle (P5)

| Tabela | Campos |
|---|---|
| `filaSync` | `id` INT autoincrement, `tabela` TEXT, `registroId` TEXT, `operacao` TEXT (`upsert`/`excluir`), `criadoEm`, `tentativas` INT, `ultimoErro` TEXT? |
| `conflitos` | `tabela`, `registroId`, `dadosRemotos` TEXT (JSON), `detectadoEm` |
| `config` | chave/valor: `copiaRemotaAtiva`, `uid`, `ultimoPull`, `exclusaoRemotaPendente`, `dispositivoId`, `petAtualId`, `sugestoesAdiadas` (JSON: id da sugestão → data) |

A tabela `config` **não é apagada** pela exclusão integral, porque guarda a pendência de remoção remota (RF17). `petAtualId` e `sugestoesAdiadas` são limpos.

Índices obrigatórios: `(petId, dataHora)` em `refeicoes`, `extras`, `atividades` e `pesagens`; `petId` em `alimentos`, `lembretes` e `referencias`; `(tabela, registroId)` em `filaSync`.

## Contrato da fila (P5 fornece, todos usam)

```dart
abstract interface class FilaSync {
  /// Chamar DENTRO da transação que gravou o registro.
  /// Com a cópia remota desligada, não faz nada.
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op);
}
```

Exemplo de repositório (padrão para todos os pacotes):

```dart
Future<void> salvarRefeicao(Refeicao r) => db.transaction(() async {
  final atual = await dao.buscar(r.id);
  await dao.gravar(r.copyWith(
    versao: (atual?.versao ?? 0) + 1,
    atualizadoEm: DateTime.now(),
    estadoSync: await fila.estadoInicial(), // 'local' ou 'pendente'
  ));
  await fila.enfileirar('refeicoes', r.id, OperacaoSync.upsert);
});

Future<void> excluirRefeicao(String id) => db.transaction(() async {
  await dao.marcarExcluido(id); // lápide, não DELETE
  await fila.enfileirar('refeicoes', id, OperacaoSync.excluir);
});
```

Com a cópia desligada, a lápide é apagada de verdade em seguida (P5 faz a limpeza).

## Contrato do mapeador (cada pacote entrega os seus)

```dart
abstract interface class MapeadorSync<T> {
  String get colecao;                       // ex.: 'refeicoes'
  Map<String, Object?> paraFirestore(T r);  // datas → Timestamp; sem campos de controle locais
  T deFirestore(String id, Map<String, Object?> doc);
  String resumoConflito(T r);               // ex.: '30 g • 08:00' (usado na tela 17)
  String get nomeRegistro;                  // ex.: 'refeição' → "A mesma refeição foi editada…"
}
```

| Mapeador | Pacote |
|---|---|
| `PetMapeador`, `FotoPetMapeador` + `FotosPetSync` (foto sem rede, P-27) | P1 |
| `AlimentoMapeador`, `RefeicaoMapeador`, `ExtraMapeador` | P2 |
| `AtividadeMapeador`, `LembreteMapeador` | P3 |
| `PesagemMapeador`, `ReferenciaMapeador` | P4 |

Cada mapeador precisa de um **teste de ida e volta** (`deFirestore(paraFirestore(x)) == x`) com um registro de cada tipo.

## Estrutura no Firebase

```
Firestore
usuarios/{uid}/
  pets/{petId}
  alimentos/{id}
  refeicoes/{id}
  extras/{id}
  atividades/{id}
  lembretes/{id}
  pesagens/{id}
  referencias/{id}
  fotos/{petId}       foto do pet: imagem (Bytes, JPEG de até 512 px) + petId

Cada documento: campos do domínio (inclusive petId) + versao (int)
                + atualizadoEm (serverTimestamp) + dispositivoId (string) + excluido (bool)
```

As coleções ficam "achatadas" por usuário, com `petId` como campo, em vez de uma subcoleção por pet. Assim o motor sincroniza todos os pets com as mesmas consultas, e a exclusão integral apaga uma coleção por vez.

Regras de segurança (P5 publica, todos revisam):

```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{uid}/{colecao}/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Motor de sincronização (P5)

### Só por Wi-Fi

- `connectivity_plus`: a sync só roda se a lista de conexões atual contém `ConnectivityResult.wifi`.
- Firestore com `persistenceEnabled: false` e `disableNetwork()` na inicialização. Ao começar um ciclo no Wi-Fi: `enableNetwork()`. Ao terminar, ou se o Wi-Fi cair (`onConnectivityChanged`): `disableNetwork()`.
- Gatilhos de um ciclo: app volta ao primeiro plano, Wi-Fi conecta, gravação nova com Wi-Fi ativo (com 5 s de espera para agrupar) e o botão de tentar de novo no 16.

### Envio em lote (push, U2-16)

```
enquanto houver itens na fila e Wi-Fi:
  1. LOTE: até 100 itens mais antigos da fila. Itens repetidos do mesmo
     (tabela, registroId) viram um só, com a última operação.
  2. LEITURA: para cada coleção do lote, busca os documentos remotos com
     where(FieldPath.documentId, whereIn: ids), em grupos de até 30 ids.
  3. CLASSIFICAÇÃO (local, item a item):
       remoto existe e remoto.excluido      → aplicar exclusão no local (precedência); sai do lote
       op == excluir                         → set(excluido: true, versao: (remoto?.versao ?? 0) + 1)
       remoto não existe                     → set(local, versao: local.versao)
       remoto.versao == local.versaoRemota   → set(local, versao: remoto.versao + 1)
       senão                                 → CONFLITO: grava em `conflitos`, estadoSync = 'conflito'; sai do lote
  4. ESCRITA: um único WriteBatch com todos os itens restantes (máximo de 500 operações) → commit().
  5. RESULTADO:
       commit ok     → numa transação do drift: versaoRemota e estadoSync = 'sincronizado'
                       em todos os itens do lote; remove todos da fila
       commit falhou → o lote é atômico: nenhum documento foi gravado e nenhum item sai da fila;
                       tentativas++, ultimoErro, estadoSync = 'falha' (dados locais intactos)
```

- **Idempotência**: os IDs dos documentos são os IDs locais, então repetir um lote nunca cria documento duplicado. Caso especial: o commit deu certo, mas a confirmação não chegou porque o Wi-Fi caiu. Na repetição, o remoto já está uma versão à frente. Para não confundir isso com conflito, o passo 3 tem uma regra antes do "senão": se `remoto.dispositivoId == este aparelho` **e** `remoto.versao == local.versaoRemota + 1`, a mudança remota foi feita por este próprio aparelho. Não é conflito: o item segue como "versão bate", usando `remoto.versao`, e o conteúdo local atual é regravado. Isso também preserva uma edição feita depois do commit sem confirmação.
- **Janela de corrida**: entre a leitura (2) e o commit (4), outro aparelho pode gravar o mesmo documento. Para este projeto, isso é aceitável: o pull seguinte detecta a divergência de versão e abre o conflito.
- **Foto do pet** (P-23): vai num documento próprio, `usuarios/{uid}/fotos/{petId}`, com a imagem como `Bytes` (JPEG de até 512 px, bem abaixo do limite de 1 MB por documento do Firestore) e os mesmos campos de controle (`versao`, `atualizadoEm`, `dispositivoId`, `excluido`). Não entra no `WriteBatch`, para o lote não passar do limite de tamanho: é gravada com `set()` depois do commit do documento do pet, e uma falha só marca o pet como `falha` para tentar de novo. Remover a foto grava a lápide (`excluido: true`, sem `imagem`). No pull, a imagem é gravada na área privada e o caminho vai para `fotoArquivo`, sem entrar na fila.

### Recebimento (pull)

- Por coleção, consulta `atualizadoEm > ultimoPull`.
- Se o registro local não está pendente: aplica o remoto (inclusive lápides).
- Se o registro local está pendente e as versões divergem: conflito.
- **Restauração**: ao ativar a cópia num aparelho com banco vazio, o pull traz tudo. A restauração fica bloqueada se `exclusaoRemotaPendente = true`.

### Conflito (tela 17)

Mostra "Neste aparelho: …" e "Na cópia: …" lado a lado.
- **Manter versão local**: força o envio com `versao = remoto.versao + 1`.
- **Usar versão da cópia**: grava o remoto no local e tira o item da fila.
Exclusão sempre vence: se um dos lados excluiu, não há escolha (texto: "Exclusões confirmadas têm precedência").

### Exclusão integral (RF17)

1. Transação local: apaga todas as tabelas de domínio (todos os pets) e a fila, e grava `exclusaoRemotaPendente = true` se a cópia estava ativa. Cancela todos os lembretes agendados.
2. Apaga os arquivos das fotos.
3. No Wi-Fi: apaga todos os documentos de `usuarios/{uid}/*` (inclusive as fotos) em lotes de até 500 e então chama `currentUser.delete()`. Se o Firebase pedir login recente, mostra o diálogo de senha.
4. Só depois do passo 3 confirmado: `exclusaoRemotaPendente = false` e a mensagem "Remoção da cópia remota concluída."
5. Backups do Firestore: não ativar backup agendado nem PITR enquanto a política de retenção não for definida (pendência do `requisitos.md`).
