/// Textos do Diário (R02, R04, R08, R09) e do atalho. Dart puro: as funções
/// recebem o resumo e a meta já calculados.
library;

import '../../../core/formato/datas.dart';
import '../../../core/formato/numeros.dart';
import '../../../core/resultado.dart';
import '../../nutricao/domain/meta_diaria.dart';
import 'aderencia.dart';
import 'entidades/extra.dart';
import 'entidades/refeicao.dart';
import 'entidades/resumo_dia.dart';

/// R09 — dia sem nenhum registro. Não mostrar "0 kcal".
const textoSemRegistros = 'Sem registros nesta data. Ausência de dados não significa consumo zero.';

const textoSemMeta = 'Registre uma pesagem para ver a meta.';

/// Card "Resumo do dia" do Diário (R02). Duas linhas separadas por `\n`.
/// Sem registros: só [textoSemRegistros] (R09).
String textoResumoDia(ResumoDia resumo, Resultado<MetaDiaria>? meta) {
  if (!resumo.temRegistros) return textoSemRegistros;

  final petiscos = resumo.parcelaExtras == null ? '—' : formatarPercentual(resumo.parcelaExtras!.toDouble());
  final total = formatarNumero(resumo.totalKcal, casas: 0);

  switch (meta) {
    case Disponivel(valor: final m):
      final mer = formatarNumero(m.mer, casas: 0);
      final linha1 = '$total de $mer kcal • Petiscos $petiscos dos registros';
      // Compara os inteiros que a UI mostra, para não escrever "Faltam 0 kcal".
      final falta = (m.mer).round() - resumo.totalKcal.round();
      if (falta == 0) return linha1;
      final linha2 = falta > 0
          ? 'Faltam ${formatarNumero(falta.toDouble(), casas: 0)} kcal para a meta de hoje.'
          : '${formatarNumero((-falta).toDouble(), casas: 0)} kcal acima da meta de hoje.';
      return '$linha1\n$linha2';
    case Indisponivel() || null:
      return '$total kcal • Petiscos $petiscos dos registros\n$textoSemMeta';
  }
}

/// R04 — gramas da meta com a densidade do alimento do atalho, arredondadas
/// ao grama e sempre com "≈". `null` se a conversão for indisponível.
String? textoGramasAproximadas(Resultado<double> gramas) => switch (gramas) {
      Disponivel(:final valor) => '≈ ${formatarNumero(valor, casas: 0)} g',
      Indisponivel() => null,
    };

/// Linha extra do atalho 06 (U2-01): `Meta de hoje: 397 kcal (≈ 110 g)`.
/// Sem meta, `null` (o atalho não mostra a linha). Sem gramas, só as kcal.
String? textoMetaNoAtalho(Resultado<MetaDiaria>? meta, Resultado<double>? gramasDaMeta) {
  switch (meta) {
    case Disponivel(valor: final m):
      final kcal = 'Meta de hoje: ${formatarEnergia(m.mer)}';
      final g = gramasDaMeta == null ? null : textoGramasAproximadas(gramasDaMeta);
      return g == null ? kcal : '$kcal ($g)';
    case Indisponivel() || null:
      return null;
  }
}

/// R08 — depois de salvar uma refeição (tela 20).
String textoRefeicaoSalva({required double antesKcal, required ResumoDia depois}) =>
    'O diário passa de ${formatarNumero(antesKcal, casas: 0)} para ${formatarNumero(depois.totalKcal, casas: 0)} kcal. '
    'Ração ${formatarEnergia(depois.racaoKcal)} • Petiscos ${formatarEnergia(depois.extrasKcal)}. '
    'Continue no seu ritmo.';

/// M7 — `67% (4 de 6 dias com registro)`.
String textoAderencia(Aderencia a) =>
    '${formatarPercentual(a.percentual)} (${a.aderentes} de ${a.diasComRegistro} dias com registro)';

const tituloDiario = 'Diário';
const tituloDiarioAtualizado = 'Diário atualizado';
const textoCardData = 'Confira o que foi registrado.';
const botaoSelecionarData = 'Selecionar data';
const tituloRefeicoes = 'Refeições';
const textoSemRefeicoes = 'Nenhuma refeição registrada.';
const botaoEditarRefeicao = 'Editar refeição';
const botaoAdicionarRefeicao = 'Adicionar refeição';
const tituloPetiscos = 'Petiscos e extras';
const textoSemPetiscos = 'Nenhum petisco registrado.';
const botaoEditarPetisco = 'Editar petisco';
const tituloResumoDoDia = 'Resumo do dia';
const botaoAdicionarPetisco = 'Adicionar petisco';
const tituloAlimentosCard = 'Alimentos e porções';
const textoAlimentosCard = 'Reutilize os valores da embalagem.';
const botaoGerenciarAlimentos = 'Gerenciar alimentos';

const tituloAlimentos = 'Alimentos e porções';
const subtituloAlimentos = 'Valores do rótulo, sem recomendação automática.';
const subtituloAlimentosAtalho = 'Cadastre o alimento para usar o atalho.';
const textoAlimentosFormulario =
    'Registros antigos preservam alimento, densidade e quantidade usados naquele momento.';
const botaoSalvarAlimento = 'Salvar alimento e porção';
const botaoExcluirAlimento = 'Excluir alimento e porção';
const rotuloNovoAlimento = 'Novo alimento…';

const tituloConfiraDensidade = 'Confira a densidade';
const subtituloConfiraDensidade = 'O valor precisa ser positivo.';
const textoConfiraDensidade =
    'Informe o valor e a unidade da embalagem. Não é possível converter com zero.';
const botaoCorrigirValor = 'Corrigir valor';

const tituloRefeicao = 'Refeição';
const subtituloRefeicao = 'Adicionar ou corrigir um registro.';
const botaoSalvarRefeicao = 'Salvar refeição';
const botaoExcluirRegistro = 'Excluir registro';

const tituloPetisco = 'Petisco ou extra';
const subtituloPetisco = 'Categoria separada das refeições.';
const botaoSalvarPetisco = 'Salvar petisco';
const descricaoPetiscoPadrao = 'Petisco';

const tituloAtalho = 'Registrar refeição';
const subtituloAtalho = 'Confira e confirme a porção habitual.';
const botaoConfirmarRefeicao = 'Confirmar refeição';
const botaoAlterarDados = 'Alterar dados';
const rotuloPorcaoHabitual = 'Porção habitual';
const rotuloPorcaoMetade = 'Metade';
const rotuloPorcaoUmaEMeia = 'Uma e meia';
const rotuloOutraQuantidade = 'Outra quantidade…';

const tituloRefeicaoSalva = 'Refeição salva';
const subtituloRefeicaoSalva = 'Salva neste aparelho.';
const botaoConsultarDiarioAtualizado = 'Consultar diário atualizado';

const tituloOutraData = 'Consultar outra data';
const botaoRetomarHoje = 'Retomar registro hoje';

const avisoEducativo = 'Estimativa educativa. Não substitui a avaliação do veterinário.';
const mensagemInformeNome = 'Informe o nome.';
const mensagemQuantidadePositiva = 'A quantidade precisa ser positiva.';
const mensagemInformeEnergia = 'Informe a energia em kcal.';
const mensagemDataAteHoje = 'Escolha uma data até hoje.';
const rotuloAlimento = 'Alimento';
const rotuloDensidade = 'Densidade';
const rotuloPorcaoReutilizavel = 'Porção reutilizável';
const rotuloQuantidade = 'Quantidade';
const rotuloEnergia = 'Energia';
const rotuloEnergiaInformada = 'Energia informada';
const rotuloDescricao = 'Descrição';
const rotuloData = 'Data';
const rotuloHorario = 'Horário';
const rotuloDataHora = 'Data e hora';
const rotuloCampoPorcao = 'Porção';
const sufixoKcalPor100g = 'kcal/100 g';
const sufixoGramas = 'g';
const sufixoKcal = 'kcal';
const textoEnergiaRotuloSufixo = '(rótulo)';

/// `08:00 • Ração habitual • 30 g • 108 kcal`
String linhaRefeicao(Refeicao r) {
  final hora = formatarHora(r.dataHora);
  final q = '${formatarNumero(r.quantidadeG, casas: 0)} g';
  return '$hora • ${r.alimentoNome} • $q • ${formatarEnergia(r.energiaKcal)}';
}

/// `12:00 • Petisco • 3 g • 12 kcal` (sem quantidade: sem o trecho das gramas).
String linhaExtra(Extra e) {
  final hora = formatarHora(e.dataHora);
  final q = e.quantidadeG == null ? null : '${formatarNumero(e.quantidadeG!, casas: 0)} g';
  final kcal = formatarEnergia(e.energiaKcal);
  return q == null ? '$hora • ${e.descricao} • $kcal' : '$hora • ${e.descricao} • $q • $kcal';
}

/// Texto do rótulo no atalho 06.
String textoEnergiaRotulo(double densidadeKcalPor100g) =>
    'Energia do rótulo: ${formatarNumero(densidadeKcalPor100g, casas: 0)} kcal/100 g. '
    'Esta porção não é uma prescrição.';

/// Porção do atalho: `Porção habitual • 30 g / 108 kcal`
String rotuloPorcao(String nome, double gramas, double kcal) =>
    '$nome • ${formatarNumero(gramas, casas: 0)} g / ${formatarNumero(kcal, casas: 0)} kcal';
