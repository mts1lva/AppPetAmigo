/// Textos da tela 04 Evolução (`pacote-4` → 04; M5, M7, R07, R10). Dart puro.
library;

import '../../../core/formato/datas.dart';
import '../../../core/formato/numeros.dart';
import '../../../core/resultado.dart';
import '../../diario/domain/textos_diario.dart' show textoAderencia;
import 'entidades/pesagem.dart';
import 'entidades/referencia.dart';
import 'modelos_do_pet.dart';
import 'parametros.dart';
import 'projecao.dart';
import 'textos_evolucao.dart';

abstract final class TextosEvolucao {
  static const titulo = 'Evolução';
  static const subtitulo = 'Peso é uma parte do acompanhamento.';

  static const tituloIndicadores = 'Indicadores';
  static const tituloUltimaPesagem = 'Última pesagem';
  static const semPesagem = 'Nenhuma pesagem registrada.';
  static const tituloPesagensAnteriores = 'Pesagens anteriores';
  static const verMais = 'Ver mais';
  static const tituloAcompanhar = 'Acompanhar';
  static const textoAcompanhar = 'Uma mudança não define melhora.';
  static const tituloEccObjetivo = 'ECC e objetivo';
  static const tituloResumo = 'Resumo para consulta';
  static const textoResumo = 'Você escolhe quando compartilhar.';

  /// Sem ECC nem objetivo, na linha "Peso ideal".
  static const informeEccObjetivo = 'Informe o ECC ou o objetivo';

  /// Sem pesagem, na linha "Peso atual" (R11).
  static const pesoNaoInformado = 'peso não informado';
}

/// Linhas do card Indicadores:
/// ```
/// Peso atual • 5,4 kg
/// Peso ideal • 4,5 kg (estimado pelo ECC 7)
/// Evolução • 18% do caminho
/// Aderência ao plano • 67% (4 de 6 dias com registro)
/// Previsão • 28 nov. 2026
/// projeção limitada ao ritmo máximo seguro      (só quando M4 cortou)
/// ```
List<String> linhasIndicadores(ModelosDoPet m) {
  final atual = m.pesoAtual;
  final ideal = m.pesoIdeal.valorOuNulo;
  final aderencia = switch (m.aderencia) {
    null => '—',
    Disponivel(:final valor) => textoAderencia(valor),
    Indisponivel(:final motivo) => motivo,
  };
  return [
    'Peso atual • ${atual == null ? TextosEvolucao.pesoNaoInformado : formatarPeso(atual.pesoKg)}',
    'Peso ideal • ${ideal == null ? TextosEvolucao.informeEccObjetivo : '${formatarPeso(ideal.kg)} ${ideal.rotulo}'}',
    'Evolução • ${m.evolucao.texto}',
    'Aderência ao plano • $aderencia',
    'Previsão • ${m.previsao.texto}',
    if (m.projecao.valorOuNulo?.limitada ?? false) textoProjecaoLimitada,
  ];
}

/// Card Última pesagem: `5,4 kg • 30 set. 2026` / `Anterior: 5,5 kg • 23 set.`
String textoUltimaPesagem(List<Pesagem> pesagens) {
  if (pesagens.isEmpty) return TextosEvolucao.semPesagem;
  final ultima = pesagens.last;
  final linhas = [linhaPesagem(ultima)];
  if (pesagens.length >= 2) {
    final anterior = pesagens[pesagens.length - 2];
    linhas.add('Anterior: ${formatarPeso(anterior.pesoKg)} • ${formatarDiaMes(anterior.dataHora)}');
  }
  return linhas.join('\n');
}

/// Pesagens do card Pesagens anteriores (P-08): todas menos as duas do card
/// Última pesagem, da mais recente para a mais antiga. `[]` com menos de 3.
List<Pesagem> pesagensAnteriores(List<Pesagem> pesagens) =>
    pesagens.length < 3 ? const [] : pesagens.sublist(0, pesagens.length - 2).reversed.toList();

/// Linha de uma pesagem anterior; a primeira de todas termina com
/// ` • peso inicial`.
String linhaPesagemAnterior(Pesagem p, {required bool pesoInicial}) =>
    pesoInicial ? '${linhaPesagem(p)} • peso inicial' : linhaPesagem(p);

/// Card ECC e objetivo: `ECC 7 de 9 • Objetivo não informado` e, com
/// referência, `Informado por Veterinário / consulta em 30 set. 2026.`
String textoEccObjetivo(Referencia? r) {
  final linhas = [linhaEccObjetivo(r)];
  if (r != null) linhas.add('Informado por ${rotuloOrigem(r.origem)} em ${formatarDataCurta(r.data)}.');
  return linhas.join('\n');
}

/// Pesagens mostradas de cada vez em Pesagens anteriores.
const pesagensPorPagina = 10;

/// Aviso fixo do card Indicadores.
const avisoIndicadores = avisoEstimativa;

