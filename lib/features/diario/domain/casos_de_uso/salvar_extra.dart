import '../energia.dart';
import '../entidades/extra.dart';
import '../repositorios/extra_repositorio.dart';

/// Grava o petisco. Energia informada (não calculada pelo rótulo).
final class SalvarExtra {
  const SalvarExtra(this._repositorio);

  final ExtraRepositorio _repositorio;

  Future<void> call(Extra extra, {required DateTime agora}) {
    if (!extra.energiaKcal.isFinite || extra.energiaKcal <= 0) {
      throw ArgumentError('Informe a energia em kcal.');
    }
    final q = extra.quantidadeG;
    if (q != null && (!q.isFinite || q <= 0)) {
      throw ArgumentError('A quantidade precisa ser positiva.');
    }
    final u = extra.unidades;
    if (u != null && u <= 0) {
      throw ArgumentError(motivoUnidadesInvalidas);
    }
    final descricao = extra.descricao.trim();
    return _repositorio.salvar(
      extra.copyWith(descricao: descricao.isEmpty ? 'Petisco' : descricao),
      agora: agora,
    );
  }
}
