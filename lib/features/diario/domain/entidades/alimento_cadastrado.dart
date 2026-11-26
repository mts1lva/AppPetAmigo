/// Valores de `alimentos.tipo` (P-32).
const tipoRacao = 'racao';
const tipoPetisco = 'petisco';

/// Campos comuns às rações e aos petiscos cadastrados.
abstract interface class AlimentoCadastrado {
  String get id;
  String get petId;
  String get nome;
  bool get arquivado;
}
