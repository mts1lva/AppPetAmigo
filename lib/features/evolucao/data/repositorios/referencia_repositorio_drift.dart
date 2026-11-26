import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/referencia.dart';
import '../../domain/repositorios/referencia_repositorio.dart';

/// Implementação drift do [ReferenciaRepositorio], no padrão do
/// `PetRepositorioDrift`.
final class ReferenciaRepositorioDrift implements ReferenciaRepositorio {
  const ReferenciaRepositorioDrift(this._banco, this._fila);

  final BancoLocal _banco;
  final FilaSync _fila;

  SimpleSelectStatement<$ReferenciasTable, ReferenciaLinha> _vigentes(String petId) =>
      _banco.select(_banco.referencias)..where((r) => r.petId.equals(petId) & r.excluido.equals(false));

  /// Se a sincronização trouxer mais de uma linha vigente, vale a alterada
  /// por último.
  @override
  Stream<Referencia?> observarVigente(String petId) {
    final consulta = _vigentes(petId)
      ..orderBy([(r) => OrderingTerm.desc(r.atualizadoEm), (r) => OrderingTerm.desc(r.data)])
      ..limit(1);
    return consulta.watchSingleOrNull().map((linha) => linha == null ? null : _paraEntidade(linha));
  }

  @override
  Future<void> salvar(Referencia referencia, {required DateTime agora}) {
    return _banco.transaction(() async {
      final estado = (await _fila.estadoInicial()).name;
      final atual =
          await (_banco.select(_banco.referencias)..where((r) => r.id.equals(referencia.id))).getSingleOrNull();

      if (atual == null) {
        await _banco.into(_banco.referencias).insert(ReferenciasCompanion.insert(
              id: referencia.id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              petId: referencia.petId,
              ecc: Value(referencia.ecc),
              objetivoKg: Value(referencia.objetivoKg),
              origem: referencia.origem.name,
              data: referencia.data,
            ));
      } else {
        if (atual.excluido) throw StateError('Referência removida: ${referencia.id}');
        await (_banco.update(_banco.referencias)..where((r) => r.id.equals(referencia.id))).write(ReferenciasCompanion(
          ecc: Value(referencia.ecc),
          objetivoKg: Value(referencia.objetivoKg),
          origem: Value(referencia.origem.name),
          data: Value(referencia.data),
          versao: Value(atual.versao + 1),
          atualizadoEm: Value(agora),
          estadoSync: Value(estado),
        ));
      }
      await _fila.enfileirar(ColecoesSync.referencias, referencia.id, OperacaoSync.upsert);

      final outras = await (_vigentes(referencia.petId)..where((r) => r.id.equals(referencia.id).not())).get();
      await _lapides(outras, agora: agora, estado: estado);
    });
  }

  @override
  Future<void> remover(String petId, {required DateTime agora}) {
    return _banco.transaction(() async {
      final vigentes = await _vigentes(petId).get();
      if (vigentes.isEmpty) return;
      await _lapides(vigentes, agora: agora, estado: (await _fila.estadoInicial()).name);
    });
  }

  Future<void> _lapides(List<ReferenciaLinha> linhas, {required DateTime agora, required String estado}) async {
    for (final l in linhas) {
      await (_banco.update(_banco.referencias)..where((r) => r.id.equals(l.id))).write(ReferenciasCompanion(
        excluido: const Value(true),
        versao: Value(l.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.referencias, l.id, OperacaoSync.excluir);
    }
  }

  static Referencia _paraEntidade(ReferenciaLinha l) => Referencia(
        id: l.id,
        petId: l.petId,
        ecc: l.ecc,
        objetivoKg: l.objetivoKg,
        origem: OrigemReferencia.values.byName(l.origem),
        data: l.data,
      );
}
