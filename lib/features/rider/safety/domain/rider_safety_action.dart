enum RiderSafetyActionType {
  emergencySos,
  reportProblem,
  unsafePickup,
  unsafeDelivery,
  contactSupport,
  shareActiveLocation,
}

extension RiderSafetyActionTypeDetails on RiderSafetyActionType {
  bool get requiresReason {
    return this == RiderSafetyActionType.reportProblem ||
        this == RiderSafetyActionType.unsafePickup ||
        this == RiderSafetyActionType.unsafeDelivery;
  }

  String get label => switch (this) {
    RiderSafetyActionType.emergencySos => 'Emergency SOS',
    RiderSafetyActionType.reportProblem => 'Report a problem',
    RiderSafetyActionType.unsafePickup => 'Report unsafe pickup',
    RiderSafetyActionType.unsafeDelivery => 'Report unsafe delivery',
    RiderSafetyActionType.contactSupport => 'Contact customer support',
    RiderSafetyActionType.shareActiveLocation =>
      'Share active delivery location',
  };
}

class RiderSafetyAction {
  const RiderSafetyAction({
    required this.id,
    required this.riderId,
    required this.type,
    required this.createdAt,
    this.reason,
  }) : assert(id != ''),
       assert(riderId != ''),
       assert(
         type != RiderSafetyActionType.reportProblem &&
                 type != RiderSafetyActionType.unsafePickup &&
                 type != RiderSafetyActionType.unsafeDelivery ||
             reason != null,
       );

  final String id;
  final String riderId;
  final RiderSafetyActionType type;
  final DateTime createdAt;
  final String? reason;
}
