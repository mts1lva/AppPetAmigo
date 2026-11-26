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
        'alimentoId': extra.alimentoId,
        'descricao': extra.descricao,
        'quantidadeG': extra.quantidadeG,
        'unidades': extra.unidades,
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

    final unidades = campo<int?>('unidades');
    if (unidades != null && unidades <= 0) {
      throw FormatException('extras/$id: campo "unidades" inválido');
    }
    return Extra(
      id: id,
      petId: campo<String>('petId'),
      alimentoId: campo<String?>('alimentoId'),
      descricao: campo<String>('descricao'),
      quantidadeG: documento['quantidadeG'] == null ? null : campo<num>('quantidadeG').toDouble(),
      unidades: unidades,
      energiaKcal: campo<num>('energiaKcal').toDouble(),
      dataHora: campo<Timestamp>('dataHora').toDate(),
    );
  }

  @override
  String resumoConflito(Extra extra) {
    final hora = formatarHora(extra.dataHora);
    final unidades = extra.unidades;
    if (unidades != null) return '$unidades un. • $hora';
    final kcal = formatarNumero(extra.energiaKcal, casas: 0);
    final q = extra.quantidadeG;
    return q == null ? '$kcal kcal • $hora' : '${formatarNumero(q, casas: 0)} g • $hora';
  }
}
