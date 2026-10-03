import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_marker_sheet_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_marker_content.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_farm_marker_content.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';

/// Displays the bottom sheet modal for a delivery request marker (pickup or delivery).
Future<bool> showRiderMapMarkerSheet(
  BuildContext context, {
  required DeliveryRequest request,
  required RiderMapMarkerKind kind,
  required double? distanceKm,
  required int? travelMinutes,
  required bool navigationBlockedByActiveDelivery,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: RiderMapMarkerSheetStyles.surfaceColor,
    builder: (context) => RiderDeliveryMarkerContent(
      request: request,
      kind: kind,
      distanceKm: distanceKm,
      travelMinutes: travelMinutes,
      navigationBlockedByActiveDelivery: navigationBlockedByActiveDelivery,
      onNavigate: () => Navigator.of(context).pop(true),
    ),
  );
  return result ?? false;
}

/// Displays the bottom sheet modal for a nearby farm marker.
Future<bool> showRiderMapFarmSheet(
  BuildContext context, {
  required RiderNearbyFarm farm,
  required bool navigationBlockedByActiveDelivery,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: RiderMapMarkerSheetStyles.surfaceColor,
    builder: (context) => RiderFarmMarkerContent(
      farm: farm,
      navigationBlockedByActiveDelivery: navigationBlockedByActiveDelivery,
      onNavigate: () => Navigator.of(context).pop(true),
    ),
  );
  return result ?? false;
}
