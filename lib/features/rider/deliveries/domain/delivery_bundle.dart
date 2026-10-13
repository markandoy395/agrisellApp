import 'delivery.dart';
import 'delivery_location.dart';
import 'delivery_payment_record.dart';
import 'delivery_proof.dart';
import 'delivery_requirement.dart';
import 'delivery_status_history.dart';

class DeliveryBundle {
  DeliveryBundle({
    required this.delivery,
    required Iterable<DeliveryLocation> locations,
    required Iterable<DeliveryStatusHistory> history,
    required Iterable<DeliveryProof> proofs,
    required this.raw,
    this.requirement,
    this.payment,
  }) : locations = List.unmodifiable(locations),
       history = List.unmodifiable(history),
       proofs = List.unmodifiable(proofs);

  factory DeliveryBundle.fromJson(Map<String, Object?> json) {
    final delivery = Delivery.fromJson(json);
    final pickup = delivery.pickupLocation?.trim();
    final dropoff = delivery.dropoffLocation?.trim();
    final normalizedLocations = _bundleMaps(json['locations'])
        .map(
          (location) => DeliveryLocation.fromJson(
            location,
            // Fulfillment RPCs can provide addresses before GPS is available.
            // Preserve missing coordinates; routing and proof checks validate them.
            requireCoordinates: false,
          ),
        )
        .toList(growable: false);
    final requirementJson = _bundleMap(json['requirement']);
    final paymentJson = _bundleMap(json['payment']);
    final payment = paymentJson == null
        ? null
        : DeliveryPayment.fromJson(paymentJson);
    if (payment != null && payment.deliveryId != delivery.deliveryId) {
      throw const FormatException('Delivery payment does not match delivery.');
    }
    return DeliveryBundle(
      delivery: delivery,
      locations: normalizedLocations.isNotEmpty
          ? normalizedLocations
          : [
              if (pickup != null && pickup.isNotEmpty)
                DeliveryLocation(
                  deliveryId: delivery.deliveryId,
                  locationType: DeliveryLocationType.pickup,
                  address: pickup,
                ),
              if (dropoff != null && dropoff.isNotEmpty)
                DeliveryLocation(
                  deliveryId: delivery.deliveryId,
                  locationType: DeliveryLocationType.dropoff,
                  address: dropoff,
                ),
            ],
      requirement: requirementJson == null
          ? null
          : DeliveryRequirement.fromJson(requirementJson),
      history: _bundleMaps(json['history']).map(DeliveryStatusHistory.fromJson),
      proofs: _bundleMaps(json['proofs']).map(DeliveryProof.fromJson),
      raw: Map.unmodifiable(json),
      payment: payment,
    );
  }

  final Delivery delivery;
  final List<DeliveryLocation> locations;
  final DeliveryRequirement? requirement;
  final List<DeliveryStatusHistory> history;
  final List<DeliveryProof> proofs;
  final DeliveryPayment? payment;
  final Map<String, Object?> raw;

  DeliveryLocation? get pickup => _location(DeliveryLocationType.pickup);
  DeliveryLocation? get dropoff => _location(DeliveryLocationType.dropoff);

  DeliveryLocation? _location(DeliveryLocationType type) {
    for (final location in locations) {
      if (location.locationType == type) return location;
    }
    return null;
  }

  DeliveryBundle copyWith({
    Delivery? delivery,
    Iterable<DeliveryStatusHistory>? history,
    Iterable<DeliveryProof>? proofs,
    DeliveryPayment? payment,
  }) => DeliveryBundle(
    delivery: delivery ?? this.delivery,
    locations: locations,
    requirement: requirement,
    history: history ?? this.history,
    proofs: proofs ?? this.proofs,
    payment: payment ?? this.payment,
    raw: raw,
  );
}

Map<String, Object?>? _bundleMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

List<Map<String, Object?>> _bundleMaps(Object? value) => value is List
    ? value.map(_bundleMap).whereType<Map<String, Object?>>().toList()
    : const [];
