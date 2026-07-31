import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_active_delivery_snapshot.dart';
import 'package:agresell_app/features/rider/deliveries/domain/active_delivery_summary.dart';

export 'package:agresell_app/features/rider/deliveries/domain/active_delivery_summary.dart';

class RiderDeliveryStateSnapshot {
  const RiderDeliveryStateSnapshot({
    required this.availability,
    required this.pendingOfflineActionCount,
    this.activeDeliveryId,
    this.currentDeliveryStatus,
    this.activeDeliverySummary,
    this.statusEvents = const [],
    this.lastSynchronizationTime,
    this.lastSynchronizationState,
    this.recoveryData = const {},
    this.activeDeliveries = const [],
  });

  final RiderAvailability availability;
  final String? activeDeliveryId;
  final DeliveryStatus? currentDeliveryStatus;
  final ActiveDeliverySummary? activeDeliverySummary;
  final List<DeliveryStatusEvent> statusEvents;
  final int pendingOfflineActionCount;
  final DateTime? lastSynchronizationTime;
  final String? lastSynchronizationState;
  final Map<String, Object?> recoveryData;
  final List<RiderActiveDeliverySnapshot> activeDeliveries;

  Map<String, Object?> toJson() => {
    'availability': availability.backendValue,
    'activeDeliveryId': activeDeliveryId,
    'currentDeliveryStatus': currentDeliveryStatus?.backendValue,
    'activeDeliverySummary': activeDeliverySummary?.toJson(),
    'statusEvents': statusEvents.map((event) => event.toJson()).toList(),
    'pendingOfflineActionCount': pendingOfflineActionCount,
    'lastSynchronizationTime': lastSynchronizationTime
        ?.toUtc()
        .toIso8601String(),
    'lastSynchronizationState': lastSynchronizationState,
    'recoveryData': recoveryData,
    'activeDeliveries': activeDeliveries.map((item) => item.toJson()).toList(),
  };

  factory RiderDeliveryStateSnapshot.fromJson(Map<String, Object?> json) {
    final summary = json['activeDeliverySummary'];
    final status = json['currentDeliveryStatus'] as String?;
    final lastSync = json['lastSynchronizationTime'] as String?;
    final storedEvents = json['statusEvents'] as List? ?? const [];
    final storedActive = json['activeDeliveries'] as List? ?? const [];
    return RiderDeliveryStateSnapshot(
      availability: RiderAvailability.fromBackendValue(
        json['availability'] as String,
      ),
      activeDeliveryId: json['activeDeliveryId'] as String?,
      currentDeliveryStatus: status == null
          ? null
          : DeliveryStatus.fromBackendValue(status),
      activeDeliverySummary: summary == null
          ? null
          : ActiveDeliverySummary.fromJson(
              Map<String, Object?>.from(summary as Map),
            ),
      statusEvents: storedEvents
          .map(
            (value) => DeliveryStatusEvent.fromJson(
              Map<String, Object?>.from(value as Map),
            ),
          )
          .toList(growable: false),
      pendingOfflineActionCount:
          (json['pendingOfflineActionCount'] as num?)?.toInt() ?? 0,
      lastSynchronizationTime: lastSync == null
          ? null
          : DateTime.parse(lastSync).toLocal(),
      lastSynchronizationState: json['lastSynchronizationState'] as String?,
      recoveryData: Map<String, Object?>.from(
        json['recoveryData'] as Map? ?? const <String, Object?>{},
      ),
      activeDeliveries: storedActive
          .map(
            (value) => RiderActiveDeliverySnapshot.fromJson(
              Map<String, Object?>.from(value as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}
