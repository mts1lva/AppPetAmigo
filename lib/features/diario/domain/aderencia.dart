/// M7 — aderência ao plano alimentar (U2-12). Dart puro.
///
/// ```
/// janela: últimos 14 dias; só dias com registro (dia vazio não conta, RF20)
/// dia aderente: 0,9 × MER ≤ total do dia ≤ 1,1 × MER
/// aderencia = aderentes ÷ diasComRegistro × 100
/// ```
library;

import '../../../core/resultado.dart';
import '../../nutricao/domain/meta_diaria.dart';
import 'entidades/resumo_dia.dart';
import 'parametros.dart';
import 'periodo.dart';

/// Motivo quando não há pesagem (MER indisponível).
const motivoAderenciaSemMeta = 'Disponível depois da primeira pesagem.';

/// Motivo quando nenhum dia da janela tem registro (RF20).
const motivoAderenciaSemRegistros = 'Sem registros nos últimos 14 dias.';

/// Resultado da aderência: quantos dias da janela ficaram dentro de ±10%
/// da meta.
final class Aderencia {
  const Aderencia({required this.aderentes, required this.diasComRegistro, required this.percentual});

  final int aderentes;
  final int diasComRegistro;

  /// `aderentes / diasComRegistro × 100`. Exibir arredondado a inteiro.
  final double percentual;

  @override
  bool operator ==(Object other) =>
      other is Aderencia &&
      other.aderentes == aderentes &&
      other.diasComRegistro == diasComRegistro &&
      other.percentual == percentual;

  @override
  int get hashCode => Object.hash(aderentes, diasComRegistro, percentual);

  @override
  String toString() => 'Aderencia($aderentes/$diasComRegistro)';
}

/// Aderência na janela de [janelaAderenciaDias] até [hoje].
///
/// [dias] já filtrados pelo pet; só entram os que têm registro e caem na
/// janela. [meta] é o M1 do pet.
Resultado<Aderencia> aderencia({
  required Iterable<ResumoDia> dias,
  required Resultado<MetaDiaria> meta,
  required DateTime hoje,
}) {
  switch (meta) {
    case Indisponivel():
      return const Indisponivel(motivoAderenciaSemMeta);
    case Disponivel(valor: final m):
      if (!m.mer.isFinite || m.mer <= 0) return const Indisponivel(motivoAderenciaSemMeta);
      final noPeriodo = [
        for (final r in dias)
          if (r.temRegistros && naJanela(r.dia, hoje, janelaAderenciaDias)) r,
      ];
      if (noPeriodo.isEmpty) return const Indisponivel(motivoAderenciaSemRegistros);

      final minimo = m.mer * (1 - faixaAderencia);
      final maximo = m.mer * (1 + faixaAderencia);
      final aderentes = noPeriodo.where((r) {
        final total = r.totalKcal;
        return total.isFinite && total >= minimo && total <= maximo;
      }).length;
      final percentual = aderentes / noPeriodo.length * 100;
      assert(percentual.isFinite, 'M7 produziu um valor não finito');
      if (!percentual.isFinite) return const Indisponivel(motivoAderenciaSemRegistros);
      return Disponivel(Aderencia(
        aderentes: aderentes,
        diasComRegistro: noPeriodo.length,
        percentual: percentual,
      ));
  }
}
