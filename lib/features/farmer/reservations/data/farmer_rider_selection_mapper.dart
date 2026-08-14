import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

class FarmerRiderSelectionMapper {
  const FarmerRiderSelectionMapper();

  FarmerRiderSelectionData selection(Object? value) {
    final response = _map(value);
    final order = _map(response['order']);
    final riders = eligibleRidersNearestFirst(
      _rows(response['riders']).map(candidate),
    );
    return FarmerRiderSelectionData(
      delivery: FarmerRiderDeliveryDetails(
        orderId: _text(order['seller_order_id']),
        deliveryId: _text(order['delivery_id']),
        pickupAddress: _text(order['pickup_address']),
        pickupBarangay: _text(order['pickup_barangay']),
        pickupMunicipality: _text(order['pickup_municipality']),
        destination: _text(order['destination']),
        goodsSummary: _text(order['goods_summary'], fallback: 'Farm produce'),
        requestedSchedule: _date(order['requested_schedule']),
        destinationLatitude: _number(order['destination_latitude']),
        destinationLongitude: _number(order['destination_longitude']),
        routeDistanceKm: _number(order['route_distance_km']),
        estimatedDeliveryMinutes: _number(
          order['estimated_delivery_minutes'],
        )?.round(),
        proposedDeliveryFee: _number(order['proposed_delivery_fee']),
      ),
      riders: riders,
    );
  }

  FarmerRiderCandidate candidate(
    Map<String, Object?> row,
  ) => FarmerRiderCandidate(
    id: _text(row['rider_id']),
    name: _text(row['name'], fallback: 'Rider'),
    profilePhotoPath: _optionalText(row['profile_photo_path']),
    barangay: _text(row['barangay']),
    municipality: _text(row['municipality']),
    sameBarangay: row['same_barangay'] == true,
    sameMunicipality: row['same_municipality'] == true,
    availabilityStatus: _text(
      row['availability_status'],
      fallback: 'offline',
    ).toLowerCase(),
    isRequestable: row['is_requestable'] is bool
        ? row['is_requestable'] as bool
        : true,
    distanceKm: _number(row['distance_km']),
    estimatedArrivalMinutes: _number(row['estimated_arrival_minutes'])?.round(),
    currentLocationUpdatedAt: _optionalDate(row['current_location_updated_at']),
    locationIsFresh: row['location_is_fresh'] == true,
    destinationSupported: row['destination_supported'] is bool
        ? row['destination_supported'] as bool
        : true,
    deliveryDistanceKm: _number(row['delivery_distance_km']),
    activeDeliveryCount: _number(row['active_delivery_count'])?.toInt() ?? 0,
    rating: _number(row['rating']) ?? 0,
    completedDeliveries: _number(row['completed_deliveries'])?.toInt() ?? 0,
    proposedDeliveryFee: _number(row['proposed_delivery_fee']),
  );

  FarmerRiderRequest request(Object? value) {
    final row = _map(value);
    return FarmerRiderRequest(
      id: _text(row['request_id']),
      deliveryId: _text(row['delivery_id']),
      orderId: _text(row['seller_order_id']),
      riderId: _text(row['rider_id']),
      riderName: _text(row['rider_name'], fallback: 'Rider'),
      riderBarangay: _text(row['rider_barangay']),
      riderMunicipality: _text(row['rider_municipality']),
      riderProfilePhotoPath: _optionalText(row['rider_profile_photo_path']),
      status: RiderAssignmentRequestStatus.fromValue(row['status']),
      requestedSchedule: _date(row['requested_schedule']),
      proposedDeliveryFee: _number(row['proposed_delivery_fee']),
      requestedAt: _date(row['requested_at']),
      expiresAt: _date(row['expires_at']),
      respondedAt: _optionalDate(row['responded_at']),
      failureReason: _optionalText(row['failure_reason']),
    );
  }

  List<FarmerRiderRequest> requests(Object? value) =>
      _rows(value).map(request).toList(growable: false);
}

List<Map<String, Object?>> _rows(Object? value) =>
    value is List ? value.map(_map).toList(growable: false) : const [];
Map<String, Object?> _map(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};
String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _optionalText(Object? value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}

double? _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(_text(value));
DateTime _date(Object? value) =>
    _optionalDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
DateTime? _optionalDate(Object? value) =>
    DateTime.tryParse(_text(value))?.toLocal();
