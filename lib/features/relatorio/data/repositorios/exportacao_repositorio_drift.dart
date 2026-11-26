import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../domain/repositorios/exportacao_repositorio.dart';

final class ExportacaoRepositorioDrift implements ExportacaoRepositorio {
  const ExportacaoRepositorioDrift(this._banco);
  final BancoLocal _banco;

  @override
  Future<Map<String, Object?>> carregar() => _banco.transaction(() async {
    final pets = await (_banco.select(
      _banco.pets,
    )..where((p) => p.excluido.equals(false))).get();
    final ativos = pets.map((p) => p.id).toSet();
    Map<String, Object?> limpar(DataClass linha) {
      final json = linha.toJson();
      for (final chave in [
        'criadoEm',
        'atualizadoEm',
        'versao',
        'versaoRemota',
        'estadoSync',
        'excluido',
        'fotoArquivo',
      ]) {
        json.remove(chave);
      }
      for (final chave in ['dataHora', 'data', 'idadeInformadaEm']) {
        final valor = json[chave];
        if (valor is int) {
          json[chave] = DateTime.fromMillisecondsSinceEpoch(valor)
              .toIso8601String();
        }
      }
      return json;
    }

    Future<List<Map<String, Object?>>> registros<
      T extends Table,
      D extends DataClass
    >(TableInfo<T, D> tabela) async {
      final linhas = await _banco.select(tabela).get();
      return [
        for (final linha in linhas)
          if (linha.toJson()['excluido'] == false &&
              ativos.contains(linha.toJson()['petId']))
            limpar(linha),
      ];
    }

    return {
      'formato': 2,
      'pets': pets.map(limpar).toList(),
      'alimentos': await registros(_banco.alimentos),
      'refeicoes': await registros(_banco.refeicoes),
      'extras': await registros(_banco.extras),
      'atividades': await registros(_banco.atividades),
      'lembretes': await registros(_banco.lembretes),
      'pesagens': await registros(_banco.pesagens),
      'referencias': await registros(_banco.referencias),
    };
  });
}
