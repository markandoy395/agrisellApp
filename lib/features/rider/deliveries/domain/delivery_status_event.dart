import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';

enum DeliveryEventSource { online, offline }

enum DeliveryEventSyncStatus { pending, synchronizing, synchronized, conflict }

class DeliveryStatusEvent {
  const DeliveryStatusEvent({
    required this.eventId,
    required this.deliveryId,
    required this.previousStatus,
    required this.newStatus,
    required this.riderId,
    required this.timestamp,
    required this.source,
    required this.syncStatus,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.locationTimestamp,
    this.isManualArrivalOverride = false,
    this.note,
    this.reasonCode,
    this.proofReference,
  });

  final String eventId;
  final String deliveryId;
  final DeliveryStatus previousStatus;
  final DeliveryStatus newStatus;
  final String riderId;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DateTime? locationTimestamp;
  final bool isManualArrivalOverride;
  final String? note;
  final String? reasonCode;
  final String? proofReference;
  final DeliveryEventSource source;
  final DeliveryEventSyncStatus syncStatus;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'deliveryId': deliveryId,
    'previousStatus': previousStatus.backendValue,
    'newStatus': newStatus.backendValue,
    'riderId': riderId,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'accuracyMeters': accuracyMeters,
    'locationTimestamp': locationTimestamp?.toUtc().toIso8601String(),
    'isManualArrivalOverride': isManualArrivalOverride,
    'note': note,
    'reasonCode': reasonCode,
    'proofReference': proofReference,
    'source': source.name,
    'syncStatus': syncStatus.name,
  };

  factory DeliveryStatusEvent.fromJson(Map<String, Object?> json) =>
      DeliveryStatusEvent(
        eventId: json['eventId'] as String,
        deliveryId: json['deliveryId'] as String,
        previousStatus: DeliveryStatus.fromBackendValue(
          json['previousStatus'] as String,
        ),
        newStatus: DeliveryStatus.fromBackendValue(json['newStatus'] as String),
        riderId: json['riderId'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
        locationTimestamp: json['locationTimestamp'] == null
            ? null
            : DateTime.parse(json['locationTimestamp'] as String).toLocal(),
        isManualArrivalOverride:
            json['isManualArrivalOverride'] as bool? ?? false,
        note: json['note'] as String?,
        reasonCode: json['reasonCode'] as String?,
        proofReference: json['proofReference'] as String?,
        source: DeliveryEventSource.values.byName(json['source'] as String),
        syncStatus: DeliveryEventSyncStatus.values.byName(
          json['syncStatus'] as String,
        ),
      );
}
