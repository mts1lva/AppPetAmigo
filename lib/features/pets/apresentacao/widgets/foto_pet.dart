import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/espacos.dart';
import '../../../../app/tema/tipografia.dart';
import '../../domain/descricao_pet.dart';
import '../../domain/entidades/pet.dart';

/// Foto do pet em círculo de 64 (cabeçalho do Início). Sem foto, ou se o
/// arquivo sumiu, círculo `suave` com a inicial do nome em `secao` (P-14).
///
/// Decorativa: quem a usa já anuncia o nome do pet ao leitor de tela.
class FotoPet extends StatelessWidget {
  const FotoPet({super.key, required this.pet, this.tamanho = PaMedida.fotoPet});

  final Pet pet;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final inicial = Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: PaCores.suave, shape: BoxShape.circle),
      child: Text(inicialDoNome(pet.nome), style: PaTexto.secao),
    );
    final arquivo = pet.fotoArquivo;
    return ExcludeSemantics(
      child: arquivo == null
          ? inicial
          : ClipOval(
              child: Image.file(
                File(arquivo),
                width: tamanho,
                height: tamanho,
                fit: BoxFit.cover,
                // Tamanho decodificado próximo ao exibido (64 dp até 3x).
                cacheWidth: (tamanho * 3).round(),
                errorBuilder: (_, _, _) => inicial,
              ),
            ),
    );
  }
}
