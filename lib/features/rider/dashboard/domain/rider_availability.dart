enum RiderVerificationStatus {
  pending('Pending verification'),
  verified('Verified'),
  rejected('Rejected'),
  suspended('Suspended');

  const RiderVerificationStatus(this.label);
  final String label;

  String get databaseValue => name;

  static RiderVerificationStatus fromDatabaseValue(Object? value) =>
      values.firstWhere(
        (status) => status.name == value?.toString(),
        orElse: () => pending,
      );
}

enum RiderEmploymentStatus {
  pending('Pending'),
  active('Active'),
  inactive('Inactive'),
  suspended('Suspended');

  const RiderEmploymentStatus(this.label);
  final String label;
}

enum RiderAvailability {
  offline('offline'),
  onlineAvailable('online_available'),
  reviewingDeliveryRequest('reviewing_delivery_request'),
  deliveryReserved('delivery_reserved'),
  goingToPickup('going_to_pickup'),
  waitingAtPickup('waiting_at_pickup'),
  productPickedUp('product_picked_up'),
  goingToBuyer('going_to_buyer'),
  waitingAtDeliveryLocation('waiting_at_delivery_location'),
  onBreak('on_break'),
  temporarilyUnavailable('temporarily_unavailable'),
  emergency('emergency');

  const RiderAvailability(this.backendValue);

  final String backendValue;

  static RiderAvailability fromBackendValue(String value) {
    final snakeCase = value.trim().replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    );
    final normalized = snakeCase.replaceAll('-', '_').toLowerCase();
    return switch (normalized) {
      'available' || 'online_and_available' => onlineAvailable,
      'picking_up' => goingToPickup,
      'delivering' => goingToBuyer,
      _ => values.firstWhere(
        (status) => status.backendValue == normalized,
        orElse: () =>
            throw FormatException('Unknown rider availability value: $value'),
      ),
    };
  }

  @Deprecated('Use RiderAvailability.onlineAvailable.')
  static const available = onlineAvailable;

  @Deprecated('Use RiderAvailability.goingToPickup.')
  static const pickingUp = goingToPickup;

  @Deprecated('Use RiderAvailability.goingToBuyer.')
  static const delivering = goingToBuyer;
}

extension RiderAvailabilityRules on RiderAvailability {
  bool get isOnline => this != RiderAvailability.offline;

  bool get canReceiveRequests => this == RiderAvailability.onlineAvailable;

  bool get isHandlingDelivery => switch (this) {
    RiderAvailability.deliveryReserved ||
    RiderAvailability.goingToPickup ||
    RiderAvailability.waitingAtPickup ||
    RiderAvailability.productPickedUp ||
    RiderAvailability.goingToBuyer ||
    RiderAvailability.waitingAtDeliveryLocation => true,
    _ => false,
  };
}

class RiderDeliveryStatus {
  const RiderDeliveryStatus({
    required this.verificationStatus,
    required this.availability,
  });

  final RiderVerificationStatus verificationStatus;
  final RiderAvailability availability;

  bool get canReceiveRequests =>
      verificationStatus == RiderVerificationStatus.verified &&
      availability.canReceiveRequests;

  bool get canManageActiveDelivery =>
      verificationStatus == RiderVerificationStatus.verified &&
      (availability.canReceiveRequests || availability.isHandlingDelivery);

  RiderDeliveryStatus copyWith({
    RiderVerificationStatus? verificationStatus,
    RiderAvailability? availability,
  }) => RiderDeliveryStatus(
    verificationStatus: verificationStatus ?? this.verificationStatus,
    availability: availability ?? this.availability,
  );
}
