import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

abstract interface class RiderConnectivityService {
  Future<RiderInternetStatus> checkConnectivity();

  Stream<RiderInternetStatus> get connectivityChanges;

  void dispose();
}

RiderConnectivityService createDefaultRiderConnectivityService() {
  const backendHealthUrl = String.fromEnvironment('RIDER_BACKEND_HEALTH_URL');
  return HttpRiderConnectivityService(
    networkCheckUri: Uri.parse('https://router.project-osrm.org'),
    backendHealthUri: backendHealthUrl.isEmpty
        ? null
        : Uri.parse(backendHealthUrl),
  );
}

/// Temporary connectivity adapter for the local-only Rider data sources.
class TemporaryOnlineRiderConnectivityService
    implements RiderConnectivityService, RiderDataSourceMetadata {
  const TemporaryOnlineRiderConnectivityService();

  @override
  RiderDataOrigin get dataOrigin => RiderDataOrigin.temporaryLocal;

  @override
  Stream<RiderInternetStatus> get connectivityChanges =>
      const Stream<RiderInternetStatus>.empty();

  @override
  Future<RiderInternetStatus> checkConnectivity() async =>
      RiderInternetStatus.online;

  @override
  void dispose() {}
}

/// Backend reachability adapter for use when a health endpoint is configured.
class HttpRiderConnectivityService
    implements RiderConnectivityService, RiderDataSourceMetadata {
  HttpRiderConnectivityService({
    required this.networkCheckUri,
    this.backendHealthUri,
    http.Client? client,
    this.timeout = const Duration(seconds: 5),
  }) : _client = client ?? http.Client();

  final Uri networkCheckUri;
  final Uri? backendHealthUri;
  final Duration timeout;
  final http.Client _client;
  final StreamController<RiderInternetStatus> _changes =
      StreamController<RiderInternetStatus>.broadcast();
  RiderInternetStatus? _lastResult;
  bool _isDisposed = false;

  @override
  RiderDataOrigin get dataOrigin => backendHealthUri == null
      ? RiderDataOrigin.temporaryLocal
      : RiderDataOrigin.backend;

  @override
  Stream<RiderInternetStatus> get connectivityChanges => _changes.stream;

  @override
  Future<RiderInternetStatus> checkConnectivity() async {
    if (_isDisposed) return RiderInternetStatus.unknown;
    final backendUri = backendHealthUri;
    RiderInternetStatus result;
    if (backendUri == null) {
      result = await _isReachable(networkCheckUri)
          ? RiderInternetStatus.online
          : RiderInternetStatus.offline;
    } else if (await _isReachable(backendUri)) {
      result = RiderInternetStatus.online;
    } else {
      result = await _isReachable(networkCheckUri)
          ? RiderInternetStatus.backendUnavailable
          : RiderInternetStatus.offline;
    }
    if (!_isDisposed && _lastResult != result) {
      _lastResult = result;
      _changes.add(result);
    }
    return result;
  }

  Future<bool> _isReachable(Uri uri) async {
    try {
      final response = await _client.head(uri).timeout(timeout);
      return response.statusCode < 500;
    } on Exception {
      return false;
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _client.close();
    _changes.close();
  }
}
