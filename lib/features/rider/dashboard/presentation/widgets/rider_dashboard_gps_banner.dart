import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

Widget? riderGpsBanner(
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
