import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_matching_context.dart';

export 'package:agresell_app/features/rider/deliveries/domain/rider_matching_context.dart';

enum RiderRequestSort {
  recommended,
  nearestPickup,
  highestEarning,
  mostUrgent,
  earliestPickup,
  earliestDelivery,
  shortestTrip,
  recentlyAvailable,
}

extension RiderRequestSortDetails on RiderRequestSort {
  String get label => switch (this) {
    RiderRequestSort.recommended => 'Recommended',
    RiderRequestSort.nearestPickup => 'Nearest pickup',
    RiderRequestSort.highestEarning => 'Highest earning',
    RiderRequestSort.mostUrgent => 'Most urgent',
    RiderRequestSort.earliestPickup => 'Earliest pickup',
    RiderRequestSort.earliestDelivery => 'Earliest delivery',
    RiderRequestSort.shortestTrip => 'Shortest total trip',
    RiderRequestSort.recentlyAvailable => 'Recently available',
  };
}

class RiderRequestFilters {
  const RiderRequestFilters({
    this.urgentOnly = false,
    this.scheduledOnly = false,
    this.perishableOnly = false,
    this.maximumPickupDistanceKm,
    this.minimumFee,
    this.maximumFee,
    this.category,
    this.pickupWithinMinutes,
    this.deliveryWithinMinutes,
  });

  final bool urgentOnly;
  final bool scheduledOnly;
  final bool perishableOnly;
  final double? maximumPickupDistanceKm;
  final double? minimumFee;
  final double? maximumFee;
  final String? category;
  final int? pickupWithinMinutes;
  final int? deliveryWithinMinutes;

  int get activeCount => [
    urgentOnly,
    scheduledOnly,
    perishableOnly,
    maximumPickupDistanceKm != null,
    minimumFee != null,
    maximumFee != null,
    category?.isNotEmpty ?? false,
    pickupWithinMinutes != null,
    deliveryWithinMinutes != null,
  ].where((active) => active).length;

  bool allows(DeliveryRequest request, {double? pickupDistanceKm}) {
    if (urgentOnly && request.priority != DeliveryPriority.urgent) return false;
    if (scheduledOnly && request.priority != DeliveryPriority.scheduled) {
      return false;
    }
    if (perishableOnly &&
        !request.handlingRequirements.any(
          (item) => item.type == ProductHandlingType.perishable,
        )) {
      return false;
    }
    if (maximumPickupDistanceKm != null &&
        ((pickupDistanceKm ?? request.routeDistanceKm) == null ||
            (pickupDistanceKm ?? request.routeDistanceKm)! >
                maximumPickupDistanceKm!)) {
      return false;
    }
    if (minimumFee != null && request.deliveryFee < minimumFee!) return false;
    if (maximumFee != null && request.deliveryFee > maximumFee!) return false;
    final selectedCategory = category?.trim().toLowerCase();
    if (selectedCategory != null &&
        selectedCategory.isNotEmpty &&
        request.productCategory.toLowerCase() != selectedCategory) {
      return false;
    }
    final now = DateTime.now();
    if (pickupWithinMinutes != null &&
        request.pickupDeadline.isAfter(
          now.add(Duration(minutes: pickupWithinMinutes!)),
        )) {
      return false;
    }
    if (deliveryWithinMinutes != null &&
        (request.deliveryDeadline == null ||
            request.deliveryDeadline!.isAfter(
              now.add(Duration(minutes: deliveryWithinMinutes!)),
            ))) {
      return false;
    }
    return true;
  }
}

class RiderRequestQuery {
  const RiderRequestQuery({
    required this.matching,
    this.searchText = '',
    this.sort = RiderRequestSort.recommended,
    this.filters = const RiderRequestFilters(),
    this.cursor,
    this.pageSize = 10,
  });

  final RiderMatchingContext matching;
  final String searchText;
  final RiderRequestSort sort;
  final RiderRequestFilters filters;
  final String? cursor;
  final int pageSize;
}

class RiderRequestPage {
  const RiderRequestPage({required this.items, this.nextCursor});
  final List<DeliveryRequest> items;
  final String? nextCursor;
}
