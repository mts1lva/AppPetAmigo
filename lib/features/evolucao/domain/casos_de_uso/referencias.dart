import '../entidades/pesagem.dart';
import '../entidades/referencia.dart';
import '../formularios.dart';
import '../peso_ideal.dart';
import '../repositorios/referencia_repositorio.dart';

/// "Salvar referências" da tela 12.
final class SalvarReferencias {
  const SalvarReferencias(this._repositorio);

  final ReferenciaRepositorio _repositorio;

  Future<void> call(Referencia referencia, {required DateTime agora}) {
    final objetivo = referencia.objetivoKg;
    final erros = validarReferencia(
      objetivoTexto: objetivo == null ? '' : '$objetivo',
      objetivoKg: objetivo,
      data: referencia.data,
      agora: agora,
    );
    final ecc = referencia.ecc;
    if (erros.isNotEmpty || (ecc != null && (ecc < 1 || ecc > 9))) {
      throw ArgumentError('Referência inválida: ${erros.keys.map((c) => c.name)}');
    }
    return _repositorio.salvar(referencia, agora: agora);
  }
}

/// "Remover referências" da tela 12, depois da tela 23: apaga só a
/// referência; as pesagens ficam (RF10).
final class RemoverReferencias {
  const RemoverReferencias(this._repositorio);

  final ReferenciaRepositorio _repositorio;

  Future<void> call(String petId, {required DateTime agora}) => _repositorio.remover(petId, agora: agora);
}

/// Linha nova da tela 12, com ECC e sem objetivo:
/// `Peso ideal estimado pelo ECC: 4,5 kg.` Devolve o peso, ou `null` quando
/// a linha não aparece (sem ECC, com objetivo ou sem pesagem).
double? pesoIdealEstimadoNaTela12({
  required String petId,
  required int? ecc,
  required double? objetivoKg,
  required DateTime data,
  required List<Pesagem> pesagens,
}) {
  if (ecc == null || objetivoKg != null) return null;
  final r = Referencia(id: '', petId: petId, ecc: ecc, origem: OrigemReferencia.tutor, data: data);
  return pesoIdeal(r, pesagens).valorOuNulo?.kg;
}
