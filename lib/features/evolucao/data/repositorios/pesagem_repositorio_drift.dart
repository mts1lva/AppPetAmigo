import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/repositorios/pesagem_repositorio.dart';

final class PesagemRepositorioDrift implements PesagemRepositorio {
  const PesagemRepositorioDrift(this._banco);

  final BancoLocal _banco;

  @override
  Stream<Pesagem?> observarUltima(String petId) {
    final consulta = _banco.select(_banco.pesagens)
      ..where((p) => p.petId.equals(petId) & p.excluido.equals(false))
      ..orderBy([(p) => OrderingTerm.desc(p.dataHora), (p) => OrderingTerm.desc(p.criadoEm)])
      ..limit(1);
    return consulta.watchSingleOrNull().map((linha) => linha == null ? null : _paraEntidade(linha));
  }

  static Pesagem _paraEntidade(PesagemLinha l) =>
      Pesagem(id: l.id, petId: l.petId, pesoKg: l.pesoKg, dataHora: l.dataHora, conferida: l.conferida);
}
