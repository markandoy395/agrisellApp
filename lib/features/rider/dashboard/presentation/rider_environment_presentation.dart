import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';

extension RiderGpsStatusPresentation on RiderGpsStatus {
  String get displayLabel => switch (this) {
    RiderGpsStatus.checking => 'GPS checking',
    RiderGpsStatus.ready => 'GPS ready',
    RiderGpsStatus.disabled => 'GPS disabled',
    RiderGpsStatus.permissionDenied => 'GPS permission denied',
    RiderGpsStatus.permissionDeniedForever => 'GPS permission blocked',
    RiderGpsStatus.approximateLocation => 'Approximate location',
    RiderGpsStatus.poorAccuracy => 'Poor GPS accuracy',
    RiderGpsStatus.timedOut => 'GPS timed out',
    RiderGpsStatus.unavailable => 'GPS unavailable',
  };
}

extension RiderInternetStatusPresentation on RiderInternetStatus {
  String get displayLabel => switch (this) {
    RiderInternetStatus.unknown => 'Connection unknown',
    RiderInternetStatus.checking => 'Internet checking',
    RiderInternetStatus.online => 'Backend connected',
    RiderInternetStatus.offline => 'No internet',
    RiderInternetStatus.reconnecting => 'Reconnecting',
    RiderInternetStatus.backendUnavailable => 'Backend unavailable',
  };
}
