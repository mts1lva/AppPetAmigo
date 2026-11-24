import '../../../core/formato/idade.dart';
import 'entidades/pet.dart';

/// R11 — textos do pet no Início e nos diálogos, flexionados pelo sexo (P-02).
/// Dart puro.

/// `Gato`/`Gata`, `Cão`/`Cadela`.
String nomeEspecie(Especie especie, Sexo sexo) => switch ((especie, sexo)) {
      (Especie.gato, Sexo.macho) => 'Gato',
      (Especie.gato, Sexo.femea) => 'Gata',
      (Especie.cao, Sexo.macho) => 'Cão',
      (Especie.cao, Sexo.femea) => 'Cadela',
    };

/// Espécie exibida, com "filhote" abaixo de 12 meses: `Gata`, `Gata filhote`.
String especieExibida(Pet pet, DateTime hoje) {
  final nome = nomeEspecie(pet.especie, pet.sexo);
  return pet.ehFilhoteEm(hoje) ? '$nome filhote' : nome;
}

/// `castrado`/`castrada`; se não castrado(a): `não castrado`/`não castrada`.
String castracaoTexto(Pet pet) {
  final palavra = pet.sexo == Sexo.femea ? 'castrada' : 'castrado';
  return pet.castrado ? palavra : 'não $palavra';
}

/// Nível de atividade em minúsculas, para `Atividade moderada`.
String nivelAtividadeTexto(NivelAtividade nivel) => switch (nivel) {
      NivelAtividade.baixa => 'baixa',
      NivelAtividade.moderada => 'moderada',
      NivelAtividade.alta => 'alta',
    };

/// Linha do pet no cabeçalho e no N1: `Gata • 6 anos`, `Gata filhote • 6 meses`.
String linhaEspecieIdade(Pet pet, DateTime hoje) =>
    '${especieExibida(pet, hoje)} • ${formatarIdade(pet.idadeMesesEm(hoje))}';

/// Inicial do nome em maiúscula, para o círculo sem foto (P-14).
String inicialDoNome(String nome) {
  final limpo = nome.trim();
  if (limpo.isEmpty) return '';
  return String.fromCharCodes(limpo.runes.take(1)).toUpperCase();
}
