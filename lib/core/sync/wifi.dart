import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contrato de verificação de Wi-Fi (`dados-e-sync.md` → Só por Wi-Fi).
///
/// A sincronização só roda quando a conexão atual inclui Wi-Fi; dados móveis
/// nunca disparam envio nem recebimento (RF15, RNF09).
abstract interface class VerificadorWifi {
  /// Indica se o aparelho está conectado a uma rede Wi-Fi neste instante.
  Future<bool> estaNoWifi();

  /// Emite `true`/`false` sempre que o estado de Wi-Fi muda.
  Stream<bool> observarWifi();
}

/// Retorna `true` somente quando a lista de conexões contém Wi-Fi.
bool listaContemWifi(List<ConnectivityResult> conexoes) =>
    conexoes.contains(ConnectivityResult.wifi);

/// Implementação de [VerificadorWifi] sobre `connectivity_plus`.
final class VerificadorWifiConnectivity implements VerificadorWifi {
  factory VerificadorWifiConnectivity([Connectivity? connectivity]) {
    final c = connectivity ?? Connectivity();
    return VerificadorWifiConnectivity.comFonte(
      verificar: c.checkConnectivity,
      observar: () => c.onConnectivityChanged,
    );
  }

  /// Construtor para testes unitários, sem depender de canal de plataforma.
  VerificadorWifiConnectivity.comFonte({
    required Future<List<ConnectivityResult>> Function() verificar,
    required Stream<List<ConnectivityResult>> Function() observar,
  })  : _verificar = verificar,
        _observar = observar;

  final Future<List<ConnectivityResult>> Function() _verificar;
  final Stream<List<ConnectivityResult>> Function() _observar;

  @override
  Future<bool> estaNoWifi() async => listaContemWifi(await _verificar());

  @override
  Stream<bool> observarWifi() => _observar().map(listaContemWifi).distinct();
}

/// Provider do verificador de Wi-Fi usado pelo motor de sincronização.
final verificadorWifiProvider = Provider<VerificadorWifi>(
  (ref) => VerificadorWifiConnectivity(),
);
