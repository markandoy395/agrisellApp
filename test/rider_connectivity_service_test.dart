import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:agresell_app/features/rider/dashboard/data/rider_connectivity_service.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';

void main() {
  final backend = Uri.parse('https://api.agrisell.test/health');
  final network = Uri.parse('https://network.test');

  test('reports backend unavailable when the network still responds', () async {
    final service = HttpRiderConnectivityService(
      backendHealthUri: backend,
      networkCheckUri: network,
      networkChanges: const Stream<void>.empty(),
      client: MockClient((request) async {
        return http.Response('', request.url == backend ? 503 : 204);
      }),
    );
    addTearDown(service.dispose);

    expect(
      await service.checkConnectivity(),
      RiderInternetStatus.backendUnavailable,
    );
  });

  test('reports offline when backend and network probes fail', () async {
    final service = HttpRiderConnectivityService(
      backendHealthUri: backend,
      networkCheckUri: network,
      networkChanges: const Stream<void>.empty(),
      client: MockClient((request) async => throw http.ClientException('down')),
    );
    addTearDown(service.dispose);

    expect(await service.checkConnectivity(), RiderInternetStatus.offline);
  });

  test('an authenticated health response still proves reachability', () async {
    final service = HttpRiderConnectivityService(
      backendHealthUri: backend,
      networkCheckUri: network,
      networkChanges: const Stream<void>.empty(),
      client: MockClient((request) async => http.Response('', 401)),
    );
    addTearDown(service.dispose);

    expect(await service.checkConnectivity(), RiderInternetStatus.online);
  });

  test('rechecks immediately when the device regains a network', () async {
    final networkChanges = StreamController<void>();
    var internetIsAvailable = false;
    final service = HttpRiderConnectivityService(
      networkCheckUri: network,
      networkChanges: networkChanges.stream,
      client: MockClient((request) async {
        if (!internetIsAvailable) throw http.ClientException('down');
        return http.Response('', 204);
      }),
    );
    addTearDown(networkChanges.close);
    addTearDown(service.dispose);

    expect(await service.checkConnectivity(), RiderInternetStatus.offline);

    final recovered = service.connectivityChanges.firstWhere(
      (status) => status == RiderInternetStatus.online,
    );
    internetIsAvailable = true;
    networkChanges.add(null);

    expect(await recovered, RiderInternetStatus.online);
  });
}
