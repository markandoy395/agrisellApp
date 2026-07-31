import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_dashboard_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_offline_state_card.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderDashboardStateBanner extends StatelessWidget {
  const RiderDashboardStateBanner({
    required this.dashboard,
    required this.availability,
    required this.onRetry,
    required this.onEnableGps,
    required this.onRequestPermission,
    required this.onOpenAppSettings,
    required this.onRefreshLocation,
    super.key,
  });

  final RiderDashboardController dashboard;
  final RiderAvailabilityController availability;
  final VoidCallback onRetry;
  final VoidCallback onEnableGps;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onRefreshLocation;

  @override
  Widget build(BuildContext context) {
    if (dashboard.state == RiderDashboardLoadState.initialLoading) {
      return const RiderLoadingStateCard(
        title: 'Loading Rider dashboard',
        message: 'Restoring availability and dashboard summaries.',
      );
    }
    if (dashboard.state == RiderDashboardLoadState.serverError) {
      return RiderErrorStateCard(
        title: 'Dashboard unavailable',
        message: dashboard.errorMessage ?? 'Please try again.',
        retryLabel: 'Retry',
        onRetry: onRetry,
      );
    }
    if (availability.internetStatus == RiderInternetStatus.offline) {
      return RiderOfflineStateCard(
        title: 'No internet connection',
        message:
            'Cached Rider state remains visible. Reconnect to synchronize.',
        actionLabel: 'Retry',
        onAction: onRetry,
      );
    }
    if (availability.internetStatus == RiderInternetStatus.backendUnavailable) {
      return RiderErrorStateCard(
        title: 'AgriSell is unavailable',
        message:
            'Your network is connected, but the AgriSell backend cannot be reached.',
        retryLabel: 'Retry',
        onRetry: onRetry,
      );
    }
    if (availability.internetStatus == RiderInternetStatus.reconnecting) {
      return const RiderLoadingStateCard(
        title: 'Reconnecting',
        message: 'Checking the network and AgriSell backend.',
      );
    }
    final gpsBanner = _gpsBanner(
      availability.gpsStatus,
      onEnableGps: onEnableGps,
      onRequestPermission: onRequestPermission,
      onOpenAppSettings: onOpenAppSettings,
      onRefreshLocation: onRefreshLocation,
    );
    if (gpsBanner != null) return gpsBanner;
    if (availability.isSynchronizing) {
      return const RiderLoadingStateCard(
        title: 'Synchronizing availability',
        message: 'Confirming the authoritative Rider work status.',
      );
    }
    if (dashboard.state == RiderDashboardLoadState.partialData ||
        dashboard.usesTemporaryData ||
        availability.usesTemporaryData) {
      return RiderEmptyStateCard(
        title: 'Partial dashboard data',
        message: dashboard.usesTemporaryData || availability.usesTemporaryData
            ? 'Backend data is unavailable; no sample records are shown.'
            : dashboard.errorMessage ??
                  'Some sections are unavailable. Pull down to refresh.',
        actionLabel: 'Retry',
        onAction: onRetry,
        icon: Icons.info_outline_rounded,
      );
    }
    if (dashboard.state == RiderDashboardLoadState.refreshing) {
      return Semantics(
        label: 'Refreshing Rider dashboard',
        liveRegion: true,
        child: const LinearProgressIndicator(minHeight: 3),
      );
    }
    return const SizedBox.shrink();
  }
}

Widget? _gpsBanner(
  RiderGpsStatus status, {
  required VoidCallback onEnableGps,
  required VoidCallback onRequestPermission,
  required VoidCallback onOpenAppSettings,
  required VoidCallback onRefreshLocation,
}) => switch (status) {
  RiderGpsStatus.disabled => RiderErrorStateCard(
    title: 'GPS is disabled',
    message: 'Turn on device location before going online.',
    retryLabel: 'Enable GPS',
    onRetry: onEnableGps,
  ),
  RiderGpsStatus.permissionDenied => RiderErrorStateCard(
    title: 'Location permission denied',
    message: 'Allow location access before going online.',
    retryLabel: 'Request permission',
    onRetry: onRequestPermission,
  ),
  RiderGpsStatus.permissionDeniedForever => RiderErrorStateCard(
    title: 'Location permission blocked',
    message: 'Open app settings and allow precise location access.',
    retryLabel: 'Open settings',
    onRetry: onOpenAppSettings,
  ),
  RiderGpsStatus.approximateLocation => RiderErrorStateCard(
    title: 'Precise location required',
    message: 'Change AgriSell location access from approximate to precise.',
    retryLabel: 'Open settings',
    onRetry: onOpenAppSettings,
  ),
  RiderGpsStatus.poorAccuracy => RiderEmptyStateCard(
    title: 'Poor GPS accuracy',
    message: 'Move to an open area for a more reliable location.',
    icon: Icons.gps_not_fixed_rounded,
    actionLabel: 'Refresh location',
    onAction: onRefreshLocation,
  ),
  RiderGpsStatus.timedOut => RiderErrorStateCard(
    title: 'Location timed out',
    message: 'Check your GPS signal and try again.',
    retryLabel: 'Retry location',
    onRetry: onRefreshLocation,
  ),
  RiderGpsStatus.unavailable => RiderErrorStateCard(
    title: 'Location unavailable',
    message: 'Check GPS and try refreshing the dashboard.',
    retryLabel: 'Retry location',
    onRetry: onRefreshLocation,
  ),
  RiderGpsStatus.checking || RiderGpsStatus.ready => null,
};
