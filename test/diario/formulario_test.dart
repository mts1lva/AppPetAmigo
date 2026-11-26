import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/diario/apresentacao/formulario.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';

void main() {
  group('textoErroGravacao', () {
    test('validação de R05 mostra o texto do caso de uso', () {
      expect(textoErroGravacao(ArgumentError('Informe o nome.')), 'Informe o nome.');
    });

    test('falha do banco ou da fila mostra o texto da P-29, nunca a exceção crua', () {
      expect(textoErroGravacao(StateError('SqliteException(5): database is locked')), textoFalhaGravacao);
      expect(textoErroGravacao(Exception('x')), 'Não foi possível salvar. Tente novamente.');
      expect(textoErroGravacao(ArgumentError()), textoFalhaGravacao);
    });
  });
}
