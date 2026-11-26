// Teste oficial T5 — envio em lote (U2-16; pacote-5 → Teste oficial T5).

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/daos/config_dao.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/sync/fake_remoto.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/core/sync/fila_sync_ativa.dart';
import 'package:petamigo/core/sync/motor_sync.dart';
import 'package:petamigo/core/sync/remoto_sync.dart';
import 'package:petamigo/core/sync/wifi.dart';

final class _WifiFalso implements VerificadorWifi {
  _WifiFalso({this.conectado = true});

  bool conectado;

  @override
  Future<bool> estaNoWifi() async => conectado;

  @override
  Stream<bool> observarWifi() => Stream.value(conectado);
}

void main() {
  const uid = 'uid-tutor-1';
  const dispositivo = 'aparelho-a';
  final agora = DateTime(2026, 11, 26, 8);

  late BancoLocal banco;
  late FilaSyncAtiva fila;
  late FakeRemoto remoto;
  late _WifiFalso wifi;

  setUp(() async {
    banco = BancoLocal(NativeDatabase.memory());
    await banco.configDao.gravar(ChavesConfig.copiaRemotaAtiva, 'true');
    await banco.configDao.gravar(ChavesConfig.uid, uid);
    await banco.configDao.gravar(ChavesConfig.dispositivoId, dispositivo);
    fila = FilaSyncAtiva(banco, agora: () => agora);
    remoto = FakeRemoto(agora: () => agora);
    wifi = _WifiFalso(conectado: true);
  });

  tearDown(() => banco.close());

  Future<void> inserirPet(String id, String nome) async {
    await banco.transaction(() async {
      final estado = (await fila.estadoInicial()).name;
      await banco.into(banco.pets).insert(
            PetsCompanion.insert(
              id: id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              nome: nome,
              especie: 'gato',
              sexo: 'femea',
              idadeMeses: 72,
              idadeInformadaEm: agora,
              castrado: true,
              nivelAtividade: 'moderada',
            ),
          );
      await fila.enfileirar(ColecoesSync.pets, id, OperacaoSync.upsert);
    });
  }

  Future<void> inserirPesagem(String id, String petId, double pesoKg) async {
    await banco.transaction(() async {
      final estado = (await fila.estadoInicial()).name;
      await banco.into(banco.pesagens).insert(
            PesagensCompanion.insert(
              id: id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              petId: petId,
              pesoKg: pesoKg,
              dataHora: agora,
            ),
          );
      await fila.enfileirar(ColecoesSync.pesagens, id, OperacaoSync.upsert);
    });
  }

  Future<void> atualizarNomePet(String id, String novoNome) async {
    await banco.transaction(() async {
      final atual = await (banco.select(banco.pets)..where((p) => p.id.equals(id))).getSingle();
      final estado = (await fila.estadoInicial()).name;
      await (banco.update(banco.pets)..where((p) => p.id.equals(id))).write(
        PetsCompanion(
          nome: Value(novoNome),
          versao: Value(atual.versao + 1),
          atualizadoEm: Value(agora),
          estadoSync: Value(estado),
        ),
      );
      await fila.enfileirar(ColecoesSync.pets, id, OperacaoSync.upsert);
    });
  }

  MotorSync criarMotor({int tamanhoLote = tamanhoPadraoLote}) => MotorSync(
        banco: banco,
        remoto: remoto,
        wifi: wifi,
        tamanhoLote: tamanhoLote,
        agora: () => agora,
      );

  group('T5 — Sincronização em lote (U2-16)', () {
    test('5 registros de 2 pets na fila viram 1 commit com 5 escritas; fila vazia; todos sincronizados', () async {
      await inserirPet('p1', 'Luna');
      await inserirPet('p2', 'Thor');
      await inserirPesagem('w1', 'p1', 5.4);
      await inserirPesagem('w2', 'p1', 5.3);
      await inserirPesagem('w3', 'p2', 12.0);

      final resultado = await criarMotor().executarEnvio();

      expect(resultado.falhou, isFalse);
      expect(resultado.lotesEnviados, 1);
      expect(resultado.itensSincronizados, 5);
      expect(remoto.totalCommits, 1);
      expect(remoto.historicoLotes.single, hasLength(5));
      expect(remoto.redeLigada, isFalse, reason: 'desliga a rede ao fim do ciclo');
      expect(await banco.select(banco.itensFilaSync).get(), isEmpty);

      final pets = await banco.select(banco.pets).get();
      final pesagens = await banco.select(banco.pesagens).get();
      expect(pets.every((p) => p.estadoSync == EstadoSync.sincronizado.name && p.versaoRemota == 1), isTrue);
      expect(pesagens.every((w) => w.estadoSync == EstadoSync.sincronizado.name && w.versaoRemota == 1), isTrue);
    });

    test('mesmo registro editado 3 vezes antes do ciclo vira 1 escrita só com o conteúdo final', () async {
      await inserirPet('p1', 'Luna');
      await atualizarNomePet('p1', 'Luna II');
      await atualizarNomePet('p1', 'Luna Final');

      expect(await banco.select(banco.itensFilaSync).get(), hasLength(3));

      final resultado = await criarMotor().executarEnvio();

      expect(resultado.lotesEnviados, 1);
      expect(resultado.itensSincronizados, 1);
      expect(remoto.totalCommits, 1);
      expect(remoto.historicoLotes.single, hasLength(1));
      expect(remoto.lerRemoto(uid, ColecoesSync.pets, 'p1')?.dados['nome'], 'Luna Final');
      expect(remoto.lerRemoto(uid, ColecoesSync.pets, 'p1')?.versao, 3);
      expect(await banco.select(banco.itensFilaSync).get(), isEmpty);
    });

    test('falha no commit não grava nada, mantém a fila, marca falha e tentativas = 1', () async {
      await inserirPet('p1', 'Luna');
      await inserirPesagem('w1', 'p1', 5.4);
      remoto.erroNoProximoCommit = Exception('falha simulada');

      final resultado = await criarMotor().executarEnvio();

      expect(resultado.falhou, isTrue);
      expect(remoto.totalCommits, 0);
      expect(remoto.documentosDaColecao(uid, ColecoesSync.pets), isEmpty);
      expect(remoto.documentosDaColecao(uid, ColecoesSync.pesagens), isEmpty);
      expect(remoto.redeLigada, isFalse);

      final filaRestante = await banco.select(banco.itensFilaSync).get();
      expect(filaRestante, hasLength(2));
      expect(filaRestante.every((i) => i.tentativas == 1 && i.ultimoErro != null), isTrue);

      final pet = await (banco.select(banco.pets)..where((p) => p.id.equals('p1'))).getSingle();
      final pesagem = await (banco.select(banco.pesagens)..where((w) => w.id.equals('w1'))).getSingle();
      expect(pet.estadoSync, EstadoSync.falha.name);
      expect(pesagem.estadoSync, EstadoSync.falha.name);
    });

    test('repetir lote após commit sem confirmação não duplica nem gera conflito falso (regra do dispositivoId)', () async {
      await inserirPet('p1', 'Luna');
      // 1º ciclo ok: versão 1 sincronizada.
      expect((await criarMotor().executarEnvio()).falhou, isFalse);

      // Edição local (versao=2, versaoRemota=1); commit grava no servidor, mas
      // a confirmação se perde (queda de Wi-Fi).
      await atualizarNomePet('p1', 'Luna Editada');
      remoto.falharDepoisDeGravarNoProximoCommit = true;
      final primeiraTentativa = await criarMotor().executarEnvio();
      expect(primeiraTentativa.falhou, isTrue);
      expect(remoto.lerRemoto(uid, ColecoesSync.pets, 'p1')?.versao, 2);

      // Nova edição local antes da repetição; repetição deve reconhecer o mesmo
      // dispositivoId sem abrir conflito falso e sem duplicar o documento.
      await atualizarNomePet('p1', 'Luna Pós-Queda');
      final repeticao = await criarMotor().executarEnvio();

      expect(repeticao.falhou, isFalse);
      expect(repeticao.conflitosDetectados, 0);
      expect(await banco.select(banco.conflitos).get(), isEmpty);
      expect(await banco.select(banco.itensFilaSync).get(), isEmpty);
      expect(remoto.documentosDaColecao(uid, ColecoesSync.pets), hasLength(1));
      expect(remoto.lerRemoto(uid, ColecoesSync.pets, 'p1')?.dados['nome'], 'Luna Pós-Queda');
      expect(remoto.lerRemoto(uid, ColecoesSync.pets, 'p1')?.versao, 2);
    });

    test('item com versão remota de outro aparelho vira conflito e fica fora do lote, sem impedir os outros', () async {
      await inserirPet('p1', 'Luna');
      await inserirPet('p2', 'Thor');
      await criarMotor().executarEnvio();

      // Outro aparelho edita p1 para versão 2.
      remoto.gravarRemoto(
        uid,
        DocumentoRemoto(
          colecao: ColecoesSync.pets,
          id: 'p1',
          dados: const {'nome': 'Luna (outro aparelho)'},
          versao: 2,
          atualizadoEm: agora,
          dispositivoId: 'aparelho-b',
          excluido: false,
        ),
      );

      // Este aparelho edita p1 (conflito) e p2 (sem conflito).
      await atualizarNomePet('p1', 'Luna (local)');
      await atualizarNomePet('p2', 'Thor (local)');

      final resultado = await criarMotor().executarEnvio();

      expect(resultado.falhou, isFalse);
      expect(resultado.conflitosDetectados, 1);
      expect(resultado.itensSincronizados, 1);
      expect(remoto.historicoLotes.last, hasLength(1));
      expect(remoto.historicoLotes.last.single.id, 'p2');
      expect(remoto.lerRemoto(uid, ColecoesSync.pets, 'p2')?.dados['nome'], 'Thor (local)');
      expect(remoto.lerRemoto(uid, ColecoesSync.pets, 'p1')?.dados['nome'], 'Luna (outro aparelho)');

      final conflitos = await banco.select(banco.conflitos).get();
      expect(conflitos, hasLength(1));
      expect(conflitos.single.tabela, ColecoesSync.pets);
      expect(conflitos.single.registroId, 'p1');

      final p1Local = await (banco.select(banco.pets)..where((p) => p.id.equals('p1'))).getSingle();
      final p2Local = await (banco.select(banco.pets)..where((p) => p.id.equals('p2'))).getSingle();
      expect(p1Local.estadoSync, EstadoSync.conflito.name);
      expect(p2Local.estadoSync, EstadoSync.sincronizado.name);
    });

    test('mais de 500 operações são divididas em lotes de até 500', () async {
      await inserirPet('p1', 'Luna');
      // Mais 504 pesagens = 505 registros na fila.
      await banco.transaction(() async {
        for (var i = 0; i < 504; i++) {
          final id = 'w-$i';
          await banco.into(banco.pesagens).insert(
                PesagensCompanion.insert(
                  id: id,
                  criadoEm: agora,
                  atualizadoEm: agora,
                  estadoSync: Value(EstadoSync.pendente.name),
                  petId: 'p1',
                  pesoKg: 5.0 + (i % 10) * 0.1,
                  dataHora: agora.add(Duration(minutes: i)),
                ),
              );
          await fila.enfileirar(ColecoesSync.pesagens, id, OperacaoSync.upsert);
        }
      });

      final resultado = await criarMotor(tamanhoLote: limiteWriteBatch).executarEnvio();

      expect(resultado.falhou, isFalse);
      expect(resultado.itensSincronizados, 505);
      expect(resultado.lotesEnviados, 2);
      expect(remoto.totalCommits, 2);
      expect(remoto.historicoLotes[0], hasLength(500));
      expect(remoto.historicoLotes[1], hasLength(5));
      expect(await banco.select(banco.itensFilaSync).get(), isEmpty);
    });

    test('sem Wi-Fi não liga a rede nem envia nada', () async {
      wifi.conectado = false;
      await inserirPet('p1', 'Luna');

      final resultado = await criarMotor().executarEnvio();

      expect(resultado.ignoradoSemWifi, isTrue);
      expect(remoto.totalTentativasCommit, 0);
      expect(remoto.redeLigada, isFalse);
      expect(await banco.select(banco.itensFilaSync).get(), hasLength(1));
    });

    test('exclusão remota confirmada tem precedência sobre edição local', () async {
      await inserirPet('p1', 'Luna');
      await criarMotor().executarEnvio();

      remoto.gravarRemoto(
        uid,
        DocumentoRemoto(
          colecao: ColecoesSync.pets,
          id: 'p1',
          dados: const {},
          versao: 2,
          atualizadoEm: agora,
          dispositivoId: 'aparelho-b',
          excluido: true,
        ),
      );
      await atualizarNomePet('p1', 'Luna editada após exclusão remota');

      final resultado = await criarMotor().executarEnvio();

      expect(resultado.exclusoesRemotasAplicadas, 1);
      expect(resultado.conflitosDetectados, 0);
      final p1Local = await (banco.select(banco.pets)..where((p) => p.id.equals('p1'))).getSingle();
      expect(p1Local.excluido, isTrue);
      expect(p1Local.estadoSync, EstadoSync.sincronizado.name);
      expect(await banco.select(banco.itensFilaSync).get(), isEmpty);
    });
  });
}
