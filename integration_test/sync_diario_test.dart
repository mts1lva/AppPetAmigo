// P2-3.2 — ida, volta e histórico do alimento arquivado no emulador.
// Sem o MotorSync do P5: os mapeadores gravam e leem os documentos como o
// motor fará (`usuarios/{uid}/{colecao}/{id}` + versao/excluido).
//
//   firebase emulators:exec --only auth,firestore --project pet-amigo-bac9e \
//     "flutter test integration_test/sync_diario_test.dart"

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petamigo/features/diario/data/mapeadores/alimento_mapeador.dart';
import 'package:petamigo/features/diario/data/mapeadores/extra_mapeador.dart';
import 'package:petamigo/features/diario/data/mapeadores/refeicao_mapeador.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/diario/domain/resumo_do_dia.dart';
import 'package:petamigo/firebase_options.dart';

import 'apoio_firebase.dart';

const _alimento = AlimentoMapeador();
const _refeicao = RefeicaoMapeador();
const _extra = ExtraMapeador();

Alimento racao() => const Alimento(
      id: 'a1',
      petId: 'p1',
      nome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      porcaoPadraoG: 30,
    );

Refeicao refeicaoHabitual() => Refeicao(
      id: 'r1',
      petId: 'p1',
      alimentoId: 'a1',
      alimentoNome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      quantidadeG: 30,
      energiaKcal: 108,
      dataHora: DateTime(2026, 9, 30, 8),
    );

Extra petisco() => Extra(
      id: 'e1',
      petId: 'p1',
      descricao: 'Petisco',
      quantidadeG: 3,
      energiaKcal: 12,
      dataHora: DateTime(2026, 9, 30, 12),
    );

CollectionReference<Map<String, Object?>> _colecao(String uid, String nome) =>
    FirebaseFirestore.instance.collection('usuarios').doc(uid).collection(nome);

Map<String, Object?> _comControle(Map<String, Object?> dominio, {required int versao, required bool excluido}) => {
      ...dominio,
      'versao': versao,
      'dispositivoId': 'teste-p2',
      'excluido': excluido,
    };

Future<void> _gravar({
  required String uid,
  required String colecao,
  required String id,
  required Map<String, Object?> dominio,
  required int versao,
  bool excluido = false,
}) {
  return _colecao(uid, colecao).doc(id).set(_comControle(dominio, versao: versao, excluido: excluido));
}

Future<Map<String, Object?>> _ler(String uid, String colecao, String id) async {
  final snap = await _colecao(uid, colecao).doc(id).get();
  expect(snap.exists, isTrue, reason: '$colecao/$id');
  return snap.data()!;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String uid;

  setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
    }
    await usarEmuladores();
  });

  setUp(() async {
    await limparEmuladores();
    uid = (await criarUsuarioDeTeste('diario')).uid;
  });

  test('ida: criar, editar e excluir refeição e petisco no emulador', () async {
    final r = refeicaoHabitual();
    final e = petisco();

    await _gravar(uid: uid, colecao: _refeicao.colecao, id: r.id, dominio: _refeicao.paraFirestore(r), versao: 1);
    await _gravar(uid: uid, colecao: _extra.colecao, id: e.id, dominio: _extra.paraFirestore(e), versao: 1);

    final docR = await _ler(uid, _refeicao.colecao, r.id);
    expect(docR['alimentoNome'], 'Ração habitual');
    expect(docR['densidadeKcalPor100g'], 360);
    expect(docR['versao'], 1);
    expect(docR['excluido'], isFalse);
    expect(_refeicao.deFirestore(r.id, docR), r);

    final docE = await _ler(uid, _extra.colecao, e.id);
    expect(_extra.deFirestore(e.id, docE), e);

    final editada = r.copyWith(quantidadeG: 45, energiaKcal: 162);
    await _gravar(
      uid: uid,
      colecao: _refeicao.colecao,
      id: r.id,
      dominio: _refeicao.paraFirestore(editada),
      versao: 2,
    );
    final docEdit = await _ler(uid, _refeicao.colecao, r.id);
    expect(docEdit['quantidadeG'], 45);
    expect(docEdit['energiaKcal'], 162);
    expect(docEdit['alimentoNome'], 'Ração habitual');
    expect(docEdit['versao'], 2);
    expect(_refeicao.deFirestore(r.id, docEdit), editada);

    await _gravar(
      uid: uid,
      colecao: _refeicao.colecao,
      id: r.id,
      dominio: _refeicao.paraFirestore(editada),
      versao: 3,
      excluido: true,
    );
    await _gravar(
      uid: uid,
      colecao: _extra.colecao,
      id: e.id,
      dominio: _extra.paraFirestore(e),
      versao: 2,
      excluido: true,
    );
    expect((await _ler(uid, _refeicao.colecao, r.id))['excluido'], isTrue);
    expect((await _ler(uid, _extra.colecao, e.id))['excluido'], isTrue);
    expect((await _ler(uid, _refeicao.colecao, r.id))['versao'], 3);
  });

  test('volta: documento gravado no emulador vira refeição do diário com os totais certos', () async {
    final r = refeicaoHabitual();
    final e = petisco();
    await _gravar(uid: uid, colecao: _refeicao.colecao, id: r.id, dominio: _refeicao.paraFirestore(r), versao: 1);
    await _gravar(uid: uid, colecao: _extra.colecao, id: e.id, dominio: _extra.paraFirestore(e), versao: 1);

    final refeicoes = [_refeicao.deFirestore(r.id, await _ler(uid, _refeicao.colecao, r.id))];
    final extras = [_extra.deFirestore(e.id, await _ler(uid, _extra.colecao, e.id))];
    final resumo = resumoDoDia(dia: DateTime(2026, 9, 30), refeicoes: refeicoes, extras: extras);
    expect(resumo.racaoKcal, 108);
    expect(resumo.extrasKcal, 12);
    expect(resumo.totalKcal, 120);
    expect(resumo.parcelaExtras, 10);
  });

  test('histórico: arquivar o alimento não muda o documento da refeição antiga', () async {
    final a = racao();
    final r = refeicaoHabitual();
    await _gravar(uid: uid, colecao: _alimento.colecao, id: a.id, dominio: _alimento.paraFirestore(a), versao: 1);
    await _gravar(uid: uid, colecao: _refeicao.colecao, id: r.id, dominio: _refeicao.paraFirestore(r), versao: 1);

    final antes = Map<String, Object?>.from(await _ler(uid, _refeicao.colecao, r.id));

    await _gravar(
      uid: uid,
      colecao: _alimento.colecao,
      id: a.id,
      dominio: _alimento.paraFirestore(a.copyWith(arquivado: true)),
      versao: 2,
    );
    expect((await _ler(uid, _alimento.colecao, a.id))['arquivado'], isTrue);

    final depois = await _ler(uid, _refeicao.colecao, r.id);
    expect(depois['alimentoNome'], antes['alimentoNome']);
    expect(depois['densidadeKcalPor100g'], antes['densidadeKcalPor100g']);
    expect(depois['quantidadeG'], antes['quantidadeG']);
    expect(depois['energiaKcal'], antes['energiaKcal']);
    expect(depois['versao'], 1);
    expect(_refeicao.deFirestore(r.id, depois), r);
  });
}
