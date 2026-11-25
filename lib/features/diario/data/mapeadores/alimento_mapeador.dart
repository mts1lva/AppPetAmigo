import '../../../../core/formato/numeros.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/alimento.dart';

/// Alimento ↔ documento `usuarios/{uid}/alimentos/{id}` (P2-3.1).
final class AlimentoMapeador implements MapeadorSync<Alimento> {
  const AlimentoMapeador();

  @override
  String get colecao => ColecoesSync.alimentos;

  @override
  String get nomeRegistro => 'alimento';

  @override
  Map<String, Object?> paraFirestore(Alimento alimento) => {
        'petId': alimento.petId,
        'nome': alimento.nome,
        'densidadeKcalPor100g': alimento.densidadeKcalPor100g,
        'porcaoPadraoG': alimento.porcaoPadraoG,
        'arquivado': alimento.arquivado,
      };

  @override
  Alimento deFirestore(String id, Map<String, Object?> documento) {
    T campo<T>(String nome) {
      final valor = documento[nome];
      if (valor is! T) throw FormatException('alimentos/$id: campo "$nome" ausente ou inválido');
      return valor;
    }

    return Alimento(
      id: id,
      petId: campo<String>('petId'),
      nome: campo<String>('nome'),
      densidadeKcalPor100g: campo<num>('densidadeKcalPor100g').toDouble(),
      porcaoPadraoG: campo<num>('porcaoPadraoG').toDouble(),
      arquivado: campo<bool>('arquivado'),
    );
  }

  @override
  String resumoConflito(Alimento alimento) =>
      '${formatarNumero(alimento.porcaoPadraoG, casas: 0)} g • ${formatarNumero(alimento.densidadeKcalPor100g, casas: 0)} kcal/100 g';
}
