import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/core/sugestao.dart';

void main() {
  const s1 = Sugestao(tipo: TipoSugestao.reduzirPetiscos, texto: 'S1');
  const s2 = Sugestao(tipo: TipoSugestao.aumentarExercicios, texto: 'S2');
  const s3 = Sugestao(tipo: TipoSugestao.mudarObjetivo, texto: 'S3');
  final hoje = DateTime(2026, 9, 30, 10);

  group('M8 — selecionarSugestoes', () {
    test('todas nulas → lista vazia (card não aparece)', () {
      expect(selecionarSugestoes(hoje: hoje), isEmpty);
    });

    test('prioridade S3 > S1 > S2, no máximo 2', () {
      expect(selecionarSugestoes(s1: s1, s2: s2, s3: s3, hoje: hoje), [s3, s1]);
      expect(selecionarSugestoes(s1: s1, s2: s2, hoje: hoje), [s1, s2]);
      expect(selecionarSugestoes(s2: s2, hoje: hoje), [s2]);
    });

    test('"Agora não" esconde por 7 dias', () {
      final adiadas = {TipoSugestao.mudarObjetivo: DateTime(2026, 9, 24, 23)};
      expect(selecionarSugestoes(s1: s1, s2: s2, s3: s3, adiadas: adiadas, hoje: hoje), [s1, s2]);

      final hojeMais1 = DateTime(2026, 10, 1);
      expect(selecionarSugestoes(s1: s1, s3: s3, adiadas: adiadas, hoje: hojeMais1), [s3, s1]);
    });
  });

  group('Resultado', () {
    test('valorOuNulo e igualdade', () {
      expect(const Disponivel(2).valorOuNulo, 2);
      expect(const Indisponivel<int>('x').valorOuNulo, isNull);
      expect(const Disponivel(2), const Disponivel(2));
      expect(const Indisponivel<int>('x'), const Indisponivel<int>('x'));
      expect(const Disponivel(2).disponivel, isTrue);
    });
  });
}
