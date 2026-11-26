// P4-4.3 — RNF06 da Evolução no aparelho: com 1.000 pesagens, abrir a tela 04
// (gráfico pronto) em até 2 s e recalcular a projeção depois de uma pesagem
// nova, em pelo menos 95% de 20 execuções. Os modelos sozinhos (< 50 ms) estão
// em test/evolucao/desempenho_test.dart.
//
// Rodar em modo profile num aparelho real (Android 8.0, 2 GB, como pede
// `arquitetura.md`), sem Firebase:
//
//   flutter run --profile -t integration_test/desempenho_evolucao_test.dart
//
// Os tempos saem no console (linhas `RNF06 …`); guarde a saída como evidência.

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show kProfileMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/tema.dart';
import 'package:petamigo/core/banco/banco_provider.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/formato/datas.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/tela_evolucao.dart';
import 'package:petamigo/features/evolucao/apresentacao/widgets/grafico_evolucao.dart';
import 'package:petamigo/features/evolucao/data/repositorios/pesagem_repositorio_drift.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';

const execucoes = 20;
const totalPesagens = 1000;
const limiteAbrir = Duration(seconds: 2);

final hoje = DateTime(2026, 9, 30, 9);

Future<BancoLocal> bancoComMilPesagens() async {
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
      ));
  await banco.batch((b) {
    b.insertAll(banco.pesagens, [
      for (var i = 0; i < totalPesagens; i++)
        PesagensCompanion.insert(
          id: 'w$i',
          criadoEm: hoje,
          atualizadoEm: hoje,
          petId: 'p1',
          pesoKg: 6 - i * 0.0006,
          dataHora: hoje.subtract(Duration(hours: 8 * (totalPesagens - 1 - i))),
        ),
    ]);
  });
  return banco;
}

Widget app(BancoLocal banco) => ProviderScope(
      overrides: [
        bancoProvider.overrideWithValue(banco),
        agoraProvider.overrideWithValue(() => hoje),
        petAtualIdProvider.overrideWith((ref) => Stream.value('p1')),
      ],
      child: MaterialApp(
        theme: PaTema.claro,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const Scaffold(body: TelaEvolucao()),
      ),
    );

/// Bombeia quadros até [pronto] ou estourar 10 s; devolve o tempo gasto.
Future<Duration> ate(WidgetTester tester, bool Function() pronto) async {
  final relogio = Stopwatch()..start();
  while (!pronto()) {
    if (relogio.elapsed > const Duration(seconds: 10)) fail('não ficou pronto em 10 s');
    await tester.pump(const Duration(milliseconds: 1));
  }
  return relogio.elapsed;
}

String? linhaPrevisao(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .firstWhere((t) => t.startsWith('Peso atual • '), orElse: () => '');

void relatar(String nome, List<Duration> tempos) {
  final ms = [for (final t in tempos) t.inMilliseconds]..sort();
  final p95 = ms[(ms.length * 0.95).ceil() - 1];
  // ignore: avoid_print
  print('RNF06 $nome (ms): ${ms.join(', ')} | mediana ${ms[ms.length ~/ 2]} | p95 $p95');
  IntegrationTestWidgetsFlutterBinding.instance.reportData = {
    ...?IntegrationTestWidgetsFlutterBinding.instance.reportData,
    nome: ms,
  };
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting(localeApp));

/// Só mede em `--profile`: em debug (o `flutter test integration_test` da
/// CI) os tempos não valem e o teste é pulado.
const pularForaDoProfile = !kProfileMode;

  testWidgets('abrir a Evolução com 1.000 pesagens: até 2 s em 95% de 20 execuções', (tester) async {
    final tempos = <Duration>[];
    for (var i = 0; i < execucoes; i++) {
      final banco = await bancoComMilPesagens();
      await tester.pumpWidget(const SizedBox());
      final relogio = Stopwatch()..start();
      await tester.pumpWidget(app(banco));
      await ate(tester, () => find.byType(GraficoEvolucao).evaluate().isNotEmpty);
      tempos.add(relogio.elapsed);
      await tester.pumpWidget(const SizedBox());
      await banco.close();
    }
    relatar('abrir', tempos);
    final dentro = tempos.where((t) => t <= limiteAbrir).length;
    expect(dentro / execucoes, greaterThanOrEqualTo(0.95));
  }, skip: pularForaDoProfile);

  testWidgets('recalcular a projeção depois de uma pesagem nova (U2-05)', (tester) async {
    final banco = await bancoComMilPesagens();
    final repo = PesagemRepositorioDrift(banco, const FilaSyncInativa());
    await tester.pumpWidget(app(banco));
    await ate(tester, () => find.byType(GraficoEvolucao).evaluate().isNotEmpty);

    final tempos = <Duration>[];
    for (var i = 0; i < execucoes; i++) {
      final antes = linhaPrevisao(tester);
      final relogio = Stopwatch()..start();
      await repo.salvar(
        Pesagem(id: 'nova$i', petId: 'p1', pesoKg: 5.2 - i * 0.01, dataHora: hoje.add(Duration(minutes: i + 1))),
        agora: hoje,
      );
      await ate(tester, () => linhaPrevisao(tester) != antes);
      tempos.add(relogio.elapsed);
    }
    relatar('recalcular', tempos);
    await tester.pumpWidget(const SizedBox());
    await banco.close();
  }, skip: pularForaDoProfile);
}
