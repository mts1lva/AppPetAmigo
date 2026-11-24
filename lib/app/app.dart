import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'router.dart';
import 'tema/tema.dart';

/// Raiz do app: tema, locale pt-BR e rotas.
class PetAmigoApp extends ConsumerWidget {
  const PetAmigoApp({super.key});

  static const locale = Locale('pt', 'BR');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PetAmigo',
      debugShowCheckedModeBanner: false,
      theme: PaTema.claro,
      locale: locale,
      supportedLocales: const [locale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(roteadorProvider),
    );
  }
}
