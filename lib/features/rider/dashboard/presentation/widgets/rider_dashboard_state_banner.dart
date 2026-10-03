import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_dashboard_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_dashboard_gps_banner.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_dashboard_stats_banner.dart';
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
    final gpsBanner = riderGpsBanner(
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
        return RiderDashboardStatsBanner(metrics: dashboard.metrics);
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
