import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/tema/cores.dart';
import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';
import '../formato/datas.dart';
import 'pa_botao.dart';
import 'pa_dialogo.dart';

/// Campos do design system (`design-system.md` → 2. PaCampo).
///
/// Caixa `superficie` com borda `borda` de 1, raio 16, altura **mínima** 64 e
/// padding horizontal de 12. O conteúdo é uma linha "Rótulo • valor" em
/// `corpo`. O rótulo nunca some; com pouco espaço (ou fonte ampliada), o
/// valor quebra para a linha de baixo. Com [erro], a borda fica `erro` e a
/// mensagem aparece embaixo em `legenda`.
///
/// Tipos: [PaCampo] (texto e número), [PaCampoEscolha], [PaCampoData] e
/// [PaCampoHora].
enum PaCampoTipo { texto, numero }

/// Campo de texto ou número: um `TextField` sem decoração depois do prefixo
/// fixo "Rótulo • ". O teclado numérico aceita vírgula e ponto (R10); use
/// `lerNumero` (`core/formato`) para converter o texto.
class PaCampo extends StatefulWidget {
  const PaCampo({
    super.key,
    required this.rotulo,
    required this.controller,
    this.tipo = PaCampoTipo.texto,
    this.sufixo,
    this.erro,
    this.aoMudar,
    this.focusNode,
    this.acaoTeclado = TextInputAction.next,
    this.maxCaracteres,
    this.dica,
  });

  const PaCampo.numero({
    super.key,
    required this.rotulo,
    required this.controller,
    this.sufixo,
    this.erro,
    this.aoMudar,
    this.focusNode,
    this.acaoTeclado = TextInputAction.next,
    this.maxCaracteres,
    this.dica,
  }) : tipo = PaCampoTipo.numero;

  final String rotulo;
  final TextEditingController controller;
  final PaCampoTipo tipo;

  /// Unidade escrita logo depois do valor, ex.: `kg` → `Peso inicial • 5,4 kg`.
  final String? sufixo;
  final String? erro;
  final ValueChanged<String>? aoMudar;
  final FocusNode? focusNode;
  final TextInputAction acaoTeclado;
  final int? maxCaracteres;

  /// Texto mostrado no lugar do valor enquanto o campo está vazio, ex.:
  /// `Não informado` (Objetivo da tela 12). Some ao digitar.
  final String? dica;

  @override
  State<PaCampo> createState() => _PaCampoState();
}

class _PaCampoState extends State<PaCampo> {
  FocusNode? _focoInterno;

  FocusNode get _foco => widget.focusNode ?? (_focoInterno ??= FocusNode());

  @override
  void dispose() {
    _focoInterno?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numero = widget.tipo == PaCampoTipo.numero;
    final sufixo = widget.sufixo;

    return _CaixaCampo(
      erro: widget.erro,
      aoTocar: _foco.requestFocus,
      child: MergeSemantics(
        child: Semantics(
          label: sufixo == null ? widget.rotulo : '${widget.rotulo} ($sufixo)',
          textField: true,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ExcludeSemantics(child: Text('${widget.rotulo} • ', style: PaTexto.corpo)),
              // Vazio, o campo guarda uma largura mínima para o cursor; com
              // valor, encolhe até o texto, e a unidade fica logo depois
              // (`5,4 kg`). A caixa inteira recebe o toque.
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, filho) => ConstrainedBox(
                  constraints: BoxConstraints(minWidth: widget.controller.text.isEmpty ? 48 : 0),
                  child: filho,
                ),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _foco,
                    style: PaTexto.corpo,
                    cursorColor: PaCores.verde,
                    maxLines: null,
                    keyboardType: numero
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                    textInputAction: widget.acaoTeclado,
                    inputFormatters: [
                      if (numero) FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      if (widget.maxCaracteres != null)
                        LengthLimitingTextInputFormatter(widget.maxCaracteres),
                    ],
                    onChanged: widget.aoMudar,
                    decoration: InputDecoration.collapsed(hintText: widget.dica, hintStyle: PaTexto.corpo),
                  ),
                ),
              ),
              if (sufixo != null) ExcludeSemantics(child: Text(' $sufixo', style: PaTexto.corpo)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uma opção de [PaCampoEscolha].
final class PaOpcao<T> {
  const PaOpcao({required this.valor, required this.rotulo});

  final T valor;
  final String rotulo;
}

/// Campo de escolha (Espécie, Castração, Atividade…). O toque abre um
/// `PaDialogo` com as opções como botões `secundario`; a escolhida fica
/// `primario`. "Voltar" fecha sem mudar nada.
class PaCampoEscolha<T> extends StatelessWidget {
  const PaCampoEscolha({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.valor,
    required this.aoEscolher,
    this.erro,
    this.subtituloDialogo,
  });

  final String rotulo;
  final List<PaOpcao<T>> opcoes;
  final T? valor;
  final ValueChanged<T>? aoEscolher;
  final String? erro;
  final String? subtituloDialogo;

  String get _textoValor {
    for (final o in opcoes) {
      if (o.valor == valor) return o.rotulo;
    }
    return '';
  }

  Future<void> _abrir(BuildContext context) async {
    final escolhida = await escolherOpcao<T>(
      context,
      titulo: rotulo,
      subtitulo: subtituloDialogo,
      opcoes: opcoes,
      valorAtual: valor,
    );
    if (escolhida != null) aoEscolher?.call(escolhida.valor);
  }

  @override
  Widget build(BuildContext context) {
    return _CaixaCampo(
      erro: erro,
      rotuloSemantico: rotulo,
      valorSemantico: _textoValor,
      aoTocar: aoEscolher == null ? null : () => _abrir(context),
      child: Text('$rotulo • $_textoValor', style: PaTexto.corpo),
    );
  }
}

/// Diálogo de escolha do design system: as opções como botões `secundario`,
/// a atual em `primario` e "Voltar" por último. Devolve a opção tocada, ou
/// `null` se o tutor voltar. Use para escolhas em mais de um passo (ex.:
/// Idade em anos e depois em meses, com [PaCampoAcao]).
Future<PaOpcao<T>?> escolherOpcao<T>(
  BuildContext context, {
  required String titulo,
  required List<PaOpcao<T>> opcoes,
  T? valorAtual,
  String? subtitulo,
}) {
  return mostrarPaDialogo<PaOpcao<T>>(
    context,
    builder: (contexto) => PaDialogo(
      titulo: titulo,
      subtitulo: subtitulo,
      botoes: [
        for (final o in opcoes)
          PaBotao(
            texto: o.rotulo,
            variante: o.valor == valorAtual ? PaBotaoVariante.primario : PaBotaoVariante.secundario,
            aoTocar: () => Navigator.of(contexto).pop(o),
          ),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(contexto).pop()),
      ],
    ),
  );
}

/// Campo "Rótulo • valor" cujo toque executa [aoTocar], para escolhas que
/// não cabem num único [PaCampoEscolha] (ex.: Idade em anos + meses, tela 05).
/// Mesma caixa e mesma acessibilidade dos outros campos.
class PaCampoAcao extends StatelessWidget {
  const PaCampoAcao({
    super.key,
    required this.rotulo,
    required this.valorTexto,
    required this.aoTocar,
    this.erro,
  });

  final String rotulo;
  final String valorTexto;
  final VoidCallback? aoTocar;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    return _CaixaCampo(
      erro: erro,
      rotuloSemantico: rotulo,
      valorSemantico: valorTexto,
      aoTocar: aoTocar,
      child: Text('$rotulo • $valorTexto', style: PaTexto.corpo),
    );
  }
}

/// Campo de data: o toque abre o `showDatePicker` nativo em pt-BR. Por
/// padrão não aceita datas futuras (R05), então [ultimaData] é hoje.
class PaCampoData extends StatelessWidget {
  const PaCampoData({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.aoEscolher,
    this.primeiraData,
    this.ultimaData,
    this.erro,
  });

  final String rotulo;
  final DateTime? valor;
  final ValueChanged<DateTime>? aoEscolher;
  final DateTime? primeiraData;
  final DateTime? ultimaData;
  final String? erro;

  Future<void> _abrir(BuildContext context) async {
    final agora = DateTime.now();
    final ultima = ultimaData ?? DateTime(agora.year, agora.month, agora.day);
    final primeira = primeiraData ?? DateTime(2000);
    var inicial = valor ?? ultima;
    if (inicial.isAfter(ultima)) inicial = ultima;
    if (inicial.isBefore(primeira)) inicial = primeira;

    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primeira,
      lastDate: ultima,
    );
    if (escolhida != null) aoEscolher?.call(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final texto = valor == null ? '' : formatarDataCurta(valor!);
    return _CaixaCampo(
      erro: erro,
      rotuloSemantico: rotulo,
      valorSemantico: texto,
      aoTocar: aoEscolher == null ? null : () => _abrir(context),
      child: Text('$rotulo • $texto', style: PaTexto.corpo),
    );
  }
}

/// Campo de hora: o toque abre o `showTimePicker` nativo (24 h em pt-BR).
class PaCampoHora extends StatelessWidget {
  const PaCampoHora({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.aoEscolher,
    this.erro,
  });

  final String rotulo;
  final TimeOfDay? valor;
  final ValueChanged<TimeOfDay>? aoEscolher;
  final String? erro;

  Future<void> _abrir(BuildContext context) async {
    final escolhida = await showTimePicker(context: context, initialTime: valor ?? TimeOfDay.now());
    if (escolhida != null) aoEscolher?.call(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final v = valor;
    final texto = v == null ? '' : formatarMinutosDoDia(v.hour * 60 + v.minute);
    return _CaixaCampo(
      erro: erro,
      rotuloSemantico: rotulo,
      valorSemantico: texto,
      aoTocar: aoEscolher == null ? null : () => _abrir(context),
      child: Text('$rotulo • $texto', style: PaTexto.corpo),
    );
  }
}

/// Caixa comum aos campos. Com [rotuloSemantico], vira um único nó de
/// acessibilidade com rótulo, valor e toque (campos que abrem seletor).
class _CaixaCampo extends StatelessWidget {
  const _CaixaCampo({
    required this.child,
    required this.aoTocar,
    this.erro,
    this.rotuloSemantico,
    this.valorSemantico,
  });

  final Widget child;
  final VoidCallback? aoTocar;
  final String? erro;
  final String? rotuloSemantico;
  final String? valorSemantico;

  @override
  Widget build(BuildContext context) {
    Widget caixa = Material(
      color: PaCores.superficie,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PaEspaco.raio),
        side: BorderSide(
          color: erro == null ? PaCores.borda : PaCores.erro,
          width: PaEspaco.bordaLargura,
        ),
      ),
      child: InkWell(
        onTap: aoTocar,
        excludeFromSemantics: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: PaMedida.campoAlturaMin,
            minWidth: double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ),
      ),
    );

    if (rotuloSemantico != null) {
      caixa = Semantics(
        container: true,
        textField: true,
        label: rotuloSemantico,
        value: valorSemantico,
        enabled: aoTocar != null,
        onTap: aoTocar,
        excludeSemantics: true,
        child: caixa,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        caixa,
        // Erro sem texto (ex.: escolha obrigatória em R05) só pinta a borda.
        if (erro != null && erro!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(erro!, style: PaTexto.legenda.copyWith(color: PaCores.erro)),
          ),
      ],
    );
  }
}
