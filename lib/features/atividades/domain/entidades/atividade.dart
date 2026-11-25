import '../parametros.dart';

enum TipoAtividade { passeio, brincadeira }

String nomeTipoAtividade(TipoAtividade tipo) => switch (tipo) {
  TipoAtividade.passeio => 'Passeio',
  TipoAtividade.brincadeira => 'Brincadeira',
};

enum CampoAtividade { duracao, dataHora }

final class Atividade {
  const Atividade({
    required this.id,
    required this.petId,
    required this.tipo,
    required this.duracaoMin,
    required this.dataHora,
  });

  final String id;
  final String petId;
  final TipoAtividade tipo;
  final int duracaoMin;
  final DateTime dataHora;

  @override
  bool operator ==(Object outro) =>
      outro is Atividade &&
      outro.id == id &&
      outro.petId == petId &&
      outro.tipo == tipo &&
      outro.duracaoMin == duracaoMin &&
      outro.dataHora == dataHora;
  @override
  int get hashCode => Object.hash(id, petId, tipo, duracaoMin, dataHora);
}

Map<CampoAtividade, String> validarAtividade(
  Atividade atividade,
  DateTime agora,
) => {
  if (atividade.duracaoMin <= 0 || atividade.duracaoMin > duracaoMaximaMinutos)
    CampoAtividade.duracao: 'Informe a duração em minutos.',
  if (atividade.dataHora.isAfter(agora))
    CampoAtividade.dataHora: 'Escolha uma data até hoje.',
};
