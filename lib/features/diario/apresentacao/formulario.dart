import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formato/numeros.dart';
import '../domain/textos_diario.dart';

/// Número para um `PaCampo.numero`: vírgula decimal, sem zeros à direita.
String textoNumeroCampo(double valor) {
  final texto = formatarNumero(valor, casas: 2).replaceAll('.', '');
  return texto.contains(',') ? texto.replaceFirst(RegExp(r',?0+$'), '') : texto;
}

DateTime juntarDataHora(DateTime data, TimeOfDay hora) =>
    DateTime(data.year, data.month, data.day, hora.hour, hora.minute);

bool dataHoraFutura(DateTime valor, DateTime agora) => valor.isAfter(agora);

/// Mensagem para mostrar no diálogo quando a gravação (salvar, arquivar,
/// excluir) falha: o texto de validação de R05 que o caso de uso lançou ou,
/// para qualquer outra falha (banco, fila), [textoFalhaGravacao] (P-29). Nunca
/// mostra a exceção crua.
String textoErroGravacao(Object erro) {
  if (erro is ArgumentError) {
    final mensagem = erro.message;
    if (mensagem is String && mensagem.isNotEmpty) return mensagem;
  }
  return textoFalhaGravacao;
}

/// Lista do dia para a R08: usa o valor já emitido; se ainda não houve emissão,
/// espera [esperar]. Erro sem valor anterior não é tratado como dia vazio.
Future<List<T>> listaEmitidaDoDia<T>(
  AsyncValue<List<T>> async, {
  required Future<List<T>> Function() esperar,
}) async {
  if (async.hasValue) return List<T>.from(async.requireValue);
  if (async.hasError) {
    Error.throwWithStackTrace(async.error!, async.stackTrace ?? StackTrace.current);
  }
  return esperar();
}
