import 'package:image_picker/image_picker.dart';

import '../../domain/repositorios/fotos_pet.dart';

/// Seletor nativo da galeria (no Android 13+, o seletor de fotos do sistema,
/// sem pedir permissão). Medidas de `pacote-1` → Tela 05.
final class SeletorFotoGaleria implements SeletorFoto {
  SeletorFotoGaleria([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> escolher() async {
    final foto = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    return foto?.path;
  }
}
