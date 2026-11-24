import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hora atual. As telas leem "hoje" por aqui, para os testes (e os goldens)
/// poderem fixar a data com `agoraProvider.overrideWithValue(...)`.
final agoraProvider = Provider<DateTime Function()>((ref) => DateTime.now);
