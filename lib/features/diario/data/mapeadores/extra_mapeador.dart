import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/formato/datas.dart';
import '../../../../core/formato/numeros.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/extra.dart';

/// Extra ↔ documento `usuarios/{uid}/extras/{id}` (P2-3.1).
final class ExtraMapeador implements MapeadorSync<Extra> {
  const ExtraMapeador();

  @override
  String get colecao => ColecoesSync.extras;

  @override
  String get nomeRegistro => 'petisco';

  @override
  Map<String, Object?> paraFirestore(Extra extra) => {
        'petId': extra.petId,
        'descricao': extra.descricao,
        'quantidadeG': extra.quantidadeG,
        'energiaKcal': extra.energiaKcal,
        'dataHora': Timestamp.fromDate(extra.dataHora),
      };

  @override
  Extra deFirestore(String id, Map<String, Object?> documento) {
    T campo<T>(String nome) {
      final valor = documento[nome];
      if (valor is! T) throw FormatException('extras/$id: campo "$nome" ausente ou inválido');
      return valor;
    }

    return Extra(
      id: id,
      petId: campo<String>('petId'),
      descricao: campo<String>('descricao'),
      quantidadeG: documento['quantidadeG'] == null ? null : campo<num>('quantidadeG').toDouble(),
      energiaKcal: campo<num>('energiaKcal').toDouble(),
      dataHora: campo<Timestamp>('dataHora').toDate(),
    );
  }

  @override
  String resumoConflito(Extra extra) {
    final hora = formatarHora(extra.dataHora);
    final kcal = formatarNumero(extra.energiaKcal, casas: 0);
    final q = extra.quantidadeG;
    return q == null ? '$kcal kcal • $hora' : '${formatarNumero(q, casas: 0)} g • $hora';
  }
}
