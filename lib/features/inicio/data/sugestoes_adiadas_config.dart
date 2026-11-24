import 'dart:convert';

import '../../../core/banco/daos/config_dao.dart';
import '../../../core/sugestao.dart';
import '../domain/repositorios/sugestoes_adiadas_repositorio.dart';

/// Guarda as sugestões adiadas na tabela `config` (chave
/// `sugestoesAdiadas`), como JSON `{"reduzirPetiscos": "2026-09-30", …}`.
/// A tabela `config` não é sincronizada, então não passa pela `FilaSync`.
final class SugestoesAdiadasConfig implements SugestoesAdiadasRepositorio {
  const SugestoesAdiadasConfig(this._config);

  final ConfigDao _config;

  @override
  Stream<Map<TipoSugestao, DateTime>> observar() => _config.observar(ChavesConfig.sugestoesAdiadas).map(lerAdiadas);

  @override
  Future<void> adiar(TipoSugestao tipo, DateTime em) async {
    final atuais = lerAdiadas(await _config.ler(ChavesConfig.sugestoesAdiadas));
    atuais[tipo] = DateTime(em.year, em.month, em.day);
    await _config.gravar(ChavesConfig.sugestoesAdiadas, gravarAdiadas(atuais));
  }
}

/// JSON → mapa. Ignora tipos desconhecidos e datas mal formadas.
Map<TipoSugestao, DateTime> lerAdiadas(String? json) {
  if (json == null || json.isEmpty) return {};
  final Object? dados;
  try {
    dados = jsonDecode(json);
  } on FormatException {
    return {};
  }
  if (dados is! Map<String, dynamic>) return {};
  final adiadas = <TipoSugestao, DateTime>{};
  for (final tipo in TipoSugestao.values) {
    final valor = dados[tipo.name];
    final data = valor is String ? DateTime.tryParse(valor) : null;
    if (data != null) adiadas[tipo] = data;
  }
  return adiadas;
}

/// Mapa → JSON, com a data no formato `AAAA-MM-DD`.
String gravarAdiadas(Map<TipoSugestao, DateTime> adiadas) => jsonEncode({
  for (final e in adiadas.entries)
    e.key.name:
        '${e.value.year.toString().padLeft(4, '0')}-'
        '${e.value.month.toString().padLeft(2, '0')}-${e.value.day.toString().padLeft(2, '0')}',
});
