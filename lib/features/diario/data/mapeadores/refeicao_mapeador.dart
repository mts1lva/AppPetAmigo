import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/formato/datas.dart';
import '../../../../core/formato/numeros.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/refeicao.dart';

/// Refeição ↔ documento `usuarios/{uid}/refeicoes/{id}` (P2-3.1).
/// Nome e densidade copiados vão junto, senão a restauração perde o histórico.
final class RefeicaoMapeador implements MapeadorSync<Refeicao> {
  const RefeicaoMapeador();

  @override
  String get colecao => ColecoesSync.refeicoes;

  @override
  String get nomeRegistro => 'refeição';

  @override
  Map<String, Object?> paraFirestore(Refeicao refeicao) => {
        'petId': refeicao.petId,
        'alimentoId': refeicao.alimentoId,
        'alimentoNome': refeicao.alimentoNome,
        'densidadeKcalPor100g': refeicao.densidadeKcalPor100g,
        'quantidadeG': refeicao.quantidadeG,
        'energiaKcal': refeicao.energiaKcal,
        'dataHora': Timestamp.fromDate(refeicao.dataHora),
      };

  @override
  Refeicao deFirestore(String id, Map<String, Object?> documento) {
    T campo<T>(String nome) {
      final valor = documento[nome];
      if (valor is! T) throw FormatException('refeicoes/$id: campo "$nome" ausente ou inválido');
      return valor;
    }

    return Refeicao(
      id: id,
      petId: campo<String>('petId'),
      alimentoId: documento['alimentoId'] as String?,
      alimentoNome: campo<String>('alimentoNome'),
      densidadeKcalPor100g: campo<num>('densidadeKcalPor100g').toDouble(),
      quantidadeG: campo<num>('quantidadeG').toDouble(),
      energiaKcal: campo<num>('energiaKcal').toDouble(),
      dataHora: campo<Timestamp>('dataHora').toDate(),
    );
  }

  @override
  String resumoConflito(Refeicao refeicao) =>
      '${formatarNumero(refeicao.quantidadeG, casas: 0)} g • ${formatarHora(refeicao.dataHora)}';
}
