import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/features/atividades/apresentacao/providers/atividades_providers.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/atividades/domain/repositorios/atividade_repositorio.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/evolucao_providers.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/evolucao/domain/repositorios/pesagem_repositorio.dart';
import 'package:petamigo/features/evolucao/domain/repositorios/referencia_repositorio.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pets_providers.dart';

import 'diario_falso.dart';
import 'pets_falsos.dart';

/// Pesagens, referência, pet Luna, relógio e ids falsos, para os widget
/// tests da Evolução.
final class EvolucaoFalsa {
  EvolucaoFalsa({
    List<Pesagem> pesagens = const [],
    Referencia? referencia,
    DateTime? agora,
    List<Alimento> alimentos = const [],
    List<Refeicao> refeicoes = const [],
    List<Extra> extras = const [],
    List<Atividade> atividades = const [],
  })  : agora = agora ?? DateTime(2026, 9, 30, 9),
        diario = DiarioFalsos(alimentos: alimentos, refeicoes: refeicoes, extras: extras),
        atividades = AtividadesFalsas(atividades) {
    this.pesagens.iniciar(pesagens);
    referencias.atual = referencia;
  }

  final DateTime agora;
  final pesagens = PesagensFalsas();
  final referencias = ReferenciasFalsas();

  /// Refeições e extras (P2), para a ingestão de M4 e a aderência de M7.
  final DiarioFalsos diario;

  /// Atividades (P3), para o gasto de M4.
  final AtividadesFalsas atividades;
  var _ids = 0;

  List<Override> get overrides => [
        petRepositorioProvider.overrideWithValue(PetsFalsos(iniciais: [(luna(), 5.4)])),
        pesagemRepositorioProvider.overrideWithValue(pesagens),
        referenciaRepositorioProvider.overrideWithValue(referencias),
        agoraProvider.overrideWithValue(() => agora),
        novoIdProvider.overrideWithValue(() => 'nova-${++_ids}'),
        ...diario.overrides,
        atividadeRepositorioProvider.overrideWithValue(atividades),
      ];
}

Stream<T> _observar<T>(StreamController<void> mudou, T Function() ler) => Stream.multi((s) {
      s.add(ler());
      final assinatura = mudou.stream.listen((_) => s.add(ler()));
      s.onCancel = assinatura.cancel;
    });

final class PesagensFalsas implements PesagemRepositorio {
  final _porId = <String, Pesagem>{};
  final salvas = <Pesagem>[];
  final excluidas = <String>[];
  final _mudou = StreamController<void>.broadcast();

  void iniciar(List<Pesagem> pesagens) {
    for (final p in pesagens) {
      _porId[p.id] = p;
    }
  }

  List<Pesagem> get todas => _porId.values.toList()..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  @override
  Stream<Pesagem?> observarUltima(String petId) => _observar(_mudou, () => todas.lastOrNull);

  @override
  Stream<List<Pesagem>> observarTodas(String petId) => _observar(_mudou, () => todas);

  @override
  Future<void> salvar(Pesagem pesagem, {required DateTime agora}) async {
    _porId[pesagem.id] = pesagem;
    salvas.add(pesagem);
    _mudou.add(null);
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) async {
    _porId.remove(id);
    excluidas.add(id);
    _mudou.add(null);
  }
}

final class ReferenciasFalsas implements ReferenciaRepositorio {
  Referencia? atual;
  final salvas = <Referencia>[];
  var remocoes = 0;
  final _mudou = StreamController<void>.broadcast();

  @override
  Stream<Referencia?> observarVigente(String petId) => _observar(_mudou, () => atual);

  @override
  Future<void> salvar(Referencia referencia, {required DateTime agora}) async {
    atual = referencia;
    salvas.add(referencia);
    _mudou.add(null);
  }

  @override
  Future<void> remover(String petId, {required DateTime agora}) async {
    atual = null;
    remocoes++;
    _mudou.add(null);
  }
}

/// Atividades do P3 em memória.
final class AtividadesFalsas implements AtividadeRepositorio {
  AtividadesFalsas(List<Atividade> iniciais) : _todas = [...iniciais];

  final List<Atividade> _todas;
  final _mudou = StreamController<void>.broadcast();

  @override
  Stream<List<Atividade>> observar(String petId, {required DateTime inicio, required DateTime fim}) => _observar(
        _mudou,
        () => [
          for (final a in _todas)
            if (a.petId == petId && !a.dataHora.isBefore(inicio) && a.dataHora.isBefore(fim)) a,
        ],
      );

  @override
  Future<void> salvar(Atividade atividade, {required DateTime agora}) async {
    _todas
      ..removeWhere((a) => a.id == atividade.id)
      ..add(atividade);
    _mudou.add(null);
  }

  @override
  Future<void> excluir(String petId, String id, {required DateTime agora}) async {
    _todas.removeWhere((a) => a.id == id);
    _mudou.add(null);
  }
}
