import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../data/gerador_exportacao.dart';
import '../../data/repositorios/exportacao_repositorio_drift.dart';

/// Contrato entregue ao P5: gerarJson() é chamado pelo botão Exportar dados.
final geradorExportacaoProvider = Provider(
  (ref) =>
      GeradorExportacao(ExportacaoRepositorioDrift(ref.watch(bancoProvider))),
);
