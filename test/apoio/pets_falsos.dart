import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:petamigo/features/evolucao/apresentacao/providers/evolucao_providers.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/evolucao/domain/repositorios/pesagem_repositorio.dart';
import 'package:petamigo/features/evolucao/domain/repositorios/referencia_repositorio.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pets_providers.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';
import 'package:petamigo/features/pets/domain/repositorios/fotos_pet.dart';
import 'package:petamigo/features/pets/domain/repositorios/pet_atual_repositorio.dart';
import 'package:petamigo/features/pets/domain/repositorios/pet_repositorio.dart';

/// Luna, a gata do protótipo: 6 anos, castrada, atividade moderada. A idade
/// é informada hoje, para o teste não depender da data em que roda (a idade
/// avança um mês por mês desde `idadeInformadaEm`).
Pet luna({String id = 'p1', String nome = 'Luna'}) => Pet(
      id: id,
      nome: nome,
      especie: Especie.gato,
      sexo: Sexo.femea,
      idadeMeses: 72,
      idadeInformadaEm: _hoje(),
      castrado: true,
      nivelAtividade: NivelAtividade.moderada,
    );

DateTime _hoje() {
  final agora = DateTime.now();
  return DateTime(agora.year, agora.month, agora.day);
}

/// Seletor e armazenamento de fotos falsos: o seletor devolve [proxima] e o
/// armazenamento só anota o que guardou e apagou.
final class FotosFalsas implements SeletorFoto, ArmazenamentoFotos {
  String? proxima;
  final guardadas = <(String, String)>[];
  final apagadas = <String>[];

  @override
  Future<String?> escolher() async => proxima;

  @override
  Future<String> guardar(String origem, {required String petId}) async {
    guardadas.add((origem, petId));
    return '/privado/fotos/$petId-${guardadas.length}.jpg';
  }

  /// Conteúdo dos arquivos "gravados" ou já existentes, por caminho.
  final arquivos = <String, Uint8List>{};

  @override
  Future<String> guardarBytes(Uint8List imagem, {required String petId}) async {
    guardadas.add(('bytes', petId));
    final caminho = '/privado/fotos/$petId-${guardadas.length}.jpg';
    arquivos[caminho] = imagem;
    return caminho;
  }

  @override
  Future<Uint8List?> ler(String caminho) async => arquivos[caminho];

  @override
  Future<void> apagar(String caminho) async => apagadas.add(caminho);
}

/// Pets em memória para widget tests (sem drift, sem timers pendentes).
/// Implementa os dois repositórios do pacote `pets` e guarda as chamadas.
final class PetsFalsos implements PetRepositorio, PetAtualRepositorio {
  PetsFalsos({List<(Pet, double)> iniciais = const []}) {
    for (final (pet, peso) in iniciais) {
      _pets[pet.id] = pet;
      _pesos[pet.id] = peso;
    }
    _atual = iniciais.isEmpty ? null : iniciais.last.$1.id;
  }

  final _pets = <String, Pet>{};
  final _pesos = <String, double>{};
  String? _atual;

  /// Pet atual, para conferir direto nos testes (sem esperar stream).
  String? get atual => _atual;
  final _mudou = StreamController<void>.broadcast();

  final fotos = FotosFalsas();
  final cadastros = <(Pet, double)>[];
  final edicoes = <(Pet, double?)>[];

  /// `pesoInicialConferido` de cada edição, na ordem de [edicoes].
  final conferidos = <bool>[];

  /// Pesagens além do peso inicial, por pet (para a conferência R06 do 05).
  final pesagensExtras = <String, List<Pesagem>>{};

  /// Data do peso inicial nas pesagens falsas.
  static final dataPesoInicial = DateTime(2026, 9, 1, 8);
  final exclusoes = <String>[];

  /// Overrides para o `ProviderScope` do teste.
  List<Override> get overrides => [
        petRepositorioProvider.overrideWithValue(this),
        petAtualRepositorioProvider.overrideWithValue(this),
        novoIdProvider.overrideWithValue(() => 'novo-${cadastros.length + 1}'),
        armazenamentoFotosProvider.overrideWithValue(fotos),
        seletorFotoProvider.overrideWithValue(fotos),
        pesagemRepositorioProvider.overrideWithValue(_PesagensDosPets(this)),
        referenciaRepositorioProvider.overrideWithValue(const _SemReferencia()),
      ];

  Stream<T> _observar<T>(T Function() ler) => Stream.multi((s) {
        s.add(ler());
        final assinatura = _mudou.stream.listen((_) => s.add(ler()));
        s.onCancel = assinatura.cancel;
      });

  void _avisar() => _mudou.add(null);

  @override
  Stream<List<Pet>> observarTodos() => _observar(() => _pets.values.toList());

  @override
  Stream<Pet?> observar(String id) => _observar(() => _pets[id]);

  @override
  Stream<double?> observarPesoInicial(String petId) => _observar(() => _pesos[petId]);

  @override
  Stream<String?> observarId() => _observar(() => _atual);

  @override
  Future<void> definirId(String? petId) async {
    _atual = petId;
    _avisar();
  }

  @override
  Future<void> cadastrar(Pet pet, {required double pesoInicialKg, required DateTime agora}) async {
    cadastros.add((pet, pesoInicialKg));
    _pets[pet.id] = pet;
    _pesos[pet.id] = pesoInicialKg;
    _atual = pet.id;
    _avisar();
  }

  @override
  Future<void> editar(Pet pet, {double? pesoInicialKg, bool pesoInicialConferido = false, required DateTime agora}) async {
    edicoes.add((pet, pesoInicialKg));
    conferidos.add(pesoInicialConferido);
    _pets[pet.id] = pet;
    if (pesoInicialKg != null) _pesos[pet.id] = pesoInicialKg;
    _avisar();
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) async {
    exclusoes.add(id);
    _pets.remove(id);
    _pesos.remove(id);
    if (_atual == id) _atual = _pets.keys.isEmpty ? null : _pets.keys.first;
    _avisar();
  }
}

/// Pesagens vistas pelo formulário 05: o peso inicial de cada pet (em
/// [PetsFalsos.dataPesoInicial]) e as [PetsFalsos.pesagensExtras].
final class _PesagensDosPets implements PesagemRepositorio {
  _PesagensDosPets(this._pets);

  final PetsFalsos _pets;

  List<Pesagem> _de(String petId) {
    final peso = _pets._pesos[petId];
    return [
      if (peso != null)
        Pesagem(id: 'inicial-$petId', petId: petId, pesoKg: peso, dataHora: PetsFalsos.dataPesoInicial),
      ...?_pets.pesagensExtras[petId],
    ];
  }

  @override
  Stream<List<Pesagem>> observarTodas(String petId) => _pets._observar(() => _de(petId));

  @override
  Stream<Pesagem?> observarUltima(String petId) => _pets._observar(() => _de(petId).lastOrNull);

  @override
  Future<void> salvar(Pesagem pesagem, {required DateTime agora}) => throw UnimplementedError();

  @override
  Future<void> excluir(String id, {required DateTime agora}) => throw UnimplementedError();
}

/// Nenhum pet tem ECC nem objetivo (a S3 do Início fica sem sugestão).
final class _SemReferencia implements ReferenciaRepositorio {
  const _SemReferencia();

  @override
  Stream<Referencia?> observarVigente(String petId) => Stream.value(null);

  @override
  Future<void> salvar(Referencia referencia, {required DateTime agora}) => throw UnimplementedError();

  @override
  Future<void> remover(String petId, {required DateTime agora}) => throw UnimplementedError();
}
