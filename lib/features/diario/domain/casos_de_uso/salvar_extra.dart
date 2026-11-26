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
    final descricao = extra.descricao.trim();
    return _repositorio.salvar(
      extra.copyWith(descricao: descricao.isEmpty ? 'Petisco' : descricao),
      agora: agora,
    );
  }
}
