import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/active_delivery_summary.dart';

class RiderActiveDeliverySnapshot {
  RiderActiveDeliverySnapshot({
    required this.recordId,
    required this.acceptedAt,
    required this.summary,
    required this.status,
    Iterable<DeliveryStatusEvent> events = const [],
  }) : events = List.unmodifiable(events);

  final String recordId;
  final DateTime acceptedAt;
  final ActiveDeliverySummary summary;
  final DeliveryStatus status;
  final List<DeliveryStatusEvent> events;

  ActiveDeliveryRecord toRecord(String riderId) => ActiveDeliveryRecord(
    id: recordId,
    requestId: summary.deliveryId,
    riderId: riderId,
    acceptedAt: acceptedAt,
    estimatedEarning: summary.deliveryFee,
  );

  Map<String, Object?> toJson() => {
    'recordId': recordId,
    'acceptedAt': acceptedAt.toUtc().toIso8601String(),
    'summary': summary.toJson(),
    'status': status.backendValue,
    'events': events.map((event) => event.toJson()).toList(),
  };

  factory RiderActiveDeliverySnapshot.fromJson(Map<String, Object?> json) {
    final storedEvents = json['events'] as List? ?? const [];
    return RiderActiveDeliverySnapshot(
      recordId: json['recordId'] as String,
      acceptedAt: DateTime.parse(json['acceptedAt'] as String).toLocal(),
      summary: ActiveDeliverySummary.fromJson(
        Map<String, Object?>.from(json['summary'] as Map),
      ),
      status: DeliveryStatus.fromBackendValue(json['status'] as String),
      events: storedEvents.map(
        (value) => DeliveryStatusEvent.fromJson(
          Map<String, Object?>.from(value as Map),
        ),
      ),
    );
  }
}
