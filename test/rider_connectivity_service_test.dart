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
      client: MockClient((request) async => throw http.ClientException('down')),
    );
    addTearDown(service.dispose);

    expect(await service.checkConnectivity(), RiderInternetStatus.offline);
  });

  test('an authenticated health response still proves reachability', () async {
    final service = HttpRiderConnectivityService(
      backendHealthUri: backend,
      networkCheckUri: network,
      client: MockClient((request) async => http.Response('', 401)),
    );
    addTearDown(service.dispose);

    expect(await service.checkConnectivity(), RiderInternetStatus.online);
  });
}
