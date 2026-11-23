/// Entidade do pet (`dados-e-sync.md` → tabela `pets`). Dart puro.
///
/// Os nomes dos valores dos enums são os mesmos gravados no banco e no
/// Firestore (`cao`, `gato`, `macho`, `femea`, `baixa`, `moderada`, `alta`).
library;

enum Especie { cao, gato }

enum Sexo { macho, femea }

enum NivelAtividade { baixa, moderada, alta }

/// Abaixo desta idade o pet é filhote (fator 3,0 em M1; briefing B-c).
const idadeFilhoteMeses = 12;

final class Pet {
  const Pet({
    required this.id,
    required this.nome,
    required this.especie,
    required this.sexo,
    required this.idadeMeses,
    required this.idadeInformadaEm,
    required this.castrado,
    required this.nivelAtividade,
    this.fotoArquivo,
  });

  final String id;
  final String nome;
  final Especie especie;
  final Sexo sexo;

  /// Idade informada no cadastro, em meses.
  final int idadeMeses;

  /// Data em que [idadeMeses] foi informada.
  final DateTime idadeInformadaEm;
  final bool castrado;
  final NivelAtividade nivelAtividade;

  /// Caminho da foto na área privada do app, ou `null` sem foto.
  final String? fotoArquivo;

  /// Idade atual = `idadeMeses` + meses completos desde `idadeInformadaEm`.
  int idadeMesesEm(DateTime hoje) => idadeMeses + mesesCompletosEntre(idadeInformadaEm, hoje);

  bool ehFilhoteEm(DateTime hoje) => idadeMesesEm(hoje) < idadeFilhoteMeses;

  Pet copyWith({
    String? nome,
    Especie? especie,
    Sexo? sexo,
    int? idadeMeses,
    DateTime? idadeInformadaEm,
    bool? castrado,
    NivelAtividade? nivelAtividade,
    String? Function()? fotoArquivo,
  }) {
    return Pet(
      id: id,
      nome: nome ?? this.nome,
      especie: especie ?? this.especie,
      sexo: sexo ?? this.sexo,
      idadeMeses: idadeMeses ?? this.idadeMeses,
      idadeInformadaEm: idadeInformadaEm ?? this.idadeInformadaEm,
      castrado: castrado ?? this.castrado,
      nivelAtividade: nivelAtividade ?? this.nivelAtividade,
      fotoArquivo: fotoArquivo == null ? this.fotoArquivo : fotoArquivo(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Pet &&
      other.id == id &&
      other.nome == nome &&
      other.especie == especie &&
      other.sexo == sexo &&
      other.idadeMeses == idadeMeses &&
      other.idadeInformadaEm == idadeInformadaEm &&
      other.castrado == castrado &&
      other.nivelAtividade == nivelAtividade &&
      other.fotoArquivo == fotoArquivo;

  @override
  int get hashCode => Object.hash(
        id, nome, especie, sexo, idadeMeses, idadeInformadaEm, castrado, nivelAtividade, fotoArquivo);

  /// Sem o nome nem a foto: logs nunca expõem dados do pet.
  @override
  String toString() => 'Pet($id)';
}

/// Meses completos entre [inicio] e [fim] (0 se [fim] for anterior).
/// Ex.: 15/03 → 14/04 = 0; 15/03 → 15/04 = 1.
int mesesCompletosEntre(DateTime inicio, DateTime fim) {
  var meses = (fim.year - inicio.year) * 12 + (fim.month - inicio.month);
  if (fim.day < inicio.day) meses--;
  return meses < 0 ? 0 : meses;
}
