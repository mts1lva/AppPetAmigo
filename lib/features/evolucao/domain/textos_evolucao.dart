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
