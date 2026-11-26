import '../../../../core/resultado.dart';
import '../energia.dart';
import '../entidades/refeicao.dart';
import '../repositorios/refeicao_repositorio.dart';

/// Grava a refeição com a energia de R01, usando a densidade **da própria
/// refeição** (cópia do alimento na ocasião).
final class SalvarRefeicao {
  const SalvarRefeicao(this._repositorio);

  final RefeicaoRepositorio _repositorio;

  Future<void> call(Refeicao refeicao, {required DateTime agora}) async {
    final energia = energiaRefeicao(refeicao.quantidadeG, refeicao.densidadeKcalPor100g);
    switch (energia) {
      case Indisponivel(:final motivo):
        throw ArgumentError(motivo);
      case Disponivel(:final valor):
        await _repositorio.salvar(refeicao.copyWith(energiaKcal: valor), agora: agora);
    }
  }
}
