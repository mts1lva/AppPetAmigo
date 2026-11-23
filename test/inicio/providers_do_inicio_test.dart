// Providers que o Início usa na etapa 1: os stubs dos pacotes seguintes e o
// ultimaPesagemProvider real (`plano-de-execucao.md` → Stubs).

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/banco_provider.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/features/diario/apresentacao/providers/resumo_dia_provider.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/lembretes_provider.dart';
import 'package:petamigo/features/privacidade/apresentacao/providers/estado_copia_provider.dart';
import 'package:petamigo/features/privacidade/domain/entidades/estado_copia.dart';

/// No Riverpod 3, provider sem ouvinte fica pausado: escute antes de esperar
/// o valor (é o que as telas fazem com `ref.watch`).
Future<T> esperar<T>(ProviderContainer c, ProviderListenable<Future<T>> p) {
  final assinatura = c.listen(p, (_, _) {});
  addTearDown(assinatura.close);
  return assinatura.read();
}

void main() {
  group('Stubs (trocados pelos donos nas etapas 2, 3 e 5)', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('resumoDiaProvider → dia vazio (P2-2.1)', () async {
      final resumo = await esperar(container, resumoDiaProvider(('p1', DateTime(2026, 9, 30))).future);
      expect(resumo, ResumoDia.vazio(DateTime(2026, 9, 30)));
      expect(resumo.temRegistros, isFalse);
    });

    test('lembretesProvider → nenhum lembrete (P3-2.1)', () async {
      expect(await esperar(container, lembretesProvider('p1').future), isEmpty);
    });

    test('estadoCopiaProvider → desligada (P5-3.3)', () async {
      expect(await esperar(container, estadoCopiaProvider.future), const CopiaDesligada());
    });
  });

  group('ResumoDia (R02)', () {
    test('total e parcela dos petiscos: 108 + 12 = 120 kcal, 10%', () {
      final r = ResumoDia(dia: DateTime(2026, 9, 30), racaoKcal: 108, extrasKcal: 12, registros: 2);
      expect(r.totalKcal, 120);
      expect(r.parcelaExtras, 10);
    });

    test('dia vazio: sem parcela (não é 0%) e sem hora', () {
      final r = ResumoDia.vazio(DateTime(2026, 9, 30, 15, 42));
      expect(r.parcelaExtras, isNull);
      expect(r.dia, DateTime(2026, 9, 30));
    });
  });

  group('ultimaPesagemProvider (real)', () {
    late BancoLocal banco;
    late ProviderContainer container;
    final agora = DateTime(2026, 9, 30, 8);

    setUp(() async {
      banco = BancoLocal(NativeDatabase.memory());
      container = ProviderContainer(overrides: [bancoProvider.overrideWithValue(banco)]);
      for (final id in ['p1', 'p2']) {
        await banco.into(banco.pets).insert(PetsCompanion.insert(
              id: id,
              criadoEm: agora,
              atualizadoEm: agora,
              nome: 'Luna',
              especie: 'gato',
              sexo: 'femea',
              idadeMeses: 72,
              idadeInformadaEm: agora,
              castrado: true,
              nivelAtividade: 'moderada',
            ));
      }
    });

    tearDown(() async {
      container.dispose();
      await banco.close();
    });

    Future<void> pesar(String id, String petId, double kg, DateTime quando, {bool excluido = false}) =>
        banco.into(banco.pesagens).insert(PesagensCompanion.insert(
              id: id,
              criadoEm: quando,
              atualizadoEm: quando,
              petId: petId,
              pesoKg: kg,
              dataHora: quando,
              excluido: Value(excluido),
            ));

    test('sem pesagem → null', () async {
      expect(await esperar(container, ultimaPesagemProvider('p1').future), isNull);
    });

    test('a mais recente do pet, ignorando excluídas e os outros pets', () async {
      await pesar('w1', 'p1', 5.6, DateTime(2026, 9, 16));
      await pesar('w2', 'p1', 5.5, DateTime(2026, 9, 23));
      await pesar('w3', 'p1', 9.9, DateTime(2026, 9, 29), excluido: true);
      await pesar('w4', 'p2', 3.0, DateTime(2026, 9, 30));

      final ultima = await esperar(container, ultimaPesagemProvider('p1').future);
      expect(ultima, Pesagem(id: 'w2', petId: 'p1', pesoKg: 5.5, dataHora: DateTime(2026, 9, 23)));
    });

    test('atualiza sozinho quando entra uma pesagem nova (M9)', () async {
      await pesar('w1', 'p1', 5.5, DateTime(2026, 9, 23));
      final emitidos = <double?>[];
      container.listen(ultimaPesagemProvider('p1'), (_, prox) => emitidos.add(prox.value?.pesoKg),
          fireImmediately: true);
      await esperar(container, ultimaPesagemProvider('p1').future);

      await pesar('w2', 'p1', 5.4, DateTime(2026, 9, 30));
      await pumpEventQueue();

      expect(emitidos.whereType<double>(), [5.5, 5.4]);
    });
  });
}
