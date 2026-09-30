import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
    if (dashboard.state == RiderDashboardLoadState.partialData ||
        (dashboard.data?.isPartial ?? false) ||
        dashboard.usesTemporaryData ||
        availability.usesTemporaryData) {
      final hasRefreshError = dashboard.errorMessage != null;
      if (!hasRefreshError) {
        return _DashboardStatsBanner(metrics: dashboard.metrics);
      }
      return RiderEmptyStateCard(
        title: 'Partial dashboard data',
        message: dashboard.errorMessage!,
        actionLabel: 'Retry',
        onAction: onRetry,
        icon: Icons.info_outline_rounded,
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

class _DashboardStatsBanner extends StatelessWidget {
  const _DashboardStatsBanner({required this.metrics});

  final RiderDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: AgrisellColors.authGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dashboard stats',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatsChip(
                label: 'Completed',
                value: '${metrics.todayCompletedDeliveries}',
              ),
              _StatsChip(
                label: 'Earnings',
                value:
                    'PHP ${metrics.todayEstimatedEarnings.toStringAsFixed(2)}',
              ),
              _StatsChip(
                label: 'Messages',
                value: '${metrics.unreadMessageCount}',
              ),
              _StatsChip(
                label: 'Alerts',
                value: '${metrics.unreadNotificationCount}',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _StatsChip extends StatelessWidget {
  const _StatsChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 92),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AgrisellColors.homeBackground,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 13,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
