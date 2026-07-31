enum OfflineDeliveryActionType {
  deliveryStatusUpdate,
  pickupProof,
  deliveryProof,
  photo,
  riderNote,
  location,
  message,
  problemReport,
  failedDeliveryReport,
  safetyReport,
  // Legacy values remain readable while older local snapshots are migrated.
  updateStatus,
  submitProof,
  recordLocation,
  reportProblem,
}

enum OfflineDeliveryActionStatus {
  pending,
  synchronizing,
  synchronized,
  failed,
  requiresAttention,
  cancelled,
  // Legacy values remain readable from Phase 0 snapshots.
  processing,
  conflict,
}

class OfflineDeliveryAction {
  OfflineDeliveryAction({
    String? localId,
    String? id,
    String? idempotencyKey,
    required this.deliveryId,
    required this.riderId,
    required this.type,
    required this.status,
    required Map<String, Object?> payload,
    DateTime? originalTimestamp,
    DateTime? createdAt,
    DateTime? queuedAt,
    int? retryCount,
    int? attemptCount,
    this.maxRetries = 6,
    this.sequence = 0,
    this.dependencyId,
    this.lastError,
    this.lastAttemptAt,
    this.nextAttemptAt,
  }) : localId = localId ?? id ?? _required('localId'),
       idempotencyKey = idempotencyKey ?? localId ?? id ?? _required('key'),
       payload = Map.unmodifiable(payload),
       originalTimestamp = originalTimestamp ?? queuedAt ?? DateTime.now(),
       createdAt = createdAt ?? queuedAt ?? DateTime.now(),
       retryCount = retryCount ?? attemptCount ?? 0;

  final String localId;
  final String idempotencyKey;
  final String deliveryId;
  final String riderId;
  final OfflineDeliveryActionType type;
  final OfflineDeliveryActionStatus status;
  final Map<String, Object?> payload;
  final DateTime originalTimestamp;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetries;
  final int sequence;
  final String? dependencyId;
  final String? lastError;
  final DateTime? lastAttemptAt;
  final DateTime? nextAttemptAt;

  String get id => localId;
  DateTime get queuedAt => createdAt;
  int get attemptCount => retryCount;
  bool get containsEvidence => {
    OfflineDeliveryActionType.pickupProof,
    OfflineDeliveryActionType.deliveryProof,
    OfflineDeliveryActionType.photo,
    OfflineDeliveryActionType.submitProof,
  }.contains(type);

  OfflineDeliveryAction copyWith({
    OfflineDeliveryActionStatus? status,
    int? retryCount,
    String? lastError,
    bool clearLastError = false,
    DateTime? lastAttemptAt,
    DateTime? nextAttemptAt,
    bool clearNextAttempt = false,
  }) => OfflineDeliveryAction(
    localId: localId,
    idempotencyKey: idempotencyKey,
    deliveryId: deliveryId,
    riderId: riderId,
    type: type,
    status: status ?? this.status,
    payload: payload,
    originalTimestamp: originalTimestamp,
    createdAt: createdAt,
    retryCount: retryCount ?? this.retryCount,
    maxRetries: maxRetries,
    sequence: sequence,
    dependencyId: dependencyId,
    lastError: clearLastError ? null : lastError ?? this.lastError,
    lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    nextAttemptAt: clearNextAttempt
        ? null
        : nextAttemptAt ?? this.nextAttemptAt,
  );

  Map<String, Object?> toJson() => {
    'localId': localId,
    'idempotencyKey': idempotencyKey,
    'deliveryId': deliveryId,
    'riderId': riderId,
    'type': type.name,
    'status': status.name,
    'payload': payload,
    'originalTimestamp': originalTimestamp.toUtc().toIso8601String(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'retryCount': retryCount,
    'maxRetries': maxRetries,
    'sequence': sequence,
    'dependencyId': dependencyId,
    'lastError': lastError,
    'lastAttemptAt': lastAttemptAt?.toUtc().toIso8601String(),
    'nextAttemptAt': nextAttemptAt?.toUtc().toIso8601String(),
  };

  factory OfflineDeliveryAction.fromJson(Map<String, Object?> json) {
    DateTime? date(String key) {
      final value = json[key] as String?;
      return value == null ? null : DateTime.parse(value).toLocal();
    }

    final legacyQueuedAt = date('queuedAt');
    return OfflineDeliveryAction(
      localId: json['localId'] as String? ?? json['id'] as String?,
      idempotencyKey: json['idempotencyKey'] as String?,
      deliveryId: json['deliveryId'] as String,
      riderId: json['riderId'] as String,
      type: OfflineDeliveryActionType.values.byName(json['type'] as String),
      status: OfflineDeliveryActionStatus.values.byName(
        json['status'] as String,
      ),
      payload: Map<String, Object?>.from(json['payload'] as Map),
      originalTimestamp: date('originalTimestamp') ?? legacyQueuedAt,
      createdAt: date('createdAt') ?? legacyQueuedAt,
      retryCount: (json['retryCount'] as num?)?.toInt(),
      attemptCount: (json['attemptCount'] as num?)?.toInt(),
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 6,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      dependencyId: json['dependencyId'] as String?,
      lastError: json['lastError'] as String?,
      lastAttemptAt: date('lastAttemptAt'),
      nextAttemptAt: date('nextAttemptAt'),
    );
  }

  static Never _required(String field) =>
      throw ArgumentError('$field is required.');
}
