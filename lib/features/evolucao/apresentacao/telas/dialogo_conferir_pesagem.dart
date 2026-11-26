import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/tipografia.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/pesagem_suspeita.dart';
import '../../domain/textos_evolucao.dart';

/// O que o tutor escolheu na tela 25.
sealed class EscolhaConferencia {
  const EscolhaConferencia();
}

/// "Corrigir para {sugestão} kg": salva o valor sugerido.
final class CorrigirParaSugestao extends EscolhaConferencia {
  const CorrigirParaSugestao(this.kg);

  final double kg;
}

/// "Corrigir valor": volta ao 11 com foco no peso.
final class CorrigirValor extends EscolhaConferencia {
  const CorrigirValor();
}

/// "Manter valor informado": salva com `conferida = true`.
final class ManterValor extends EscolhaConferencia {
  const ManterValor();
}

/// Abre a tela 25 Conferir pesagem (R06). Devolve `null` em "Voltar" (volta
/// ao 11 sem salvar), no véu ou no botão voltar do Android.
Future<EscolhaConferencia?> abrirConferirPesagem(
  BuildContext context, {
  required double informadoKg,
  required ConferenciaPesagem conferencia,
}) {
  return mostrarPaDialogo<EscolhaConferencia>(
    context,
    builder: (_) => DialogoConferirPesagem(informadoKg: informadoKg, conferencia: conferencia),
  );
}

class DialogoConferirPesagem extends StatelessWidget {
  const DialogoConferirPesagem({super.key, required this.informadoKg, required this.conferencia});

  final double informadoKg;
  final ConferenciaPesagem conferencia;

  @override
  Widget build(BuildContext context) {
    final sugestao = conferencia.sugestaoKg;
    final anterior = conferencia.anteriorKg;
    void escolher(EscolhaConferencia e) => Navigator.of(context).pop(e);

    return PaDialogo(
      titulo: TextosConferirPesagem.titulo,
      subtitulo: TextosConferirPesagem.subtitulo,
      campos: [
        // Somente leitura, em estado de erro (borda `erro`, sem mensagem).
        PaCampoAcao(
          rotulo: 'Peso informado',
          valorTexto: '${textoPesoDigitado(informadoKg)} kg',
          aoTocar: null,
          erro: '',
        ),
        if (anterior != null) Text(TextosConferirPesagem.texto(anterior), style: PaTexto.corpo),
      ],
      botoes: [
        if (sugestao != null)
          PaBotao.primario(
            texto: TextosConferirPesagem.corrigirPara(sugestao),
            aoTocar: () => escolher(CorrigirParaSugestao(sugestao)),
          )
        else
          PaBotao.primario(texto: 'Corrigir valor', aoTocar: () => escolher(const CorrigirValor())),
        PaBotao.primario(texto: 'Manter valor informado', aoTocar: () => escolher(const ManterValor())),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
