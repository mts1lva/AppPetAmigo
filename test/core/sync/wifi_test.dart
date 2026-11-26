import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/sync/wifi.dart';

void main() {
  group('listaContemWifi', () {
    test('retorna true apenas quando ConnectivityResult.wifi está presente', () {
      expect(listaContemWifi([ConnectivityResult.wifi]), isTrue);
      expect(listaContemWifi([ConnectivityResult.mobile, ConnectivityResult.wifi]), isTrue);
      expect(listaContemWifi([ConnectivityResult.mobile]), isFalse);
      expect(listaContemWifi([ConnectivityResult.none]), isFalse);
      expect(listaContemWifi([ConnectivityResult.ethernet]), isFalse);
      expect(listaContemWifi(const []), isFalse);
    });
  });

  group('VerificadorWifiConnectivity', () {
    test('estaNoWifi reflete o resultado atual da fonte', () async {
      var atual = <ConnectivityResult>[ConnectivityResult.mobile];
      final wifi = VerificadorWifiConnectivity.comFonte(
        verificar: () async => atual,
        observar: () => const Stream.empty(),
      );

      expect(await wifi.estaNoWifi(), isFalse);
      atual = [ConnectivityResult.wifi];
      expect(await wifi.estaNoWifi(), isTrue);
    });

    test('observarWifi emite somente transições reais de Wi-Fi (distinct)', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      addTearDown(controller.close);

      final wifi = VerificadorWifiConnectivity.comFonte(
        verificar: () async => [ConnectivityResult.none],
        observar: () => controller.stream,
      );

      final eventos = <bool>[];
      final sub = wifi.observarWifi().listen(eventos.add);
      addTearDown(sub.cancel);

      controller.add([ConnectivityResult.none]);
      controller.add([ConnectivityResult.mobile]);
      controller.add([ConnectivityResult.wifi]);
      controller.add([ConnectivityResult.wifi, ConnectivityResult.mobile]);
      controller.add([ConnectivityResult.mobile]);
      await pumpEventQueue();

      expect(eventos, [false, true, false]);
    });
  });
}
