import 'package:flutter/widgets.dart';

import '../../app/tema/espacos.dart';

/// Intercala [filhos] com o espaço padrão de 12 (`PaEspaco.s`), para colunas
/// de cards, diálogos e telas principais.
List<Widget> espacar(List<Widget> filhos, {double espaco = PaEspaco.s}) => [
      for (var i = 0; i < filhos.length; i++) ...[
        if (i > 0) SizedBox(height: espaco),
        filhos[i],
      ],
    ];
