import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderRequestAccessCard extends StatelessWidget {
  const RiderRequestAccessCard({
    required this.state,
    this.isCheckingLocation = false,
    this.onRetryLocation,
    this.onOpenLocationSettings,
    this.onOpenAppSettings,
    this.onOpenProfile,
    super.key,
  });
  final RiderRequestAccessState state;
  final bool isCheckingLocation;
  final VoidCallback? onRetryLocation;
  final VoidCallback? onOpenLocationSettings;
  final VoidCallback? onOpenAppSettings;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (isCheckingLocation &&
        state == RiderRequestAccessState.locationUnavailable) {
      return const RiderLoadingStateCard(
        title: 'Finding your location',
        message: 'Waiting for a current GPS fix. Keep location enabled.',
      );
    }
    final content = switch (state) {
      RiderRequestAccessState.unauthenticated => (
        'Sign in required',
        'Sign in with an authenticated Rider account to view requests.',
        Icons.lock_outline_rounded,
      ),
      RiderRequestAccessState.offline => (
        'Rider Offline',
        'Go Online and Available from Home to receive nearby requests.',
        Icons.offline_bolt_outlined,
      ),
      RiderRequestAccessState.noInternet => (
        'No internet connection',
        'Reconnect before loading current delivery requests.',
        Icons.wifi_off_rounded,
      ),
      RiderRequestAccessState.backendUnavailable => (
        'Backend unavailable',
        'Internet is connected, but delivery requests cannot be reached.',
        Icons.cloud_off_outlined,
      ),
      RiderRequestAccessState.gpsDisabled => (
        'GPS is disabled',
        'Request estimates use your registered service location. Turn on GPS to confirm an acceptance.',
        Icons.location_disabled_rounded,
      ),
      RiderRequestAccessState.permissionDenied => (
        'Location permission denied',
        'Request estimates use your registered service location. Allow precise GPS to confirm an acceptance.',
        Icons.gps_off_rounded,
      ),
      RiderRequestAccessState.poorGpsAccuracy => (
        'Poor GPS accuracy',
        'Move to an open area. Request estimates use your registered service location until a precise GPS fix is available.',
        Icons.gps_not_fixed_rounded,
      ),
      RiderRequestAccessState.locationUnavailable => (
        'Location unavailable',
        'Request estimates use your registered service location. Current GPS is required before acceptance.',
        Icons.location_searching_rounded,
      ),
      RiderRequestAccessState.registeredLocationMissing => (
        'Registered location missing',
        'Add valid registered service coordinates in your Rider profile before matching requests.',
        Icons.home_work_outlined,
      ),
      RiderRequestAccessState.serviceAreaMissing => (
        'Service area missing',
        'Add your registered service area in your Rider profile before matching requests.',
        Icons.map_outlined,
      ),
      RiderRequestAccessState.invalidServiceRadius => (
        'Service radius unavailable',
        'Update your registered service radius before matching requests.',
        Icons.radar_outlined,
      ),
      RiderRequestAccessState.outsideRegisteredServiceArea => (
        'Outside your registered service area',
        'Only pickups inside your registered coverage are shown. Current GPS still determines distance and deadlines.',
        Icons.wrong_location_outlined,
      ),
      RiderRequestAccessState.activeDeliveryLimit => (
        'Active-delivery limit reached',
        'Complete the current delivery before receiving another request.',
        Icons.route_outlined,
      ),
      RiderRequestAccessState.eligible => throw StateError(
        'Eligible access does not need a state card.',
      ),
    };
    final profileState = switch (state) {
      RiderRequestAccessState.registeredLocationMissing ||
      RiderRequestAccessState.serviceAreaMissing ||
      RiderRequestAccessState.invalidServiceRadius ||
      RiderRequestAccessState.outsideRegisteredServiceArea => true,
      _ => false,
    };
    final action = profileState
        ? onOpenProfile
        : state == RiderRequestAccessState.gpsDisabled
        ? onOpenLocationSettings ?? onRetryLocation
        : state == RiderRequestAccessState.permissionDenied
        ? onOpenAppSettings ?? onRetryLocation
        : onRetryLocation;
    final label = profileState
        ? 'Open profile'
        : state == RiderRequestAccessState.gpsDisabled
        ? 'Enable GPS'
        : state == RiderRequestAccessState.permissionDenied
        ? 'Open settings'
        : 'Retry location';
    return RiderEmptyStateCard(
      title: content.$1,
      message: content.$2,
      icon: content.$3,
      actionLabel: action == null ? null : label,
      onAction: action,
    );
  }
}
