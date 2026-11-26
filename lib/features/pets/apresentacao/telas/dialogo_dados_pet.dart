import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/formato/formato.dart';
import '../../../../core/ui/ui.dart';
import '../../../evolucao/apresentacao/providers/evolucao_providers.dart';
import '../../../evolucao/apresentacao/telas/dialogo_conferir_pesagem.dart';
import '../../../evolucao/domain/textos_evolucao.dart';
import '../../domain/entidades/dados_pet.dart';
import '../../domain/entidades/pet.dart';
import '../providers/pets_providers.dart';

/// Abre o diálogo 05 Dados do pet (`pacote-1` → Tela 05): cadastro quando
/// [petId] é nulo, edição quando não é.
Future<void> abrirDadosPet(BuildContext context, {String? petId}) {
  return mostrarPaDialogo<void>(context, builder: (_) => DialogoDadosPet(petId: petId));
}

/// Opções dos campos de escolha (`pacote-1` → Tela 05; P-02 e P-13).
abstract final class OpcoesPet {
  static const especie = [
    PaOpcao(valor: Especie.cao, rotulo: 'Cão'),
    PaOpcao(valor: Especie.gato, rotulo: 'Gato'),
  ];
  static const sexo = [
    PaOpcao(valor: Sexo.macho, rotulo: 'Macho'),
    PaOpcao(valor: Sexo.femea, rotulo: 'Fêmea'),
  ];
  static const castracao = [
    PaOpcao(valor: true, rotulo: 'Sim'),
    PaOpcao(valor: false, rotulo: 'Não'),
  ];
  static const atividade = [
    PaOpcao(valor: NivelAtividade.baixa, rotulo: 'Baixa'),
    PaOpcao(valor: NivelAtividade.moderada, rotulo: 'Moderada'),
    PaOpcao(valor: NivelAtividade.alta, rotulo: 'Alta'),
  ];
  static final anos = [
    for (var a = 0; a <= idadeMaximaAnos; a++) PaOpcao(valor: a, rotulo: a == 1 ? '1 ano' : '$a anos'),
  ];
  static final meses = [
    for (var m = 0; m <= 11; m++) PaOpcao(valor: m, rotulo: m == 1 ? '1 mês' : '$m meses'),
  ];
}

class DialogoDadosPet extends ConsumerStatefulWidget {
  const DialogoDadosPet({super.key, this.petId});

  final String? petId;

  @override
  ConsumerState<DialogoDadosPet> createState() => _DialogoDadosPetState();
}

class _DialogoDadosPetState extends ConsumerState<DialogoDadosPet> {
  final _nome = TextEditingController();
  final _peso = TextEditingController();
  final _focoNome = FocusNode();
  final _focoPeso = FocusNode();
  final _chaves = {for (final c in CampoPet.values) c: GlobalKey()};

  Especie? _especie;
  Sexo? _sexo;
  int? _anos;
  int? _meses;
  bool? _castrado;
  NivelAtividade? _atividade;

  /// Foto escolhida na galeria (arquivo temporário). Só é copiada para a área
  /// privada ao salvar; voltar sem salvar não guarda nada.
  String? _fotoEscolhida;

  Map<CampoPet, String> _erros = const {};
  var _salvando = false;
  var _preenchido = false;
  double? _pesoInicialSalvo;

  bool get _edicao => widget.petId != null;

  @override
  void dispose() {
    _nome.dispose();
    _peso.dispose();
    _focoNome.dispose();
    _focoPeso.dispose();
    super.dispose();
  }

  /// Na edição, preenche o formulário uma única vez com os dados salvos.
  void _preencher(Pet pet, double? pesoInicial) {
    final d = DadosPet.dePet(pet, hoje: DateTime.now(), pesoInicialKg: pesoInicial);
    _nome.text = d.nome;
    _especie = d.especie;
    _sexo = d.sexo;
    _anos = d.anos;
    _meses = d.meses;
    _castrado = d.castrado;
    _atividade = d.nivelAtividade;
    _pesoInicialSalvo = pesoInicial;
    _peso.text = pesoInicial == null ? '' : _textoPeso(pesoInicial);
    _preenchido = true;
  }

  /// Peso para editar: vírgula decimal e sem zeros à direita (`5,4`, `20`).
  static String _textoPeso(double kg) {
    final texto = formatarNumero(kg, casas: 2).replaceAll('.', '');
    return texto.contains(',') ? texto.replaceFirst(RegExp(r',?0+$'), '') : texto;
  }

  DadosPet get _dados => DadosPet(
        nome: _nome.text,
        especie: _especie,
        sexo: _sexo,
        anos: _anos,
        meses: _meses,
        castrado: _castrado,
        nivelAtividade: _atividade,
        pesoInicialKg: lerNumero(_peso.text),
      );

  Future<void> _escolherIdade() async {
    final anos = await escolherOpcao<int>(context, titulo: 'Idade (anos)', opcoes: OpcoesPet.anos, valorAtual: _anos);
    if (anos == null || !mounted) return;
    final meses =
        await escolherOpcao<int>(context, titulo: 'Idade (meses)', opcoes: OpcoesPet.meses, valorAtual: _meses);
    if (meses == null) return;
    _alterar(() {
      _anos = anos.valor;
      _meses = meses.valor;
    }, CampoPet.idade);
  }

  /// Aplica a mudança e tira o erro do campo, se havia.
  void _alterar(VoidCallback mudanca, CampoPet campo) {
    setState(() {
      mudanca();
      if (_erros.containsKey(campo)) _erros = Map.of(_erros)..remove(campo);
    });
  }

  /// Tela 25 para o peso inicial novo [kg]. Devolve `false` para salvar sem
  /// conferência (valor comum ou corrigido pela sugestão, que já vai para o
  /// campo), `true` para salvar o valor mantido como `conferida` e `null`
  /// para não salvar ("Voltar" ou "Corrigir valor", que leva o foco ao peso).
  Future<bool?> _conferirPesoInicial(String petId, double kg) async {
    final pesagens = await ref.read(pesagensProvider(petId).future);
    final inicial = pesagens.firstOrNull;
    if (inicial == null || !mounted) return false;
    final conferencia = ref.read(salvarPesagemProvider).conferir(
          pesagens: pesagens,
          novoKg: kg,
          dataHora: inicial.dataHora,
          ignorarId: inicial.id,
        );
    if (!conferencia.suspeita) return false;

    final escolha = await abrirConferirPesagem(context, informadoKg: kg, conferencia: conferencia);
    switch (escolha) {
      case null:
        return null;
      case CorrigirValor():
        _focoPeso.requestFocus();
        return null;
      case CorrigirParaSugestao(kg: final sugestao):
        _peso.text = textoPesoDigitado(sugestao);
        return false;
      case ManterValor():
        return true;
    }
  }

  Future<void> _salvar() async {
    var dados = _dados;
    final erros = validarDadosPet(dados);
    if (erros.isNotEmpty) {
      setState(() => _erros = erros);
      _irParaPrimeiroErro(erros.keys.first);
      return;
    }

    // R06 (U2-06): mudar o peso inicial passa pela conferência de pesagem
    // suspeita, comparando com a pesagem seguinte (P4-2.1).
    final petId = widget.petId;
    var conferido = false;
    if (petId != null && dados.pesoInicialKg != _pesoInicialSalvo) {
      final conferencia = await _conferirPesoInicial(petId, dados.pesoInicialKg!);
      if (conferencia == null) return;
      conferido = conferencia;
      dados = _dados;
    }

    setState(() => _salvando = true);
    try {
      final agora = DateTime.now();
      if (petId == null) {
        await ref.read(cadastrarPetProvider)(dados, agora: agora, fotoEscolhida: _fotoEscolhida);
      } else {
        final atual = ref.read(petProvider(petId)).value;
        if (atual == null) return;
        await ref.read(editarPetProvider)(
          atual,
          dados,
          pesoInicialAtualKg: _pesoInicialSalvo,
          agora: agora,
          pesoInicialConferido: conferido,
          fotoEscolhida: _fotoEscolhida,
        );
      }
      // Só fecha depois que a transação terminou (sem UI otimista).
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  /// R05: o botão continua habilitado e leva o foco ao primeiro campo com erro.
  void _irParaPrimeiroErro(CampoPet campo) {
    final contexto = _chaves[campo]!.currentContext;
    if (contexto != null) Scrollable.ensureVisible(contexto, duration: const Duration(milliseconds: 200));
    switch (campo) {
      case CampoPet.nome:
        _focoNome.requestFocus();
      case CampoPet.pesoInicial:
        _focoPeso.requestFocus();
      default:
        FocusScope.of(context).unfocus();
    }
  }

  Future<void> _escolherFoto() async {
    final foto = await ref.read(seletorFotoProvider).escolher();
    if (foto != null && mounted) setState(() => _fotoEscolhida = foto);
  }

  Future<void> _excluir() async {
    final pet = ref.read(petProvider(widget.petId!)).value;
    if (pet == null) return;
    final excluir = ref.read(excluirPetProvider);
    final navegador = Navigator.of(context);
    if (!await confirmarExclusao(context)) return;
    // Quem chamou a tela 23 fecha o próprio diálogo e executa a exclusão.
    navegador.pop();
    await excluir(pet, agora: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final petId = widget.petId;
    Pet? pet;
    if (petId != null) {
      pet = ref.watch(petProvider(petId)).value;
      final peso = ref.watch(pesoInicialProvider(petId));
      // Pronto para a conferência do peso inicial ao salvar (R06).
      ref.watch(pesagensProvider(petId));
      if (!_preenchido && pet != null && peso.hasValue) _preencher(pet, peso.value);
    }
    final quantidadePets = ref.watch(petsProvider).value?.length ?? 0;
    final carregandoEdicao = _edicao && !_preenchido;

    Widget campo(CampoPet c, Widget filho) => KeyedSubtree(key: _chaves[c], child: filho);

    return PaDialogo(
      titulo: _edicao && pet != null ? 'Dados de ${pet.nome}' : 'Dados do pet',
      subtitulo: 'Cadastro e edição no mesmo formulário.',
      campos: carregandoEdicao
          ? const []
          : [
              campo(
                CampoPet.nome,
                PaCampo(
                  rotulo: 'Nome',
                  controller: _nome,
                  focusNode: _focoNome,
                  maxCaracteres: tamanhoMaximoNome,
                  erro: _erros[CampoPet.nome],
                  aoMudar: (_) => _alterar(() {}, CampoPet.nome),
                ),
              ),
              campo(
                CampoPet.especie,
                PaCampoEscolha<Especie>(
                  rotulo: 'Espécie',
                  opcoes: OpcoesPet.especie,
                  valor: _especie,
                  erro: _erros[CampoPet.especie],
                  aoEscolher: (v) => _alterar(() => _especie = v, CampoPet.especie),
                ),
              ),
              campo(
                CampoPet.sexo,
                PaCampoEscolha<Sexo>(
                  rotulo: 'Sexo',
                  opcoes: OpcoesPet.sexo,
                  valor: _sexo,
                  erro: _erros[CampoPet.sexo],
                  aoEscolher: (v) => _alterar(() => _sexo = v, CampoPet.sexo),
                ),
              ),
              campo(
                CampoPet.idade,
                PaCampoAcao(
                  rotulo: 'Idade',
                  valorTexto: (_anos == null || _meses == null) ? '' : formatarIdade(_anos! * 12 + _meses!),
                  erro: _erros[CampoPet.idade],
                  aoTocar: _escolherIdade,
                ),
              ),
              campo(
                CampoPet.castracao,
                PaCampoEscolha<bool>(
                  rotulo: 'Castração',
                  opcoes: OpcoesPet.castracao,
                  valor: _castrado,
                  erro: _erros[CampoPet.castracao],
                  aoEscolher: (v) => _alterar(() => _castrado = v, CampoPet.castracao),
                ),
              ),
              campo(
                CampoPet.atividade,
                PaCampoEscolha<NivelAtividade>(
                  rotulo: 'Atividade',
                  opcoes: OpcoesPet.atividade,
                  valor: _atividade,
                  erro: _erros[CampoPet.atividade],
                  aoEscolher: (v) => _alterar(() => _atividade = v, CampoPet.atividade),
                ),
              ),
              campo(
                CampoPet.pesoInicial,
                PaCampo.numero(
                  rotulo: 'Peso inicial',
                  controller: _peso,
                  focusNode: _focoPeso,
                  sufixo: 'kg',
                  acaoTeclado: TextInputAction.done,
                  erro: _erros[CampoPet.pesoInicial],
                  aoMudar: (_) => _alterar(() {}, CampoPet.pesoInicial),
                ),
              ),
            ],
      botoes: [
        PaBotao.primario(texto: 'Adicionar ou trocar foto', aoTocar: carregandoEdicao ? null : _escolherFoto),
        PaBotao.primario(texto: 'Salvar pet', carregando: _salvando, aoTocar: carregandoEdicao ? null : _salvar),
        if (_edicao && quantidadePets >= 2) PaBotao.perigo(texto: 'Excluir este pet', aoTocar: _excluir),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
