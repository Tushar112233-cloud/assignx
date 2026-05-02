import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superviser_app/core/services/connectivity_service.dart';

void main() {
  group('ConnectivityState', () {
    test('default state has unknown status', () {
      const state = ConnectivityState();
      expect(state.status, ConnectionStatus.unknown);
      expect(state.isConnected, isTrue);
    });

    test('copyWith creates new state with updated values', () {
      const state = ConnectivityState();
      final newState = state.copyWith(
        status: ConnectionStatus.online,
        isConnected: true,
        connectionTypes: [ConnectivityResult.wifi],
      );

      expect(newState.status, ConnectionStatus.online);
      expect(newState.isConnected, isTrue);
      expect(newState.connectionTypes, contains(ConnectivityResult.wifi));
    });

    test('isWifi returns true when connected via WiFi', () {
      const state = ConnectivityState(
        connectionTypes: [ConnectivityResult.wifi],
        isConnected: true,
      );
      expect(state.isWifi, isTrue);
      expect(state.isMobile, isFalse);
    });

    test('isMobile returns true when connected via mobile data', () {
      const state = ConnectivityState(
        connectionTypes: [ConnectivityResult.mobile],
        isConnected: true,
      );
      expect(state.isMobile, isTrue);
      expect(state.isWifi, isFalse);
    });

    test('isEthernet returns true when connected via ethernet', () {
      const state = ConnectivityState(
        connectionTypes: [ConnectivityResult.ethernet],
        isConnected: true,
      );
      expect(state.isEthernet, isTrue);
    });

    test('connectionDescription returns correct text for WiFi', () {
      const state = ConnectivityState(
        connectionTypes: [ConnectivityResult.wifi],
        isConnected: true,
      );
      expect(state.connectionDescription, 'Connected via WiFi');
    });

    test('connectionDescription returns correct text for mobile', () {
      const state = ConnectivityState(
        connectionTypes: [ConnectivityResult.mobile],
        isConnected: true,
      );
      expect(state.connectionDescription, 'Connected via Mobile Data');
    });

    test('connectionDescription returns correct text when offline', () {
      const state = ConnectivityState(
        connectionTypes: [ConnectivityResult.none],
        isConnected: false,
      );
      expect(state.connectionDescription, 'No internet connection');
    });
  });

  group('ConnectionStatus', () {
    test('has correct values', () {
      expect(ConnectionStatus.values.length, 3);
      expect(ConnectionStatus.online, isNotNull);
      expect(ConnectionStatus.offline, isNotNull);
      expect(ConnectionStatus.unknown, isNotNull);
    });
  });
}
