import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/referencia.dart';
import '../../domain/parametros.dart';
import '../../domain/textos_evolucao.dart';

/// Referência (ECC e objetivo) ↔ documento `usuarios/{uid}/referencias/{id}`
/// (`dados-e-sync.md`; P4-3.1).
final class ReferenciaMapeador implements MapeadorSync<Referencia> {
  const ReferenciaMapeador();

  @override
  String get colecao => ColecoesSync.referencias;

  @override
  String get nomeRegistro => 'referência';

  @override
  Map<String, Object?> paraFirestore(Referencia r) => {
        'petId': r.petId,
        'ecc': r.ecc,
        'objetivoKg': r.objetivoKg,
        'origem': r.origem.name,
        'data': Timestamp.fromDate(r.data),
      };

  /// Lança [FormatException] se faltar campo ou vier valor inválido.
  @override
  Referencia deFirestore(String id, Map<String, Object?> documento) {
    String erro(String campo) => 'referencias/$id: campo "$campo" ausente ou inválido';

    final petId = documento['petId'];
    if (petId is! String) throw FormatException(erro('petId'));
    final data = documento['data'];
    if (data is! Timestamp) throw FormatException(erro('data'));

    final eccBruto = documento['ecc'];
    int? ecc;
    if (eccBruto != null) {
      if (eccBruto is! num || eccBruto != eccBruto.roundToDouble()) throw FormatException(erro('ecc'));
      ecc = eccBruto.toInt();
      if (ecc < eccMinimo || ecc > eccMaximo) throw FormatException(erro('ecc'));
    }

    final objetivoBruto = documento['objetivoKg'];
    double? objetivo;
    if (objetivoBruto != null) {
      if (objetivoBruto is! num) throw FormatException(erro('objetivoKg'));
      objetivo = objetivoBruto.toDouble();
      if (!objetivo.isFinite || objetivo <= 0) throw FormatException(erro('objetivoKg'));
    }

    final origemTexto = documento['origem'];
    final origem = OrigemReferencia.values.where((o) => o.name == origemTexto).firstOrNull;
    if (origem == null) throw FormatException(erro('origem'));

    return Referencia(id: id, petId: petId, ecc: ecc, objetivoKg: objetivo, origem: origem, data: data.toDate());
  }

  /// `ECC 7 de 9 • Objetivo não informado` (tela 17).
  @override
  String resumoConflito(Referencia r) => linhaEccObjetivo(r);
}
