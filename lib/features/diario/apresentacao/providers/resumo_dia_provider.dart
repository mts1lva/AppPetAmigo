import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/relogio.dart';
import '../../domain/entidades/extra.dart';
import '../../domain/entidades/refeicao.dart';
import '../../domain/entidades/resumo_dia.dart';
import '../../domain/parametros.dart';
import '../../domain/periodo.dart';
import '../../domain/resumo_do_dia.dart';
import 'repositorios_providers.dart';

/// Resumo de um dia do pet (R02). Passe o dia sem hora: `DateTime(a, m, d)`.
final resumoDiaProvider = StreamProvider.family<ResumoDia, (String petId, DateTime dia)>((ref, args) {
  final (petId, dia) = args;
  final inicio = diaDe(dia);
  final fim = inicio.add(const Duration(days: 1));
  return _combinar(
    refeicoes: ref.watch(refeicaoRepositorioProvider).observarEntre(petId, inicio, fim),
    extras: ref.watch(extraRepositorioProvider).observarEntre(petId, inicio, fim),
    montar: (refeicoes, extras) => resumoDoDia(dia: inicio, refeicoes: refeicoes, extras: extras),
  );
});

/// Resumos dos últimos 14 dias (M7), um por dia civil, do mais antigo ao mais
/// recente. S1 usa a mesma janela e ignora o que está fora dos 7 dias.
final resumosJanelaProvider = StreamProvider.family<List<ResumoDia>, String>((ref, petId) {
  final hoje = diaDe(ref.watch(agoraProvider)());
  final inicio = hoje.subtract(const Duration(days: janelaAderenciaDias - 1));
  final fim = hoje.add(const Duration(days: 1));
  return _combinar(
    refeicoes: ref.watch(refeicaoRepositorioProvider).observarEntre(petId, inicio, fim),
    extras: ref.watch(extraRepositorioProvider).observarEntre(petId, inicio, fim),
    montar: (refeicoes, extras) => [
      for (var i = 0; i < janelaAderenciaDias; i++)
        resumoDoDia(
          dia: inicio.add(Duration(days: i)),
          refeicoes: refeicoes,
          extras: extras,
        ),
    ],
  );
});

Stream<T> _combinar<T>({
  required Stream<List<Refeicao>> refeicoes,
  required Stream<List<Extra>> extras,
  required T Function(List<Refeicao>, List<Extra>) montar,
}) {
  return Stream.multi((s) {
    List<Refeicao>? rs;
    List<Extra>? es;
    void emitir() {
      if (rs == null || es == null) return;
      s.add(montar(rs!, es!));
    }

    final a = refeicoes.listen((v) {
      rs = v;
      emitir();
    });
    final b = extras.listen((v) {
      es = v;
      emitir();
    });
    s.onCancel = () {
      a.cancel();
      b.cancel();
    };
  });
}
