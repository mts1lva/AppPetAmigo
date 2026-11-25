import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:petamigo/features/diario/apresentacao/providers/repositorios_providers.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/diario/domain/periodo.dart';
import 'package:petamigo/features/diario/domain/repositorios/alimento_repositorio.dart';
import 'package:petamigo/features/diario/domain/repositorios/extra_repositorio.dart';
import 'package:petamigo/features/diario/domain/repositorios/refeicao_repositorio.dart';

/// Repositórios do diário em memória, para widget tests.
final class DiarioFalsos {
  DiarioFalsos({
    List<Alimento> alimentos = const [],
    List<Refeicao> refeicoes = const [],
    List<Extra> extras = const [],
  }) : alimentos = AlimentoRepositorioFalso(alimentos),
       refeicoes = RefeicaoRepositorioFalso(refeicoes),
       extras = ExtraRepositorioFalso(extras) {
    this.alimentos._refeicoes = this.refeicoes;
    this.refeicoes._avisarAtalho = this.alimentos._avisar;
    this.extras._avisarAtalho = this.alimentos._avisar;
  }

  final AlimentoRepositorioFalso alimentos;
  final RefeicaoRepositorioFalso refeicoes;
  final ExtraRepositorioFalso extras;

  List<Override> get overrides => [
        alimentoRepositorioProvider.overrideWithValue(alimentos),
        refeicaoRepositorioProvider.overrideWithValue(refeicoes),
        extraRepositorioProvider.overrideWithValue(extras),
      ];
}

final class _Hub {
  final mudou = StreamController<void>.broadcast();
  void avisar() => mudou.add(null);
  Stream<T> observar<T>(T Function() ler) => Stream.multi((s) {
        s.add(ler());
        final a = mudou.stream.listen((_) => s.add(ler()));
        s.onCancel = a.cancel;
      });
}

final class AlimentoRepositorioFalso implements AlimentoRepositorio {
  AlimentoRepositorioFalso(List<Alimento> iniciais) {
    for (final a in iniciais) {
      _itens[a.id] = a;
    }
  }

  final _hub = _Hub();
  final _itens = <String, Alimento>{};
  RefeicaoRepositorioFalso? _refeicoes;
  final salvos = <Alimento>[];
  final arquivados = <String>[];
  Future<void> Function()? antesDeGravar;

  void _avisar() => _hub.avisar();

  @override
  Stream<List<Alimento>> observarDoPet(String petId) => _hub.observar(
        () => _itens.values.where((a) => a.petId == petId && !a.arquivado).toList(),
      );

  @override
  Stream<Alimento?> observar(String id) => _hub.observar(() => _itens[id]);

  @override
  Stream<Alimento?> observarAtalho(String petId) => _hub.observar(() {
        final ativos = _itens.values.where((a) => a.petId == petId && !a.arquivado).toList();
        if (ativos.isEmpty) return null;
        final lista = _refeicoes?._itens.values.where((r) => r.petId == petId).toList() ?? [];
        lista.sort((a, b) => b.dataHora.compareTo(a.dataHora));
        for (final r in lista) {
          final id = r.alimentoId;
          if (id == null) continue;
          for (final a in ativos) {
            if (a.id == id) return a;
          }
        }
        return ativos.last;
      });

  @override
  Future<void> salvar(Alimento alimento, {required DateTime agora}) async {
    await antesDeGravar?.call();
    salvos.add(alimento);
    _itens[alimento.id] = alimento;
    _hub.avisar();
  }

  @override
  Future<void> arquivar(String id, {required DateTime agora}) async {
    await antesDeGravar?.call();
    arquivados.add(id);
    final atual = _itens[id];
    if (atual != null) _itens[id] = atual.copyWith(arquivado: true);
    _hub.avisar();
  }
}

final class RefeicaoRepositorioFalso implements RefeicaoRepositorio {
  RefeicaoRepositorioFalso(List<Refeicao> iniciais) {
    for (final r in iniciais) {
      _itens[r.id] = r;
    }
  }

  final _hub = _Hub();
  final _itens = <String, Refeicao>{};
  void Function()? _avisarAtalho;
  final salvas = <Refeicao>[];
  final excluidas = <String>[];

  @override
  Stream<List<Refeicao>> observarEntre(String petId, DateTime inicio, DateTime fim) => _hub.observar(
        () => _itens.values
            .where((r) => r.petId == petId && !r.dataHora.isBefore(inicio) && r.dataHora.isBefore(fim))
            .toList()
          ..sort((a, b) => a.dataHora.compareTo(b.dataHora)),
      );

  @override
  Stream<Refeicao?> observarMaisRecente(String petId) => _hub.observar(() {
        final lista = _itens.values.where((r) => r.petId == petId).toList()
          ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
        return lista.isEmpty ? null : lista.first;
      });

  @override
  Stream<Refeicao?> observarMaisRecenteDoDia(String petId, DateTime dia) => _hub.observar(() {
        final inicio = diaDe(dia);
        final fim = inicio.add(const Duration(days: 1));
        final lista = _itens.values
            .where((r) => r.petId == petId && !r.dataHora.isBefore(inicio) && r.dataHora.isBefore(fim))
            .toList()
          ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
        return lista.isEmpty ? null : lista.first;
      });

  @override
  Stream<Refeicao?> observar(String id) => _hub.observar(() => _itens[id]);

  @override
  Future<void> salvar(Refeicao refeicao, {required DateTime agora}) async {
    salvas.add(refeicao);
    _itens[refeicao.id] = refeicao;
    _hub.avisar();
    _avisarAtalho?.call();
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) async {
    excluidas.add(id);
    _itens.remove(id);
    _hub.avisar();
    _avisarAtalho?.call();
  }
}

final class ExtraRepositorioFalso implements ExtraRepositorio {
  ExtraRepositorioFalso(List<Extra> iniciais) {
    for (final e in iniciais) {
      _itens[e.id] = e;
    }
  }

  final _hub = _Hub();
  final _itens = <String, Extra>{};
  void Function()? _avisarAtalho;
  final salvos = <Extra>[];
  final excluidos = <String>[];

  @override
  Stream<List<Extra>> observarEntre(String petId, DateTime inicio, DateTime fim) => _hub.observar(
        () => _itens.values
            .where((e) => e.petId == petId && !e.dataHora.isBefore(inicio) && e.dataHora.isBefore(fim))
            .toList()
          ..sort((a, b) => a.dataHora.compareTo(b.dataHora)),
      );

  @override
  Stream<Extra?> observarMaisRecenteDoDia(String petId, DateTime dia) => _hub.observar(() {
        final inicio = diaDe(dia);
        final fim = inicio.add(const Duration(days: 1));
        final lista = _itens.values
            .where((e) => e.petId == petId && !e.dataHora.isBefore(inicio) && e.dataHora.isBefore(fim))
            .toList()
          ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
        return lista.isEmpty ? null : lista.first;
      });

  @override
  Stream<Extra?> observar(String id) => _hub.observar(() => _itens[id]);

  @override
  Future<void> salvar(Extra extra, {required DateTime agora}) async {
    salvos.add(extra);
    _itens[extra.id] = extra;
    _hub.avisar();
    _avisarAtalho?.call();
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) async {
    excluidos.add(id);
    _itens.remove(id);
    _hub.avisar();
    _avisarAtalho?.call();
  }
}

Alimento racaoHabitual({String petId = 'p1'}) => Alimento(
      id: 'a1',
      petId: petId,
      nome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      porcaoPadraoG: 30,
    );

Refeicao refeicaoHabitual({String petId = 'p1', DateTime? quando}) => Refeicao(
      id: 'r1',
      petId: petId,
      alimentoId: 'a1',
      alimentoNome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      quantidadeG: 30,
      energiaKcal: 108,
      dataHora: quando ?? DateTime(2026, 9, 30, 8),
    );

Extra extraHabitual({String petId = 'p1', DateTime? quando}) => Extra(
      id: 'e1',
      petId: petId,
      descricao: 'Petisco',
      quantidadeG: 3,
      energiaKcal: 12,
      dataHora: quando ?? DateTime(2026, 9, 30, 12),
    );
