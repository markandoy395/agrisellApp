import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';

List<DeliveryRequest> sortRiderDeliveryRequests(
  List<DeliveryRequest> requests,
) => sortRiderRequests(requests, RiderRequestSort.recommended);

List<DeliveryRequest> sortRiderRequests(
  List<DeliveryRequest> requests,
  RiderRequestSort sort, {
  double? Function(DeliveryRequest request)? pickupDistanceKm,
}) {
  requests.sort((a, b) {
    final result = switch (sort) {
      RiderRequestSort.recommended =>
        b.priority.rank.compareTo(a.priority.rank) != 0
            ? b.priority.rank.compareTo(a.priority.rank)
            : _nearest(a, b, pickupDistanceKm),
      RiderRequestSort.nearestPickup => _nearest(a, b, pickupDistanceKm),
      RiderRequestSort.highestEarning => b.deliveryFee.compareTo(a.deliveryFee),
      RiderRequestSort.mostUrgent => b.priority.rank.compareTo(a.priority.rank),
      RiderRequestSort.earliestPickup => a.pickupDeadline.compareTo(
        b.pickupDeadline,
      ),
      RiderRequestSort.earliestDelivery => _date(
        a.deliveryDeadline,
      ).compareTo(_date(b.deliveryDeadline)),
      RiderRequestSort.shortestTrip => _number(
        a.totalTripDistanceKm,
      ).compareTo(_number(b.totalTripDistanceKm)),
      RiderRequestSort.recentlyAvailable => _date(
        b.availableAt,
      ).compareTo(_date(a.availableAt)),
    };
    return result != 0 ? result : a.id.compareTo(b.id);
  });
  return requests;
}

int _nearest(
  DeliveryRequest a,
  DeliveryRequest b,
  double? Function(DeliveryRequest request)? pickupDistanceKm,
) => _number(
  pickupDistanceKm?.call(a) ?? a.routeDistanceKm,
).compareTo(_number(pickupDistanceKm?.call(b) ?? b.routeDistanceKm));

double _number(double? value) => value ?? double.infinity;

DateTime _date(DateTime? value) => value ?? DateTime(9999);
