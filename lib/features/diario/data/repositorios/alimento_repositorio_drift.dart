import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/alimento.dart';
import '../../domain/repositorios/alimento_repositorio.dart';
import 'petisco_repositorio_drift.dart';

/// Rações no drift: gravação atômica com a fila; exclusão **arquiva**.
///
/// A tabela `alimentos` também guarda os petiscos cadastrados (P-32), que são
/// de [PetiscoRepositorioDrift]: toda leitura daqui filtra `tipo = racao`.
final class AlimentoRepositorioDrift implements AlimentoRepositorio {
  AlimentoRepositorioDrift(this._banco, this._fila);

  final BancoLocal _banco;
  final FilaSync _fila;

  SimpleSelectStatement<$AlimentosTable, AlimentoLinha> _ativosDoPet(String petId) =>
      _banco.select(_banco.alimentos)
        ..where((a) => a.petId.equals(petId) & _racao(a) & a.excluido.equals(false) & a.arquivado.equals(false));

  @override
  Stream<List<Alimento>> observarDoPet(String petId) => (_ativosDoPet(petId)
        ..orderBy([
          (a) => OrderingTerm.desc(a.criadoEm),
          (a) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
        ]))
      .watch()
      .map((linhas) => linhas.map(_paraEntidade).toList());

  @override
  Stream<Alimento?> observar(String id) => (_banco.select(_banco.alimentos)
        ..where((a) => a.id.equals(id) & _racao(a) & a.excluido.equals(false) & a.arquivado.equals(false)))
      .watchSingleOrNull()
      .map((linha) => linha == null ? null : _paraEntidade(linha));

  @override
  Stream<Alimento?> observarAtalho(String petId) {
    final alimentos = (_banco.select(_banco.alimentos)
          ..where((a) => a.petId.equals(petId) & _racao(a) & a.excluido.equals(false)))
        .watch();
    final refeicoes = (_banco.select(_banco.refeicoes)
          ..where((r) => r.petId.equals(petId) & r.excluido.equals(false)))
        .watch();
    return Stream.multi((listener) {
      List<AlimentoLinha>? a;
      List<RefeicaoLinha>? r;
      void emitir() {
        if (a == null || r == null) return;
        listener.add(_escolherAtalho(a!, r!));
      }

      final sa = alimentos.listen((v) {
        a = v;
        emitir();
      });
      final sr = refeicoes.listen((v) {
        r = v;
        emitir();
      });
      listener.onCancel = () {
        sa.cancel();
        sr.cancel();
      };
    });
  }

  static Alimento? _escolherAtalho(List<AlimentoLinha> alimentos, List<RefeicaoLinha> refeicoes) {
    final ativos = [for (final a in alimentos) if (!a.arquivado) a];
    if (ativos.isEmpty) return null;
    final porId = {for (final a in ativos) a.id: a};
    final refeicoesOrdenadas = [...refeicoes]
      ..sort((x, y) {
        final porHora = y.dataHora.compareTo(x.dataHora);
        if (porHora != 0) return porHora;
        return y.criadoEm.compareTo(x.criadoEm);
      });
    for (final r in refeicoesOrdenadas) {
      final id = r.alimentoId;
      if (id != null && porId.containsKey(id)) return _paraEntidade(porId[id]!);
    }
    ativos.sort((x, y) {
      final porCriacao = y.criadoEm.compareTo(x.criadoEm);
      if (porCriacao != 0) return porCriacao;
      return y.id.compareTo(x.id);
    });
    return _paraEntidade(ativos.first);
  }

  @override
  Future<void> salvar(Alimento alimento, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual =
          await (_banco.select(_banco.alimentos)..where((a) => a.id.equals(alimento.id))).getSingleOrNull();
      final estado = (await _fila.estadoInicial()).name;
      if (atual == null) {
        await _banco.into(_banco.alimentos).insert(AlimentosCompanion.insert(
              id: alimento.id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              petId: alimento.petId,
              nome: alimento.nome,
              tipo: const Value(tipoRacao),
              densidadeKcalPor100g: Value(alimento.densidadeKcalPor100g),
              porcaoPadraoG: Value(alimento.porcaoPadraoG),
              arquivado: Value(alimento.arquivado),
            ));
      } else {
        await (_banco.update(_banco.alimentos)..where((a) => a.id.equals(alimento.id))).write(AlimentosCompanion(
          nome: Value(alimento.nome),
          densidadeKcalPor100g: Value(alimento.densidadeKcalPor100g),
          porcaoPadraoG: Value(alimento.porcaoPadraoG),
          arquivado: Value(alimento.arquivado),
          versao: Value(atual.versao + 1),
          atualizadoEm: Value(agora),
          estadoSync: Value(estado),
        ));
      }
      await _fila.enfileirar(ColecoesSync.alimentos, alimento.id, OperacaoSync.upsert);
    });
  }

  @override
  Future<void> arquivar(String id, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_banco.select(_banco.alimentos)
            ..where((a) => a.id.equals(id) & a.excluido.equals(false)))
          .getSingleOrNull();
      if (atual == null || atual.arquivado) return;
      final estado = (await _fila.estadoInicial()).name;
      await (_banco.update(_banco.alimentos)..where((a) => a.id.equals(id))).write(AlimentosCompanion(
        arquivado: const Value(true),
        versao: Value(atual.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.alimentos, id, OperacaoSync.upsert);
    });
  }

  static Expression<bool> _racao($AlimentosTable a) => a.tipo.equals(tipoRacao);

  /// Só recebe linhas `tipo = racao`, que sempre têm densidade e porção.
  static Alimento _paraEntidade(AlimentoLinha l) => Alimento(
        id: l.id,
        petId: l.petId,
        nome: l.nome,
        densidadeKcalPor100g: l.densidadeKcalPor100g!,
        porcaoPadraoG: l.porcaoPadraoG!,
        arquivado: l.arquivado,
      );
}
