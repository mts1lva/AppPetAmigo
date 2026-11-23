import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/daos/config_dao.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/features/pets/data/repositorios/pet_atual_repositorio_drift.dart';

void main() {
  late BancoLocal banco;

  setUp(() => banco = BancoLocal(NativeDatabase.memory()));
  tearDown(() => banco.close());

  test('PetAtualRepositorioDrift lê e grava config.petAtualId', () async {
    final repo = PetAtualRepositorioDrift(banco.configDao);
    expect(await repo.observarId().first, isNull);

    await repo.definirId('p1');
    expect(await repo.observarId().first, 'p1');
    expect(await banco.configDao.ler(ChavesConfig.petAtualId), 'p1');

    await repo.definirId(null);
    expect(await repo.observarId().first, isNull);
  });
}
