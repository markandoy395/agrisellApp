import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_unavailable_card.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

/// Renders appropriate feedback cards when device location is loading or unavailable.
class RiderMapLocationFallback extends StatelessWidget {
  const RiderMapLocationFallback({required this.controller, super.key});

  final RiderLocationController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    if (state == RiderLocationState.loading ||
        state == RiderLocationState.idle) {
      return const Padding(
        padding: RiderMapStyles.fallbackPadding,
        child: RiderLoadingStateCard(
          title: 'Finding your location',
          message: 'Requesting the current device location.',
        ),
      );
    }

    return Padding(
      padding: RiderMapStyles.fallbackPadding,
      child: RiderMapUnavailableCard(
        title: _titleFor(state),
        message: controller.errorMessage ?? _messageFor(state),
        primaryActionLabel: _primaryLabel(controller, state),
        onPrimaryAction: _primaryAction(controller, state),
      ),
    );
  }

  static String _titleFor(RiderLocationState state) => switch (state) {
    RiderLocationState.serviceDisabled => 'Location services are off',
    RiderLocationState.permissionDenied => 'Location permission is needed',
    RiderLocationState.permissionDeniedForever =>
      'Location permission is blocked',
    RiderLocationState.approximateLocation => 'Precise location is off',
    _ => 'Map location unavailable',
  };

  static String _messageFor(RiderLocationState state) => switch (state) {
    RiderLocationState.serviceDisabled =>
      'Enable device location to display live pickup and delivery routes.',
    RiderLocationState.permissionDenied =>
      'Allow location access to show your position and nearby pickup requests.',
    RiderLocationState.permissionDeniedForever =>
      'Open app settings to grant location access for rider navigation.',
    RiderLocationState.approximateLocation =>
      'Enable precise location before using arrival actions.',
    _ => 'Try refreshing your device location.',
  };

  static String _primaryLabel(
    RiderLocationController controller,
    RiderLocationState state,
  ) =>
      controller.supportsDeviceSettings &&
          (state == RiderLocationState.serviceDisabled ||
              state == RiderLocationState.permissionDeniedForever ||
              state == RiderLocationState.approximateLocation)
      ? 'Open settings'
      : state == RiderLocationState.permissionDenied
      ? 'Allow location'
      : 'Try again';

  static VoidCallback _primaryAction(
    RiderLocationController controller,
    RiderLocationState state,
  ) {
    final action = switch (state) {
      RiderLocationState.serviceDisabled => controller.openLocationSettings,
      RiderLocationState.permissionDeniedForever => controller.openAppSettings,
      RiderLocationState.approximateLocation => controller.openAppSettings,
      _ => null,
    };
    return controller.supportsDeviceSettings && action != null
        ? () => unawaited(action())
        : state == RiderLocationState.permissionDenied
        ? () => unawaited(controller.refresh(requestPermission: true))
        : controller.refresh;
  }
}
