/// Textos dos cards da tela 01 Início (`pacote-1` → 01; R02, R10, R11).
/// Dart puro: as funções recebem os dados já lidos pelos providers.
library;

import '../../../core/formato/datas.dart';
import '../../../core/formato/numeros.dart';
import '../../../core/resultado.dart';
import '../../../core/sugestao.dart';
import '../../diario/domain/entidades/resumo_dia.dart';
import '../../lembretes/domain/entidades/lembrete.dart';
import '../../nutricao/domain/meta_diaria.dart';
import '../../pets/domain/descricao_pet.dart';
import '../../pets/domain/entidades/pet.dart';
import '../../privacidade/domain/entidades/estado_copia.dart';

const subtituloInicio = 'Um cuidado de cada vez.';

/// Abaixo do nome no cabeçalho, com 2 ou mais pets.
const dicaTrocarPet = 'Trocar de pet';

const tituloReferenciaAlimentar = 'Referência alimentar';
const tituloSugestoes = 'Sugestões';
const tituloLembretes = 'Lembretes';
const tituloSeuControle = 'Seu controle';

const botaoEditarPet = 'Editar pet';
const botaoRegistrarRefeicao = 'Registrar refeição';
const botaoEntenderReferencia = 'Entender a referência';
const botaoConfigurarLembretes = 'Configurar lembretes';
const botaoPrivacidade = 'Privacidade e cópia remota';
const botaoAgoraNao = 'Agora não';

/// Card do pet: `Gata • 6 anos • castrada` / `Atividade moderada • 5,4 kg`.
/// Sem pesagem: `peso não informado`.
String textoPerfil(Pet pet, double? pesoKg, DateTime hoje) {
  final peso = pesoKg == null ? 'peso não informado' : formatarPeso(pesoKg);
  return '${linhaEspecieIdade(pet, hoje)} • ${castracaoTexto(pet)}\n'
      'Atividade ${nivelAtividadeTexto(pet.nivelAtividade)} • $peso';
}

/// Card "Hoje · 30 set." (R02). Sem registros: `Ainda sem registros hoje.`
/// Sem meta (sem pesagem, ou ainda carregando): `Total registrado: …`.
String textoHoje(ResumoDia resumo, Resultado<MetaDiaria>? meta) {
  if (!resumo.temRegistros) return 'Ainda sem registros hoje.';
  final linha1 = 'Ração ${formatarEnergia(resumo.racaoKcal)} • Petiscos ${formatarEnergia(resumo.extrasKcal)}';
  final linha2 = switch (meta) {
    Disponivel(valor: final m) => 'Total: ${formatarNumero(resumo.totalKcal, casas: 0)} de ${formatarEnergia(m.mer)}',
    _ => 'Total registrado: ${formatarEnergia(resumo.totalKcal)}',
  };
  return '$linha1\n$linha2';
}

/// Card "Lembretes": horários dos ativos em ordem (`08:00 • 14:00 • 20:00`)
/// ou `Nenhum lembrete ativo.`
String textoLembretes(List<Lembrete> lembretes) {
  final horas = {
    for (final l in lembretes)
      if (l.ativo) l.horaMinutos,
  }.toList()..sort();
  if (horas.isEmpty) return 'Nenhum lembrete ativo.';
  return horas.map(formatarMinutosDoDia).join(' • ');
}

/// Card "Seu controle". O conflito não tem texto na spec; até o P5 decidir
/// (P5-3.3), aparece como pendente, porque há alterações esperando.
String textoSeuControle(EstadoCopia estado) => switch (estado) {
  CopiaDesligada() => 'Dados salvos neste aparelho.',
  CopiaPendente() || CopiaComConflito() => 'Cópia remota: pendente',
  CopiaSincronizada() => 'Cópia remota: sincronizado',
  CopiaComFalha() => 'Cópia remota: falha',
};

/// Botão de ação de cada sugestão (M8).
String textoAcaoSugestao(TipoSugestao tipo) => switch (tipo) {
  TipoSugestao.mudarObjetivo => 'Ver evolução',
  TipoSugestao.reduzirPetiscos => 'Ver diário',
  TipoSugestao.aumentarExercicios => 'Ver atividades',
};
