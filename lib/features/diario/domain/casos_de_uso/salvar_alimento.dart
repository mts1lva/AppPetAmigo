import '../entidades/alimento.dart';
import '../repositorios/alimento_repositorio.dart';

/// Grava o alimento (cadastro ou edição). A tela valida a densidade antes
/// (tela 22 se ≤ 0); chamar com densidade inválida é erro de programação.
final class SalvarAlimento {
  const SalvarAlimento(this._repositorio);

  final AlimentoRepositorio _repositorio;

  Future<void> call(Alimento alimento, {required DateTime agora}) {
    if (!alimento.densidadeKcalPor100g.isFinite || alimento.densidadeKcalPor100g <= 0) {
      throw ArgumentError('Densidade precisa ser positiva.');
    }
    if (!alimento.porcaoPadraoG.isFinite || alimento.porcaoPadraoG <= 0) {
      throw ArgumentError('A quantidade precisa ser positiva.');
    }
    if (alimento.nome.trim().isEmpty) {
      throw ArgumentError('Informe o nome.');
    }
    return _repositorio.salvar(
      alimento.copyWith(nome: alimento.nome.trim()),
      agora: agora,
    );
  }
}
