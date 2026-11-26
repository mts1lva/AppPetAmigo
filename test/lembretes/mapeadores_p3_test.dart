import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/atividades/data/mapeadores/atividade_mapeador.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/lembretes/data/mapeadores/lembrete_mapeador.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';

void main() {
  test('atividade: ida e volta, Timestamp e descrição do conflito', () {
    final a = Atividade(
      id: 'a1',
      petId: 'p1',
      tipo: TipoAtividade.brincadeira,
      duracaoMin: 10,
      dataHora: DateTime(2026, 9, 30, 18),
    );
    final m = AtividadeMapeador();
    final doc = m.paraFirestore(a);
    expect(m.deFirestore(a.id, doc), a);
    expect(m.colecao, 'atividades');
    expect(m.resumoConflito(a), '30 set. 2026 • 18:00 • Brincadeira • 10 min');
    expect(
      () => m.deFirestore(a.id, {...doc, 'duracaoMin': 0}),
      throwsFormatException,
    );
    expect(
      () => m.deFirestore(a.id, {...doc, 'dataHora': 'ontem'}),
      throwsFormatException,
    );
  });
  test('lembrete: não transmite id do aparelho; restaura com id local', () {
    const l = Lembrete(
      id: 'l1',
      petId: 'p1',
      horaMinutos: 480,
      tipo: TipoLembrete.refeicao,
      ativo: false,
      notificacaoId: 42,
    );
    final m = LembreteMapeador(notificacaoIdLocal: (_) => 42);
    final doc = m.paraFirestore(l);
    expect(doc.keys, unorderedEquals(['petId', 'hora', 'tipo', 'ativo']));
    expect(m.deFirestore(l.id, doc), l);
    final outroAparelho = LembreteMapeador(notificacaoIdLocal: (_) => 123);
    expect(
      outroAparelho.deFirestore(l.id, {
        ...doc,
        'notificacaoId': 999,
      }).notificacaoId,
      123,
    );
    expect(m.resumoConflito(l), '08:00 • Refeição • pausado');
    for (final invalido in [
      {...doc, 'hora': 1440},
      {...doc, 'tipo': 'outro'},
      {...doc, 'ativo': null},
    ]) {
      expect(() => m.deFirestore(l.id, invalido), throwsFormatException);
    }
  });
}
