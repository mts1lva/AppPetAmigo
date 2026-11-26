// P2-4.3 — RNF06 do Diário no aparelho (Android 8.0, 2 GB).
// flutter run --profile -t integration_test/desempenho_diario_test.dart

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kProfileMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petamigo/app/tema/tema.dart';
import 'package:petamigo/core/banco/banco_provider.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/formato/datas.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/diario/apresentacao/telas/tela_diario.dart';
import 'package:petamigo/features/diario/data/repositorios/refeicao_repositorio_drift.dart';
import 'package:petamigo/features/diario/domain/aderencia.dart';
import 'package:petamigo/features/diario/domain/casos_de_uso/salvar_refeicao.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/diario/domain/parametros.dart';
import 'package:petamigo/features/diario/domain/periodo.dart';
import 'package:petamigo/features/diario/domain/resumo_do_dia.dart';
import 'package:petamigo/features/diario/domain/sugestao_petiscos.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';
import 'package:petamigo/features/nutricao/domain/meta_diaria.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

const _execucoes = 20;
const _totalRegistros = 1000;
const _proporcaoMinima = 0.95;
const _pesoKg = 5.4;
final _agora = DateTime(2026, 9, 30, 9);
final _hoje = diaDe(_agora);
final _pet = Pet(
  id: 'p1',
  nome: 'Luna',
  especie: Especie.gato,
  sexo: Sexo.femea,
  idadeMeses: 72,
  idadeInformadaEm: _agora,
  castrado: true,
  nivelAtividade: NivelAtividade.moderada,
);

Refeicao _refeicao(String id, DateTime dataHora) => Refeicao(
  id: id,
  petId: _pet.id,
  alimentoNome: 'Ração',
  densidadeKcalPor100g: 360,
  quantidadeG: 30,
  energiaKcal: 108,
  dataHora: dataHora,
);

// Distribui o histórico pela janela de M7. O Diário abre só o dia atual.
final _historico = [
  for (var i = 0; i < _totalRegistros; i++)
    _refeicao(
      'r$i',
      _agora.subtract(
        Duration(
          days: i % janelaAderenciaDias,
          minutes: i ~/ janelaAderenciaDias,
        ),
      ),
    ),
];

Future<BancoLocal> _bancoComRegistros() async {
  final cache = await getTemporaryDirectory();
  final pasta = await cache.createTemp('rnf06_diario_');
  addTearDown(() => pasta.delete(recursive: true));
  final banco = BancoLocal(
    driftDatabase(
      name: 'diario',
      native: DriftNativeOptions(databaseDirectory: () async => pasta),
    ),
  );
  addTearDown(banco.close);
  await banco
      .into(banco.pets)
      .insert(
        PetsCompanion.insert(
          id: _pet.id,
          criadoEm: _agora,
          atualizadoEm: _agora,
          nome: _pet.nome,
          especie: _pet.especie.name,
          sexo: _pet.sexo.name,
          idadeMeses: _pet.idadeMeses,
          idadeInformadaEm: _pet.idadeInformadaEm,
          castrado: _pet.castrado,
          nivelAtividade: _pet.nivelAtividade.name,
        ),
      );
  await banco
      .into(banco.pesagens)
      .insert(
        PesagensCompanion.insert(
          id: 'peso-p1',
          criadoEm: _agora,
          atualizadoEm: _agora,
          petId: _pet.id,
          pesoKg: _pesoKg,
          dataHora: _agora,
        ),
      );
  await banco.batch((b) {
    b.insertAll(banco.refeicoes, [
      for (final r in _historico)
        RefeicoesCompanion.insert(
          id: r.id,
          criadoEm: _agora,
          atualizadoEm: _agora,
          petId: r.petId,
          alimentoNome: r.alimentoNome,
          densidadeKcalPor100g: r.densidadeKcalPor100g,
          quantidadeG: r.quantidadeG,
          energiaKcal: r.energiaKcal,
          dataHora: r.dataHora,
        ),
    ]);
  });
  return banco;
}

Widget _app(BancoLocal banco) => ProviderScope(
  overrides: [
    bancoProvider.overrideWithValue(banco),
    agoraProvider.overrideWithValue(() => _agora),
    petAtualIdProvider.overrideWith((ref) => Stream.value(_pet.id)),
  ],
  child: MaterialApp(
    theme: PaTema.claro,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: const Scaffold(body: TelaDiario()),
  ),
);

void _relatar(
  String acao,
  List<Duration> tempos,
  bool Function(Duration) dentroDoLimite,
) {
  const microsPorMs = Duration.microsecondsPerMillisecond;
  final ms = [for (final tempo in tempos) tempo.inMicroseconds / microsPorMs];
  final ordenados = [...ms]..sort();
  final meio = ordenados.length ~/ 2;
  final mediana = (ordenados[meio - 1] + ordenados[meio]) / 2;
  final p95 = ordenados[(ordenados.length * _proporcaoMinima).ceil() - 1];
  final dentro = tempos.where(dentroDoLimite).length;
  final proporcao = dentro / tempos.length;
  final percentual = (proporcao * 100).round();
  final resultado = proporcao >= _proporcaoMinima ? 'APROVADO' : 'REPROVADO';
  final linha =
      'RNF06 $acao (ms): ${ms.join(', ')} | mediana ${mediana.toStringAsFixed(3)}'
      ' | p95 $p95 | $dentro/${tempos.length} ($percentual%) | $resultado';
  // ignore: avoid_print
  print(linha);
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  binding.reportData = {
    ...?binding.reportData,
    acao: {
      'tempos_ms': ms,
      'mediana_ms': mediana,
      'p95_ms': p95,
      'dentro_do_limite': dentro,
      'percentual': percentual,
      'resultado': resultado,
    },
  };
  expect(proporcao, greaterThanOrEqualTo(_proporcaoMinima), reason: linha);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting(localeApp));
  const pularForaDoProfile = !kProfileMode;

  testWidgets('salvar refeição com 1.000 registros em até 1 s', (tester) async {
    final banco = await _bancoComRegistros();
    final salvar = SalvarRefeicao(
      RefeicaoRepositorioDrift(banco, const FilaSyncInativa()),
    );
    final tempos = <Duration>[];
    for (var i = 0; i < _execucoes; i++) {
      final nova = _refeicao('nova-$i', _agora);
      final relogio = Stopwatch()..start();
      await salvar(nova, agora: _agora);
      tempos.add(relogio.elapsed);
      // Restaura a base de 1.000 refeições antes da próxima gravação.
      final remover = banco.delete(banco.refeicoes)
        ..where((r) => r.id.equals(nova.id));
      expect(await remover.go(), 1);
    }
    _relatar('salvar', tempos, (tempo) => tempo <= const Duration(seconds: 1));
  }, skip: pularForaDoProfile);

  testWidgets('abrir o resumo com 1.000 registros em até 2 s', (tester) async {
    final banco = await _bancoComRegistros();
    final resumo = resumoDoDia(
      dia: _hoje,
      refeicoes: _historico,
      extras: const [],
    );
    final pronto = find.text(
      textoResumoDia(resumo, metaDiaria(_pet, _pesoKg, _agora)),
    );
    final tempos = <Duration>[];
    for (var i = 0; i < _execucoes; i++) {
      final relogio = Stopwatch()..start();
      await tester.pumpWidget(_app(banco));
      while (pronto.evaluate().isEmpty) {
        if (relogio.elapsed > const Duration(seconds: 10)) {
          fail('O Resumo do dia não ficou pronto em 10 s.');
        }
        await tester.pump(const Duration(milliseconds: 1));
      }
      await tester.ensureVisible(pronto);
      await tester.pump();
      tempos.add(relogio.elapsed);
      // Descarta o escopo e as consultas da tela entre aberturas.
      await tester.pumpWidget(const SizedBox());
    }
    _relatar('abrir', tempos, (tempo) => tempo <= const Duration(seconds: 2));
  }, skip: pularForaDoProfile);

  testWidgets('modelos do Diário (M1, M7 e S1 de M8) em menos de 50 ms', (
    _,
  ) async {
    final historico = _historico;
    final tempos = <Duration>[];
    for (var i = 0; i < _execucoes; i++) {
      final relogio = Stopwatch()..start();
      final meta = metaDiaria(_pet, _pesoKg, _agora);
      final dias = [
        for (var d = janelaAderenciaDias - 1; d >= 0; d--)
          resumoDoDia(
            dia: somarDias(_hoje, -d),
            refeicoes: historico,
            extras: const [],
          ),
      ];
      final resultado = aderencia(dias: dias, meta: meta, hoje: _hoje);
      final sugestao = sugestaoPetiscos(dias: dias, hoje: _hoje);
      tempos.add(relogio.elapsed);
      expect(resultado.valorOuNulo?.diasComRegistro, janelaAderenciaDias);
      expect(sugestao, isNull);
    }
    _relatar(
      'modelos',
      tempos,
      (tempo) => tempo < const Duration(milliseconds: 50),
    );
  }, skip: pularForaDoProfile);
}
