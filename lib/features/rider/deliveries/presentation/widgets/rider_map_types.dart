import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';

/// Filter modes for displaying delivery opportunities, assigned jobs, and farms.
enum RiderMapFilter { all, deliveries, farmers, assigned, nearby }

/// Descriptive metadata for map filter tabs and chips.
extension RiderMapFilterDetails on RiderMapFilter {
  String get label => switch (this) {
    RiderMapFilter.all => 'All',
    RiderMapFilter.deliveries => 'Deliveries',
    RiderMapFilter.farmers => 'Farmers',
    RiderMapFilter.assigned => 'Assigned',
    RiderMapFilter.nearby => 'Nearby',
  };

  IconData get icon => switch (this) {
    RiderMapFilter.all => Icons.layers_rounded,
    RiderMapFilter.deliveries => Icons.inventory_2_rounded,
    RiderMapFilter.farmers => Icons.agriculture_rounded,
    RiderMapFilter.assigned => Icons.local_shipping_rounded,
    RiderMapFilter.nearby => Icons.navigation_rounded,
  };
}

/// Category classification of markers displayed on the rider map.
enum RiderMapMarkerKind { availableDelivery, farmer, assignedDelivery }

/// Callback signature when a delivery request marker is tapped.
typedef RiderMapMarkerCallback =
    void Function(DeliveryRequest request, RiderMapMarkerKind kind);
