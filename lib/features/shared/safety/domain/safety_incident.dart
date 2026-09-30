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

enum SafetyIncidentStatus {
  submitted,
  underReview,
  waitingForInformation,
  escalated,
  resolved,
  rejected;

  String get label => switch (this) {
    submitted => 'Pending Review',
    underReview => 'Under Investigation',
    waitingForInformation => 'Waiting for Info',
    escalated => 'Escalated',
    resolved => 'Resolved',
    rejected => 'Dismissed',
  };

  bool get isTerminal => this == resolved || this == rejected;
  bool get isOpen => !isTerminal;

  static SafetyIncidentStatus fromString(String value) {
    for (final status in values) {
      if (status.name.toLowerCase() == value.toLowerCase()) return status;
    }
    return switch (value.toLowerCase()) {
      'open' => submitted,
      'under_review' => underReview,
      'waiting_for_info' || 'waiting_for_information' => waitingForInformation,
      'closed' => resolved,
      _ => submitted,
    };
  }
}

class SafetyIncident {
  const SafetyIncident({
    required this.reportId,
    required this.category,
    required this.description,
    required this.status,
    required this.reportedAt,
    this.reportType = 'safety_report',
    this.reporterRole = 'buyer',
    this.reporterName,
    this.reporterContact,
    this.reporterEmail,
    this.stage,
    this.resolutionNotes,
    this.resolvedBy,
    this.resolvedAt,
    this.orderId,
    this.deliveryId,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.attachments = const [],
    this.requestedActions = const [],
  });

  final String reportId;
  final SafetyIncidentCategory category;
  final String description;
  final SafetyIncidentStatus status;
  final DateTime reportedAt;
  final String reportType;
  final String reporterRole;
  final String? reporterName;
  final String? reporterContact;
  final String? reporterEmail;
  final String? stage;
  final String? resolutionNotes;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final int? orderId;
  final int? deliveryId;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final List<String> attachments;
  final List<String> requestedActions;

  bool get isEmergency =>
      category == SafetyIncidentCategory.emergencySos ||
      reportType == 'safety_action';

  SafetyIncident copyWith({
    SafetyIncidentStatus? status,
    String? resolutionNotes,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return SafetyIncident(
      reportId: reportId,
      category: category,
      description: description,
      status: status ?? this.status,
      reportedAt: reportedAt,
      reportType: reportType,
      reporterRole: reporterRole,
      reporterName: reporterName,
      reporterContact: reporterContact,
      reporterEmail: reporterEmail,
      stage: stage,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      orderId: orderId,
      deliveryId: deliveryId,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      attachments: attachments,
      requestedActions: requestedActions,
    );
  }

  factory SafetyIncident.fromJson(Map<String, Object?> json) {
    final reportedAtRaw = json['reported_at'] ?? json['created_at'];
    final reportedAt = reportedAtRaw != null
        ? DateTime.tryParse('$reportedAtRaw')?.toLocal() ?? DateTime.now()
        : DateTime.now();

    final resolvedAtRaw = json['resolved_at'];
    final resolvedAt = resolvedAtRaw != null
        ? DateTime.tryParse('$resolvedAtRaw')?.toLocal()
        : null;

    final attachmentsList = (json['attachments'] as List? ?? const [])
        .map((e) => '$e')
        .toList(growable: false);

    final actionsList = (json['requested_actions'] as List? ?? const [])
        .map((e) => '$e')
        .toList(growable: false);

    return SafetyIncident(
      reportId: '${json['report_id'] ?? ''}',
      category: SafetyIncidentCategory.fromString('${json['category'] ?? ''}'),
      description: '${json['description'] ?? ''}',
      status: SafetyIncidentStatus.fromString('${json['status'] ?? 'submitted'}'),
      reportedAt: reportedAt,
      reportType: '${json['report_type'] ?? 'safety_report'}',
      reporterRole: '${json['reporter_role'] ?? 'buyer'}',
      reporterName: json['reporter_name'] as String?,
      reporterContact: json['reporter_contact'] as String?,
      reporterEmail: json['reporter_email'] as String?,
      stage: json['stage'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: resolvedAt,
      orderId: json['order_id'] is num ? (json['order_id'] as num).toInt() : null,
      deliveryId: json['delivery_id'] is num ? (json['delivery_id'] as num).toInt() : null,
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
      accuracyMeters: json['accuracy_meters'] is num ? (json['accuracy_meters'] as num).toDouble() : null,
      attachments: attachmentsList,
      requestedActions: actionsList,
    );
  }

  Map<String, Object?> toJson() => {
    'report_id': reportId,
    'category': category.name,
    'description': description,
    'status': status.name,
    'reported_at': reportedAt.toUtc().toIso8601String(),
    'report_type': reportType,
    'reporter_role': reporterRole,
    'reporter_name': reporterName,
    'reporter_contact': reporterContact,
    'reporter_email': reporterEmail,
    'stage': stage,
    'resolution_notes': resolutionNotes,
    'resolved_by': resolvedBy,
    'resolved_at': resolvedAt?.toUtc().toIso8601String(),
    'order_id': orderId,
    'delivery_id': deliveryId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy_meters': accuracyMeters,
    'attachments': attachments,
    'requested_actions': requestedActions,
  };
}
