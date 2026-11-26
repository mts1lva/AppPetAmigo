/// Textos de tela da Evolução que mais de um lugar usa (`pacote-4`, R10).
/// Dart puro.
library;

import '../../../core/formato/datas.dart';
import '../../../core/formato/numeros.dart';
import 'entidades/pesagem.dart';
import 'entidades/referencia.dart';

/// Rótulos de "Origem" da tela 12 (P-13).
String rotuloOrigem(OrigemReferencia origem) => switch (origem) {
      OrigemReferencia.veterinario => 'Veterinário / consulta',
      OrigemReferencia.outroProfissional => 'Outro profissional',
      OrigemReferencia.tutor => 'Tutor',
    };

/// ECC na escala de 9 pontos: `7 de 9`.
String rotuloEcc(int ecc) => '$ecc de 9';

/// `{peso} • {data}`, como no card Última pesagem: `5,4 kg • 30 set. 2026`.
String linhaPesagem(Pesagem p) => '${formatarPeso(p.pesoKg)} • ${formatarDataCurta(p.dataHora)}';

/// `ECC 7 de 9 • Objetivo 4,5 kg`, com `não informado` no que faltar (card
/// ECC e objetivo da tela 04).
String linhaEccObjetivo(Referencia? r) {
  final ecc = r?.ecc;
  final objetivo = r?.objetivoKg;
  return 'ECC ${ecc == null ? 'não informado' : rotuloEcc(ecc)} • '
      'Objetivo ${objetivo == null ? 'não informado' : formatarPeso(objetivo)}';
}

/// Peso como o tutor digitaria: vírgula decimal, até 3 casas e sem zeros à
/// direita (`5,4`, `54`, `5,43`). Usado para preencher o campo Peso e nos
/// valores da tela 25, que mostram o número informado sem arredondar.
String textoPesoDigitado(double kg) {
  final texto = formatarNumero(kg, casas: 3).replaceAll('.', '');
  return texto.replaceFirst(RegExp(r',?0+$'), '');
}

/// Tela 11 — subtítulo e texto (`pacote-4`).
abstract final class TextosPesagem {
  static const titulo = 'Pesagem';
  static const tituloPesoInicial = 'Peso inicial';
  static const subtitulo = 'Valores positivos em quilogramas.';
  static const aviso = 'Variações suspeitas exigem conferência; o registro não é descartado silenciosamente.';
}

/// Tela 25 — Conferir pesagem (`pacote-4`, R06).
abstract final class TextosConferirPesagem {
  static const titulo = 'Conferir pesagem';
  static const subtitulo = 'Valor fora do esperado.';

  static String texto(double anteriorKg) =>
      'Anterior: ${formatarPeso(anteriorKg)}. Confira unidade e separador decimal. '
      'Corrija ou mantenha o valor; nenhum dado será descartado silenciosamente.';

  static String corrigirPara(double sugestaoKg) => 'Corrigir para ${textoPesoDigitado(sugestaoKg)} kg';
}

/// N3 — Pesagem salva (`pacote-4`, R08).
abstract final class TextosPesagemSalva {
  static const titulo = 'Pesagem salva';
  static const subtitulo = 'Salva neste aparelho.';
}

/// Tela 12 — ECC e objetivo (`pacote-4`).
abstract final class TextosReferencias {
  static const titulo = 'ECC e objetivo';
  static const subtitulo = 'Informações orientadas pelo veterinário.';
  static const naoInformado = 'Não informado';
  static const explicacao =
      'ECC é o escore de condição corporal. Precisa de avaliação profissional; peso isolado não diagnostica.';

  static String pesoIdealEstimado(double kg) => 'Peso ideal estimado pelo ECC: ${formatarPeso(kg)}.';
}
