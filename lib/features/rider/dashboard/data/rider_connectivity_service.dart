import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

abstract interface class RiderConnectivityService {
  Future<RiderInternetStatus> checkConnectivity();

  Stream<RiderInternetStatus> get connectivityChanges;

  void dispose();
}

RiderConnectivityService createDefaultRiderConnectivityService() {
  const backendHealthUrl = String.fromEnvironment('RIDER_BACKEND_HEALTH_URL');
  final configuredBackendUri = backendHealthUrl.trim().isEmpty
      ? null
      : Uri.parse(backendHealthUrl);
  final supabaseHealthUri = AgrisellSupabase.isInitialized
      ? Uri.parse(
          AgrisellSupabase.projectUrl,
        ).replace(path: '/auth/v1/health', query: null, fragment: null)
      : null;
  return HttpRiderConnectivityService(
    // A routing API should not decide whether the whole app is online. These
    // endpoints are only used to distinguish a lost internet connection from
    // an unavailable AgriSell backend.
    networkCheckUri: Uri.parse('https://www.google.com/generate_204'),
    fallbackNetworkCheckUris: [
      Uri.parse('https://www.cloudflare.com/cdn-cgi/trace'),
    ],
    backendHealthUri: configuredBackendUri ?? supabaseHealthUri,
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
    this.fallbackNetworkCheckUris = const [],
    this.backendHealthUri,
    http.Client? client,
    this.timeout = const Duration(seconds: 5),
    Stream<void>? networkChanges,
  }) : _client = client ?? http.Client(),
       _networkChanges =
           networkChanges ?? Connectivity().onConnectivityChanged.map((_) {}) {
    _networkChangeSubscription = _networkChanges.listen((_) {
      // The platform signal only says that an interface changed. Confirm it
      // with a request so captive portals and unusable Wi-Fi are not treated
      // as an internet connection.
      unawaited(checkConnectivity());
    });
  }

  final Uri networkCheckUri;
  final List<Uri> fallbackNetworkCheckUris;
  final Uri? backendHealthUri;
  final Duration timeout;
  final http.Client _client;
  final Stream<void> _networkChanges;
  final StreamController<RiderInternetStatus> _changes =
      StreamController<RiderInternetStatus>.broadcast();
  late final StreamSubscription<void> _networkChangeSubscription;
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
      result = await _isInternetReachable()
          ? RiderInternetStatus.online
          : RiderInternetStatus.offline;
    } else if (await _isReachable(backendUri)) {
      result = RiderInternetStatus.online;
    } else {
      result = await _isInternetReachable()
          ? RiderInternetStatus.backendUnavailable
          : RiderInternetStatus.offline;
    }
    if (!_isDisposed && _lastResult != result) {
      _lastResult = result;
      _changes.add(result);
    }
    return result;
  }

  Future<bool> _isInternetReachable() async {
    if (await _isReachable(networkCheckUri)) return true;
    for (final uri in fallbackNetworkCheckUris) {
      if (await _isReachable(uri)) return true;
    }
    return false;
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
    unawaited(_networkChangeSubscription.cancel());
    _client.close();
    _changes.close();
  }
}
