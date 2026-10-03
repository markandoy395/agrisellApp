enum SafetyIncidentCategory {
  emergencySos,
  accident,
  harassment,
  vehicleBreakdown,
  roadClosure,
  severeWeather,
  theft,
  unsafePickup,
  unsafeDestination,
  suspiciousProduct,
  suspiciousUser,
  fraudScam,
  damagedGoods,
  other;

  String get label => switch (this) {
    emergencySos => 'Emergency SOS',
    accident => 'Traffic / Physical Accident',
    harassment => 'Harassment / Threat',
    vehicleBreakdown => 'Vehicle Breakdown',
    roadClosure => 'Road Closure / Blockade',
    severeWeather => 'Severe Weather / Flood',
    theft => 'Theft / Robbery',
    unsafePickup => 'Unsafe Pickup Location',
    unsafeDestination => 'Unsafe Drop-off Location',
    suspiciousProduct => 'Suspicious / Contaminated Product',
    suspiciousUser => 'Suspicious User / Impersonation',
    fraudScam => 'Fraud / Scam / Payment Issue',
    damagedGoods => 'Damaged / Hazardous Goods',
    other => 'Other Safety Concern',
  };

  bool get isEmergency => this == emergencySos;

  static SafetyIncidentCategory fromString(String value) {
    for (final cat in values) {
      if (cat.name.toLowerCase() == value.toLowerCase()) return cat;
    }
    return switch (value) {
      'emergency' || 'sos' => emergencySos,
      'accidents' => accident,
      'vehicle' => vehicleBreakdown,
      _ => other,
    };
  }
}
