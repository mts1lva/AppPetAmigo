import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/core/sync/fila_sync_provider.dart';
import 'package:petamigo/core/sync/mapeador_sync.dart';

/// Registro e mapeador mínimos, para provar que o contrato é implementável.
final class _Nota {
  const _Nota(this.id, this.texto);

  final String id;
  final String texto;

  @override
  bool operator ==(Object other) => other is _Nota && other.id == id && other.texto == texto;

  @override
  int get hashCode => Object.hash(id, texto);
}

final class _NotaMapeador implements MapeadorSync<_Nota> {
  @override
  String get colecao => 'notas';

  @override
  String get nomeRegistro => 'nota';

  @override
  Map<String, Object?> paraFirestore(_Nota r) => {'texto': r.texto};

  @override
  _Nota deFirestore(String id, Map<String, Object?> doc) => _Nota(id, doc['texto']! as String);

  @override
  String resumoConflito(_Nota r) => r.texto;
}

void main() {
  group('FilaSyncInativa', () {
    test('registros ficam como "local" e enfileirar não faz nada', () async {
      const fila = FilaSyncInativa();
      expect(await fila.estadoInicial(), EstadoSync.local);
      await expectLater(fila.enfileirar(ColecoesSync.pets, 'p1', OperacaoSync.upsert), completes);
      await expectLater(fila.enfileirar(ColecoesSync.pets, 'p1', OperacaoSync.excluir), completes);
    });

    test('é a fila do app até a etapa 5', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(filaSyncProvider), isA<FilaSyncInativa>());
    });
  });

  test('valores gravados no banco seguem dados-e-sync.md', () {
    expect(OperacaoSync.values.map((o) => o.name), ['upsert', 'excluir']);
    expect(EstadoSync.values.map((e) => e.name), ['local', 'pendente', 'sincronizado', 'falha', 'conflito']);
    expect(ColecoesSync.todas, [
      'pets',
      'fotos',
      'alimentos',
      'refeicoes',
      'extras',
      'atividades',
      'lembretes',
      'pesagens',
      'referencias',
    ]);
    expect(ColecoesSync.todas.first, ColecoesSync.pets, reason: 'pets antes, por causa das chaves estrangeiras');
  });

  test('MapeadorSync: ida e volta preserva o registro', () {
    final m = _NotaMapeador();
    const nota = _Nota('n1', 'oi');
    expect(m.deFirestore(nota.id, m.paraFirestore(nota)), nota);
  });
}
