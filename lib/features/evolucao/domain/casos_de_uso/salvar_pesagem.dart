import '../celebracao.dart';
import '../entidades/pesagem.dart';
import '../entidades/referencia.dart';
import '../formularios.dart';
import '../pesagem_suspeita.dart';
import '../peso_ideal.dart';
import '../repositorios/pesagem_repositorio.dart';

/// Tela 11: conferência de R06 antes de salvar e celebração de M8 depois.
final class SalvarPesagem {
  const SalvarPesagem(this._repositorio);

  final PesagemRepositorio _repositorio;

  /// R06 — compara [novoKg] com a pesagem anterior mais próxima de
  /// [dataHora] (no peso inicial, com a seguinte). [ignorarId] é a própria
  /// pesagem, na edição.
  ConferenciaPesagem conferir({
    required List<Pesagem> pesagens,
    required double novoKg,
    required DateTime dataHora,
    String? ignorarId,
  }) {
    final base = pesagemDeReferencia(pesagens, dataHora: dataHora, ignorarId: ignorarId);
    return conferirPesagem(novoKg, base?.pesoKg);
  }

  /// Grava [nova] (criação ou edição, pelo id) e devolve o texto da
  /// celebração de M8, ou `null`. [pesagensAntes] são as pesagens do pet
  /// antes de salvar.
  Future<String?> call(
    Pesagem nova, {
    required List<Pesagem> pesagensAntes,
    required Referencia? referencia,
    required String nomePet,
    required DateTime agora,
  }) async {
    final erros = validarPesagem(pesoKg: nova.pesoKg, dataHora: nova.dataHora, agora: agora);
    if (erros.isNotEmpty) throw ArgumentError('Pesagem inválida: ${erros.keys.map((c) => c.name)}');

    await _repositorio.salvar(nova, agora: agora);

    final depois = [
      for (final p in pesagensAntes)
        if (p.id != nova.id) p,
      nova,
    ];
    final pi = pesoIdeal(referencia, depois).valorOuNulo?.kg;
    return celebracao(
      nomePet: nomePet,
      anteriorKg: _anterior(pesagensAntes, nova)?.pesoKg,
      novoKg: nova.pesoKg,
      pi: pi,
    );
  }

  /// A pesagem imediatamente anterior a [nova] no tempo (sem ela mesma).
  /// O peso inicial não tem anterior, então não celebra.
  static Pesagem? _anterior(List<Pesagem> pesagens, Pesagem nova) {
    Pesagem? anterior;
    for (final p in pesagens) {
      if (p.id == nova.id || p.dataHora.isAfter(nova.dataHora)) continue;
      if (anterior == null || p.dataHora.isAfter(anterior.dataHora)) anterior = p;
    }
    return anterior;
  }
}
