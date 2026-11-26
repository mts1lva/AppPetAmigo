import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/diario/domain/periodo.dart';

void main() {
  group('somarDias', () {
    test('conta dias civis, atravessando mês e ano', () {
      expect(somarDias(DateTime(2026, 11, 30), 1), DateTime(2026, 12, 1));
      expect(somarDias(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
      expect(somarDias(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 28));
    });

    test('sempre devolve meia-noite', () {
      final r = somarDias(DateTime(2026, 10, 18), -13);
      expect((r.hour, r.minute), (0, 0));
    });
  });

  group('naJanela', () {
    final hoje = DateTime(2026, 11, 26, 21, 30);

    test('14 dias vão de hoje − 13 até hoje', () {
      expect(naJanela(DateTime(2026, 11, 13), hoje, 14), isTrue);
      expect(naJanela(DateTime(2026, 11, 12, 23, 59), hoje, 14), isFalse);
      expect(naJanela(DateTime(2026, 11, 26, 23, 59), hoje, 14), isTrue);
      expect(naJanela(DateTime(2026, 11, 27), hoje, 14), isFalse);
    });
  });
}
