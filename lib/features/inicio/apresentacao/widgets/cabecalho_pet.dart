import 'package:flutter/widgets.dart';

import '../../../../app/tema/espacos.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/widgets/foto_pet.dart';
import '../../../pets/domain/descricao_pet.dart';
import '../../../pets/domain/entidades/pet.dart';
import '../../domain/textos_inicio.dart';

/// Cabeçalho do pet no Início (`pacote-1` → 01, item 3): foto 64 → 12 →
/// nome e `Gata • 6 anos` em `secao` → espaço → gato sorrindo 64 com 22 de
/// margem à direita. Com 2 ou mais pets, `Trocar de pet` em `legenda` abaixo
/// do nome. Tocar abre o N1 Seus pets ([aoTocar]).
class CabecalhoPet extends StatelessWidget {
  const CabecalhoPet({
    super.key,
    required this.pet,
    required this.hoje,
    required this.variosPets,
    required this.aoTocar,
  });

  static const _alturaMin = 80.0;
  static const _margemGato = 22.0;

  final Pet pet;
  final DateTime hoje;
  final bool variosPets;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final linha = linhaEspecieIdade(pet, hoje);
    return Semantics(
      button: true,
      label: '${pet.nome}, $linha',
      hint: 'Abre Seus pets',
      excludeSemantics: true,
      onTap: aoTocar,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: aoTocar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _alturaMin),
          child: Row(
            children: [
              FotoPet(pet: pet),
              const SizedBox(width: PaEspaco.s),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.nome, style: PaTexto.secao),
                    Text(linha, style: PaTexto.secao),
                    if (variosPets) Text(dicaTrocarPet, style: PaTexto.legenda),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: PaEspaco.s, right: _margemGato),
                child: PaGatoSorrindo(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
