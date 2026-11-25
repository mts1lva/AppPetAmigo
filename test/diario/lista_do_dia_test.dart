import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/diario/apresentacao/formulario.dart';

void main() {
  group('R08 — listaEmitidaDoDia', () {
    test('usa o valor já emitido e não chama esperar', () async {
      var esperou = false;
      final lista = await listaEmitidaDoDia(
        const AsyncData([1, 2]),
        esperar: () async {
          esperou = true;
          return [99];
        },
      );
      expect(lista, [1, 2]);
      expect(esperou, isFalse);
    });

    test('espera quando o stream ainda não emitiu', () async {
      final lista = await listaEmitidaDoDia(
        const AsyncLoading<List<int>>(),
        esperar: () async => [7],
      );
      expect(lista, [7]);
    });

    test('erro sem valor anterior não vira lista vazia', () async {
      expect(
        () => listaEmitidaDoDia(
          AsyncError<List<int>>(ArgumentError('falha'), StackTrace.empty),
          esperar: () async => const <int>[],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
