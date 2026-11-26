// P4-3.2 — Pesagens e referências no Firebase Emulator Suite (roteiro da
// P5-3.7). Sem o MotorSync do P5: os mapeadores gravam e leem os documentos
// como o motor fará (`usuarios/{uid}/{colecao}/{id}` + versao/excluido), e o
// "pull" grava no banco local pelos repositórios do P4.
//
//   firebase emulators:exec --only auth,firestore --project pet-amigo-bac9e \
//     "flutter test integration_test/sync_evolucao_test.dart"

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:petamigo/core/banco/banco_provider.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/formato/datas.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/evolucao_providers.dart';
import 'package:petamigo/features/evolucao/data/mapeadores/pesagem_mapeador.dart';
import 'package:petamigo/features/evolucao/data/mapeadores/referencia_mapeador.dart';
import 'package:petamigo/features/evolucao/data/repositorios/pesagem_repositorio_drift.dart';
import 'package:petamigo/features/evolucao/data/repositorios/referencia_repositorio_drift.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/evolucao/domain/grafico_dados.dart';
import 'package:petamigo/firebase_options.dart';

import 'apoio_firebase.dart';

const _pesagem = PesagemMapeador();
const _referencia = ReferenciaMapeador();

final hoje = DateTime(2026, 9, 30, 9);

Pesagem pesagem(String id, double kg, DateTime data, {bool conferida = false}) =>
    Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data, conferida: conferida);

final pesagensLuna = [
  pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('w3', 5.4, DateTime(2026, 9, 30, 8)),
];

final ecc7 = Referencia(id: 'r1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30));

CollectionReference<Map<String, Object?>> _colecao(String uid, String nome) =>
    FirebaseFirestore.instance.collection('usuarios').doc(uid).collection(nome);

Future<void> _gravar({
  required String uid,
  required String colecao,
  required String id,
  required Map<String, Object?> dominio,
  required int versao,
  bool excluido = false,
}) {
  return _colecao(uid, colecao).doc(id).set({
    ...dominio,
    'versao': versao,
    'dispositivoId': 'teste-p4',
    'excluido': excluido,
  });
}

Future<Map<String, Object?>> _ler(String uid, String colecao, String id) async {
  final snap = await _colecao(uid, colecao).doc(id).get();
  expect(snap.exists, isTrue, reason: '$colecao/$id');
  return snap.data()!;
}

/// Banco local em memória com a Luna cadastrada (as pesagens têm chave
/// estrangeira para `pets`).
Future<BancoLocal> bancoComLuna() async {
  final banco = BancoLocal(NativeDatabase.memory());
  await banco.into(banco.pets).insert(PetsCompanion.insert(
        id: 'p1',
        criadoEm: hoje,
        atualizadoEm: hoje,
        nome: 'Luna',
        especie: 'gato',
        sexo: 'femea',
        idadeMeses: 72,
        idadeInformadaEm: hoje,
        castrado: true,
        nivelAtividade: 'moderada',
        estadoSync: const Value('sincronizado'),
      ));
  return banco;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String uid;

  setUpAll(() async {
    // Fora de test/ não roda o flutter_test_config.dart: sem isto a data
    // prevista (formatarDataCurta, pt_BR) lança LocaleDataException.
    await initializeDateFormatting(localeApp);
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
    }
    await usarEmuladores();
  });

  setUp(() async {
    await limparEmuladores();
    uid = (await criarUsuarioDeTeste('evolucao')).uid;
  });

  test('ida: pesagem suspeita mantida chega com conferida: true', () async {
    final mantida = pesagem('w9', 54, DateTime(2026, 9, 30, 9), conferida: true);
    await _gravar(uid: uid, colecao: _pesagem.colecao, id: mantida.id, dominio: _pesagem.paraFirestore(mantida), versao: 1);

    final doc = await _ler(uid, _pesagem.colecao, mantida.id);
    expect(doc['conferida'], isTrue);
    expect(doc['pesoKg'], 54);
    expect(doc['dataHora'], isA<Timestamp>());
    expect(doc['petId'], 'p1');
    expect(_pesagem.deFirestore(mantida.id, doc), mantida);
  });

  test('ida: remover referências grava a lápide em referencias e não mexe em pesagens (RF10)', () async {
    for (final p in pesagensLuna) {
      await _gravar(uid: uid, colecao: _pesagem.colecao, id: p.id, dominio: _pesagem.paraFirestore(p), versao: 1);
    }
    await _gravar(uid: uid, colecao: _referencia.colecao, id: ecc7.id, dominio: _referencia.paraFirestore(ecc7), versao: 1);
    final pesagensAntes = {for (final p in pesagensLuna) p.id: await _ler(uid, _pesagem.colecao, p.id)};

    // O repositório local enfileira a exclusão; o motor manda a lápide.
    final banco = await bancoComLuna();
    addTearDown(banco.close);
    final fila = _FilaGravadora();
    final repo = ReferenciaRepositorioDrift(banco, fila);
    await repo.salvar(ecc7, agora: hoje);
    await repo.remover('p1', agora: hoje);
    expect(fila.chamadas.last, (ColecoesSync.referencias, 'r1', OperacaoSync.excluir));
    await _gravar(
      uid: uid,
      colecao: _referencia.colecao,
      id: ecc7.id,
      dominio: _referencia.paraFirestore(ecc7),
      versao: 2,
      excluido: true,
    );

    final ref = await _ler(uid, _referencia.colecao, ecc7.id);
    expect((ref['excluido'], ref['versao']), (true, 2));
    for (final p in pesagensLuna) {
      expect(await _ler(uid, _pesagem.colecao, p.id), pesagensAntes[p.id], reason: p.id);
    }
    expect(fila.chamadas.where((c) => c.$1 == ColecoesSync.pesagens), isEmpty);
  });

  test('volta: 3 pesagens e ECC 7 no emulador → gráfico, peso ideal 4,5 e projeção recalculados sozinhos', () async {
    for (final p in pesagensLuna) {
      await _gravar(uid: uid, colecao: _pesagem.colecao, id: p.id, dominio: _pesagem.paraFirestore(p), versao: 1);
    }
    await _gravar(uid: uid, colecao: _referencia.colecao, id: ecc7.id, dominio: _referencia.paraFirestore(ecc7), versao: 1);

    final banco = await bancoComLuna();
    final container = ProviderContainer(overrides: [
      bancoProvider.overrideWithValue(banco),
      agoraProvider.overrideWithValue(() => hoje),
    ]);
    addTearDown(() async {
      container.dispose();
      await banco.close();
    });
    container.listen(modelosProvider('p1'), (_, _) {});
    container.listen(graficoProvider('p1'), (_, _) {});
    await pumpEventQueue();
    expect(container.read(graficoProvider('p1')), isA<Indisponivel<GraficoDados>>(), reason: 'antes do pull');

    // "Pull": cada documento vira registro local pelos repositórios.
    final pesagens = PesagemRepositorioDrift(banco, const FilaSyncInativa());
    final referencias = ReferenciaRepositorioDrift(banco, const FilaSyncInativa());
    for (final doc in (await _colecao(uid, _pesagem.colecao).get()).docs) {
      await pesagens.salvar(_pesagem.deFirestore(doc.id, doc.data()), agora: hoje);
    }
    final docRef = await _ler(uid, _referencia.colecao, ecc7.id);
    await referencias.salvar(_referencia.deFirestore(ecc7.id, docRef), agora: hoje);
    await pumpEventQueue();

    final grafico = container.read(graficoProvider('p1'))!.valorOuNulo!;
    expect(grafico.historico.map((p) => p.kg), [5.6, 5.5, 5.4]);
    expect(container.read(pesoIdealProvider('p1'))!.valorOuNulo!.kg, closeTo(4.5, 1e-9));
    expect(container.read(projecaoProvider('p1'))!.valorOuNulo!.kgDia, closeTo(-0.014286, 0.0000005));
    expect(container.read(dataPrevistaProvider('p1'))!.texto, '02 dez. 2026');
  });
}

/// Fila que só anota as chamadas.
final class _FilaGravadora implements FilaSync {
  final chamadas = <(String, String, OperacaoSync)>[];

  @override
  Future<EstadoSync> estadoInicial() async => EstadoSync.pendente;

  @override
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op) async =>
      chamadas.add((tabela, registroId, op));
}
