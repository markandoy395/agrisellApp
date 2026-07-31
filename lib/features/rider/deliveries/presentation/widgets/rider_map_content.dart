import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_unavailable_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_route_panel.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderMapContent extends StatelessWidget {
  const RiderMapContent({
    required this.controller,
    required this.mapController,
    required this.requests,
    required this.routeController,
    required this.riderId,
    required this.onMapReady,
    required this.onPositionChanged,
    super.key,
  });

  final RiderLocationController controller;
  final MapController mapController;
  final List<DeliveryRequest> requests;
  final RiderRouteController routeController;
  final String? riderId;
  final VoidCallback onMapReady;
  final PositionCallback onPositionChanged;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    if (state == RiderLocationState.loading ||
        state == RiderLocationState.idle) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: RiderLoadingStateCard(
          title: 'Finding your location',
          message: 'Requesting the current device location.',
        ),
      );
    }
    final location = controller.location;
    if ((state == RiderLocationState.ready ||
            state == RiderLocationState.approximateLocation) &&
        location != null) {
      final riderPoint = routeController.displayPoint(location);
      return Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 156),
              child: RiderLiveMap(
                riderPoint: riderPoint,
                routes: routeController.routes,
                activeRoute: routeController.activeRoute,
                requests: requests,
                mapController: mapController,
                riderId: riderId,
                onMapReady: onMapReady,
                onPositionChanged: onPositionChanged,
              ),
            ),
          ),
          Positioned(
            right: 26,
            bottom: 300,
            child: FloatingActionButton.small(
              heroTag: 'rider-map-recenter',
              tooltip: 'Center on current road position',
              onPressed: () => mapController.move(
                LatLng(riderPoint.latitude, riderPoint.longitude),
                16,
              ),
              backgroundColor: AgrisellColors.surface,
              foregroundColor: AgrisellColors.authGreen,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 160,
            child: RiderRoutePanel(
              controller: routeController,
              requests: requests,
              location: location,
              locationController: controller,
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(14),
      child: RiderMapUnavailableCard(
        title: _titleFor(state),
        message: controller.errorMessage ?? _messageFor(state),
        primaryActionLabel: _primaryLabel(controller, state),
        onPrimaryAction: _primaryAction(controller, state),
      ),
    );
  }

  String _titleFor(RiderLocationState state) => switch (state) {
    RiderLocationState.serviceDisabled => 'Location services are off',
    RiderLocationState.permissionDenied => 'Location permission is needed',
    RiderLocationState.permissionDeniedForever =>
      'Location permission is blocked',
    RiderLocationState.approximateLocation => 'Precise location is off',
    _ => 'Map location unavailable',
  };

  String _messageFor(RiderLocationState state) => switch (state) {
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

  String _primaryLabel(
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

  VoidCallback _primaryAction(
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
