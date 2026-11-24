import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/formato/formato.dart';

void main() {
  final trintaSet = DateTime(2026, 9, 30, 8, 0);

  group('R10 — datas e hora', () {
    test('data curta: 30 set. 2026 (abreviação do intl igual à do protótipo)', () {
      expect(formatarDataCurta(trintaSet), '30 set. 2026');
      expect(formatarDataCurta(DateTime(2026, 12, 2)), '02 dez. 2026');
      expect(formatarDataCurta(DateTime(2026, 11, 28)), '28 nov. 2026');
    });

    test('todas as abreviações de mês terminam em ponto', () {
      final meses = [for (var m = 1; m <= 12; m++) formatarDiaMes(DateTime(2026, m, 15)).substring(3)];
      expect(meses, ['jan.', 'fev.', 'mar.', 'abr.', 'mai.', 'jun.', 'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.']);
    });

    test('cabeçalho do Diário: 30 setembro 2026', () {
      expect(formatarDataExtenso(trintaSet), '30 setembro 2026');
    });

    test('card do Início: Hoje · 30 set.', () {
      expect(formatarHojeCard(trintaSet), 'Hoje · 30 set.');
    });

    test('hora HH:mm', () {
      expect(formatarHora(trintaSet), '08:00');
      expect(formatarHora(DateTime(2026, 9, 30, 20, 5)), '20:05');
      expect(formatarMinutosDoDia(480), '08:00');
      expect(formatarMinutosDoDia(14 * 60), '14:00');
      expect(formatarMinutosDoDia(23 * 60 + 59), '23:59');
      expect(() => formatarMinutosDoDia(24 * 60), throwsRangeError);
    });
  });

  group('R10 — números', () {
    test('peso com 1 casa e vírgula; 2 casas no gráfico', () {
      expect(formatarPeso(5.4), '5,4 kg');
      expect(formatarPeso(5), '5,0 kg');
      expect(formatarPeso(5.44, casas: 2), '5,44 kg');
      expect(formatarPeso(4.745, casas: 1), '4,7 kg');
    });

    test('energia em inteiro', () {
      expect(formatarEnergia(108), '108 kcal');
      expect(formatarEnergia(396.75), '397 kcal');
      expect(formatarEnergia(110.2), '110 kcal');
      expect(formatarEnergia(7700), '7.700 kcal');
    });

    test('percentual em inteiro', () {
      expect(formatarPercentual(18.2), '18%');
      expect(formatarPercentual(66.67), '67%');
    });

    test('números do cálculo da tela 18', () {
      expect(formatarNumero(1.6), '1,6');
      expect(formatarNumero(0.75, casas: 2), '0,75');
    });

    test('sem "-0"', () {
      expect(formatarNumero(-0.04), '0,0');
    });

    test('entrada aceita vírgula e ponto', () {
      expect(lerNumero('5,4'), 5.4);
      expect(lerNumero('5.4'), 5.4);
      expect(lerNumero(' 30 '), 30);
      expect(lerNumero(',5'), 0.5);
      expect(lerNumero('5,'), 5);
      for (final invalido in ['', 'abc', '5,4,1', '5.4.1', '-3', '1e3']) {
        expect(lerNumero(invalido), isNull, reason: invalido);
      }
    });
  });

  group('R11 — saudação e idade', () {
    test('saudação só com o horário, sem nome (P-01)', () {
      DateTime h(int hora, [int min = 0]) => DateTime(2026, 9, 30, hora, min);
      expect(saudacao(h(5)), 'Bom dia');
      expect(saudacao(h(11, 59)), 'Bom dia');
      expect(saudacao(h(12)), 'Boa tarde');
      expect(saudacao(h(17, 59)), 'Boa tarde');
      expect(saudacao(h(18)), 'Boa noite');
      expect(saudacao(h(0)), 'Boa noite');
      expect(saudacao(h(4, 59)), 'Boa noite');
    });

    test('idade: meses abaixo de 1 ano, depois anos', () {
      expect(formatarIdade(6), '6 meses');
      expect(formatarIdade(1), '1 mês');
      expect(formatarIdade(11), '11 meses');
      expect(formatarIdade(12), '1 ano');
      expect(formatarIdade(23), '1 ano');
      expect(formatarIdade(72), '6 anos');
    });
  });
}
