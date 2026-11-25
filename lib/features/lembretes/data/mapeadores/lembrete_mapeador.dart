import '../../../../core/formato/datas.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/lembrete.dart';

/// O motor fornece o id local já existente/alocado para cada documento.
/// Esse id pertence ao aparelho e nunca é copiado do Firestore (P3-3.1).
final class LembreteMapeador implements MapeadorSync<Lembrete> {
  const LembreteMapeador({required this.notificacaoIdLocal});
  final int Function(String id) notificacaoIdLocal;
  @override
  String get colecao => ColecoesSync.lembretes;
  @override
  String get nomeRegistro => 'lembrete';
  @override
  Map<String, Object?> paraFirestore(Lembrete l) => {
    'petId': l.petId,
    'hora': l.horaMinutos,
    'tipo': l.tipo.name,
    'ativo': l.ativo,
  };
  @override
  Lembrete deFirestore(String id, Map<String, Object?> doc) {
    final petId = doc['petId'];
    final hora = doc['hora'];
    final tipo = doc['tipo'];
    final ativo = doc['ativo'];
    if (id.isEmpty ||
        petId is! String ||
        petId.isEmpty ||
        hora is! int ||
        hora < 0 ||
        hora >= 1440 ||
        ativo is! bool ||
        !TipoLembrete.values.any((t) => t.name == tipo)) {
      throw const FormatException('Documento de lembrete inválido.');
    }
    final idLocal = notificacaoIdLocal(id);
    if (idLocal < 0 || idLocal > 0x7fffffff) {
      throw const FormatException('Id local de notificação inválido.');
    }
    return Lembrete(
      id: id,
      petId: petId,
      horaMinutos: hora,
      tipo: TipoLembrete.values.byName(tipo as String),
      ativo: ativo,
      notificacaoId: idLocal,
    );
  }

  @override
  String resumoConflito(Lembrete l) =>
      '${formatarMinutosDoDia(l.horaMinutos)} • '
      '${nomeTipoLembrete(l.tipo)}${l.ativo ? '' : ' • pausado'}';
}

