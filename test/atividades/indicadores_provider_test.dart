import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/banco_provider.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/features/atividades/apresentacao/providers/atividades_providers.dart';
import 'package:petamigo/features/atividades/apresentacao/providers/indicadores_atividade_provider.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/lembretes_provider.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/notificacoes_providers.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pets_providers.dart';

import '../apoio/pets_falsos.dart';

Future<void> esperarAte(bool Function() pronto) async {
  for (var i = 0; i < 100 && !pronto(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(
    pronto(),
    isTrue,
    reason: 'O stream deve atualizar os indicadores após a transação.',
  );
}

void main() {
  test('P3-2.1: atividades recalculam gasto e S2; lembretes do Início leem o banco', () async {
    final banco = BancoLocal(NativeDatabase.memory());
    final hoje = DateTime(2026, 9, 30, 20);
    final c = ProviderContainer(
      overrides: [
        bancoProvider.overrideWithValue(banco),
        agoraProvider.overrideWithValue(() => hoje),
        pesoIdealAtividadeProvider.overrideWith((ref, petId) => 4.5),
      ],
    );
    addTearDown(() async {
      c.dispose();
      await banco.close();
    });
    final pets = c.read(petRepositorioProvider);
    await pets.cadastrar(luna(), pesoInicialKg: 5.4, agora: hoje);
    await pets.cadastrar(luna(id: 'p2'), pesoInicialKg: 5.4, agora: hoje);
    c.listen(gastoAtividadeProvider('p1'), (_, _) {});
    c.listen(sugestaoExerciciosProvider('p1'), (_, _) {});
    c.listen(lembretesProvider('p1'), (_, _) {});
    await esperarAte(
      () => c.read(gastoAtividadeProvider('p1')) is Disponivel<double>,
    );
    expect(c.read(gastoAtividadeProvider('p1'))?.valorOuNulo, 0);
    expect(
      c.read(sugestaoExerciciosProvider('p1'))?.texto,
      contains('Mais 15 minutos'),
    );
    final repo = c.read(atividadeRepositorioProvider);
    await repo.salvar(
      Atividade(
        id: 'a1',
        petId: 'p1',
        tipo: TipoAtividade.brincadeira,
        duracaoMin: 10,
        dataHora: hoje,
      ),
      agora: hoje,
    );
    await esperarAte(
      () => (c.read(gastoAtividadeProvider('p1'))?.valorOuNulo ?? 0) > 0,
    );
    expect(
      c.read(gastoAtividadeProvider('p1'))?.valorOuNulo,
      closeTo(5.166 / 14, .001),
    );
    final antes = c.read(gastoAtividadeProvider('p1'))?.valorOuNulo;
    await repo.salvar(
      Atividade(
        id: 'a2',
        petId: 'p2',
        tipo: TipoAtividade.passeio,
        duracaoMin: 600,
        dataHora: hoje,
      ),
      agora: hoje,
    );
    expect(c.read(gastoAtividadeProvider('p1'))?.valorOuNulo, antes);
    await repo.excluir('p1', 'a1', agora: hoje);
    await esperarAte(
      () => c.read(gastoAtividadeProvider('p1'))?.valorOuNulo == 0,
    );
    await c.read(lembreteRepositorioProvider).criarSugeridos('p1', agora: hoje);
    await esperarAte(() => c.read(lembretesProvider('p1')).value?.length == 3);
    expect(c.read(lembretesProvider('p1')).value!.map((l) => l.horaMinutos), [
      480,
      840,
      1200,
    ]);
  });
}
