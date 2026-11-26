import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/textos_evolucao.dart';

/// Pesagem ↔ documento `usuarios/{uid}/pesagens/{id}` (`dados-e-sync.md`;
/// P4-3.1). Inclui `conferida` (R06).
final class PesagemMapeador implements MapeadorSync<Pesagem> {
  const PesagemMapeador();

  @override
  String get colecao => ColecoesSync.pesagens;

  @override
  String get nomeRegistro => 'pesagem';

  @override
  Map<String, Object?> paraFirestore(Pesagem p) => {
        'petId': p.petId,
        'pesoKg': p.pesoKg,
        'dataHora': Timestamp.fromDate(p.dataHora),
        'conferida': p.conferida,
      };

  /// Lança [FormatException] se faltar campo ou vier valor inválido.
  @override
  Pesagem deFirestore(String id, Map<String, Object?> documento) {
    final campos = _Campos('pesagens/$id', documento);
    final peso = campos.obrigatorio<num>('pesoKg').toDouble();
    if (!peso.isFinite || peso <= 0) throw FormatException('pesagens/$id: "pesoKg" inválido');
    return Pesagem(
      id: id,
      petId: campos.obrigatorio<String>('petId'),
      pesoKg: peso,
      dataHora: campos.obrigatorio<Timestamp>('dataHora').toDate(),
      conferida: campos.conferida(),
    );
  }

  /// `5,4 kg • 30 set. 2026` (tela 17).
  @override
  String resumoConflito(Pesagem p) => linhaPesagem(p);
}

/// Leitura tipada dos campos de um documento.
final class _Campos {
  const _Campos(this.caminho, this.documento);

  final String caminho;
  final Map<String, Object?> documento;

  T obrigatorio<T>(String nome) {
    final valor = documento[nome];
    if (valor is! T) throw FormatException('$caminho: campo "$nome" ausente ou inválido');
    return valor;
  }

  /// `conferida` ausente (documento antigo) vale `false`.
  bool conferida() {
    final valor = documento['conferida'] ?? false;
    if (valor is! bool) throw FormatException('$caminho: campo "conferida" inválido');
    return valor;
  }
}
