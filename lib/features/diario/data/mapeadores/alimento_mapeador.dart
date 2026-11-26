import '../../../../core/formato/numeros.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/alimento.dart';
import '../../domain/entidades/alimento_cadastrado.dart';
import '../../domain/entidades/petisco.dart';

/// Ração ou petisco ↔ documento `usuarios/{uid}/alimentos/{id}` (P-32).
final class AlimentoMapeador implements MapeadorSync<AlimentoCadastrado> {
  const AlimentoMapeador();

  @override
  String get colecao => ColecoesSync.alimentos;

  @override
  String get nomeRegistro => 'alimento';

  @override
  Map<String, Object?> paraFirestore(AlimentoCadastrado alimento) => {
    'petId': alimento.petId,
    'nome': alimento.nome,
    'arquivado': alimento.arquivado,
    ...switch (alimento) {
      Alimento() => {
        'tipo': tipoRacao,
        'densidadeKcalPor100g': alimento.densidadeKcalPor100g,
        'porcaoPadraoG': alimento.porcaoPadraoG,
      },
      Petisco() => {
        'tipo': tipoPetisco,
        'kcalPorUnidade': alimento.kcalPorUnidade,
        'unidadesHabituais': alimento.unidadesHabituais,
      },
      _ => throw ArgumentError('Tipo de alimento cadastrado inválido'),
    },
  };

  @override
  AlimentoCadastrado deFirestore(String id, Map<String, Object?> documento) {
    FormatException erroCampo(String nome) => FormatException('alimentos/$id: campo "$nome" ausente ou inválido');

    T campo<T>(String nome) {
      final valor = documento[nome];
      if (valor is! T) throw erroCampo(nome);
      return valor;
    }

    final tipo = documento.containsKey('tipo') ? campo<String>('tipo') : tipoRacao;
    final petId = campo<String>('petId');
    final nome = campo<String>('nome');
    final arquivado = campo<bool>('arquivado');
    if (tipo == tipoPetisco) {
      final kcalPorUnidade = campo<num>('kcalPorUnidade').toDouble();
      final unidadesHabituais = campo<int>('unidadesHabituais');
      if (!kcalPorUnidade.isFinite || kcalPorUnidade <= 0) throw erroCampo('kcalPorUnidade');
      if (unidadesHabituais <= 0) throw erroCampo('unidadesHabituais');
      return Petisco(
        id: id,
        petId: petId,
        nome: nome,
        kcalPorUnidade: kcalPorUnidade,
        unidadesHabituais: unidadesHabituais,
        arquivado: arquivado,
      );
    }
    if (tipo != tipoRacao) throw erroCampo('tipo');
    return Alimento(
      id: id,
      petId: petId,
      nome: nome,
      densidadeKcalPor100g: campo<num>('densidadeKcalPor100g').toDouble(),
      porcaoPadraoG: campo<num>('porcaoPadraoG').toDouble(),
      arquivado: arquivado,
    );
  }

  @override
  String resumoConflito(AlimentoCadastrado alimento) => switch (alimento) {
    Alimento() =>
      '${formatarNumero(alimento.porcaoPadraoG, casas: 0)} g • '
          '${formatarEnergia(alimento.densidadeKcalPor100g)}/100 g',
    Petisco() => '${alimento.unidadesHabituais} un. • ${formatarEnergia(alimento.kcalPorUnidade)}/un.',
    _ => throw ArgumentError('Tipo de alimento cadastrado inválido'),
  };
}
