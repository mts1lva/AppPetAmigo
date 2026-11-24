/// Foto do pet (`pacote-1` → Tela 05; P1-1.4). Dart puro: as implementações
/// ficam em `data/fotos/` (image_picker e path_provider).
library;

/// Abre o seletor nativo de fotos (galeria).
abstract interface class SeletorFoto {
  /// Caminho da foto escolhida (arquivo temporário), ou `null` se o tutor
  /// desistir.
  Future<String?> escolher();
}

/// Fotos guardadas na área privada do app (RNF04).
abstract interface class ArmazenamentoFotos {
  /// Copia a foto de [origem] para a área privada e devolve o novo caminho
  /// (sempre um arquivo novo, para não reaproveitar a imagem em cache).
  Future<String> guardar(String origem, {required String petId});

  /// Apaga a foto; não faz nada se ela já não existe.
  Future<void> apagar(String caminho);
}
