import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/formato/datas.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/atividade.dart';
import '../../domain/parametros.dart';

final class AtividadeMapeador implements MapeadorSync<Atividade> {
  @override
  String get colecao => ColecoesSync.atividades;
  @override
  String get nomeRegistro => 'atividade';
  @override
  Map<String, Object?> paraFirestore(Atividade a) => {
    'petId': a.petId,
    'tipo': a.tipo.name,
    'duracaoMin': a.duracaoMin,
    'dataHora': Timestamp.fromDate(a.dataHora),
  };
  @override
  Atividade deFirestore(String id, Map<String, Object?> doc) {
    final petId = doc['petId'];
    final tipo = doc['tipo'];
    final minutos = doc['duracaoMin'];
    final dataHora = doc['dataHora'];
    if (id.isEmpty ||
        petId is! String ||
        petId.isEmpty ||
        minutos is! int ||
        minutos <= 0 ||
        minutos > duracaoMaximaMinutos ||
        dataHora is! Timestamp ||
        !TipoAtividade.values.any((t) => t.name == tipo)) {
      throw const FormatException('Documento de atividade inválido.');
    }
    return Atividade(
      id: id,
      petId: petId,
      tipo: TipoAtividade.values.byName(tipo as String),
      duracaoMin: minutos,
      dataHora: dataHora.toDate(),
    );
  }

  @override
  String resumoConflito(Atividade a) =>
      '${formatarDataCurta(a.dataHora)} • ${formatarHora(a.dataHora)} • '
      '${nomeTipoAtividade(a.tipo)} • ${a.duracaoMin} min';
}
