import 'delivery_json.dart';
import 'delivery_status.dart';

class DeliveryStatusHistory {
  const DeliveryStatusHistory({
    required this.statusHistoryId,
    required this.deliveryId,
    required this.newStatus,
    required this.changedAt,
    required this.createdAt,
    this.previousStatus,
    this.remarks,
    this.latitude,
    this.longitude,
  });

  factory DeliveryStatusHistory.fromJson(Map<String, Object?> json) =>
      DeliveryStatusHistory(
        statusHistoryId: deliveryString(json['status_history_id']),
        deliveryId: deliveryString(json['delivery_id']),
        previousStatus: json['previous_status'] == null
            ? null
            : DeliveryStatus.fromBackendValue(
                deliveryString(json['previous_status']),
              ),
        newStatus: DeliveryStatus.fromBackendValue(
          deliveryString(json['new_status']),
        ),
        remarks: json['remarks'] as String?,
        latitude: deliveryDouble(json['latitude']),
        longitude: deliveryDouble(json['longitude']),
        changedAt:
            deliveryDateTime(json['changed_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        createdAt:
            deliveryDateTime(json['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  final String statusHistoryId;
  final String deliveryId;
  final DeliveryStatus? previousStatus;
  final DeliveryStatus newStatus;
  final String? remarks;
  final double? latitude;
  final double? longitude;
  final DateTime changedAt;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    if (statusHistoryId.isNotEmpty) 'status_history_id': statusHistoryId,
    'delivery_id': deliveryId,
    'previous_status': previousStatus?.databaseValue,
    'new_status': newStatus.databaseValue,
    'remarks': remarks,
    'latitude': latitude,
    'longitude': longitude,
    'changed_at': changedAt.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  DeliveryStatusHistory copyWith({String? remarks}) => DeliveryStatusHistory(
    statusHistoryId: statusHistoryId,
    deliveryId: deliveryId,
    previousStatus: previousStatus,
    newStatus: newStatus,
    remarks: remarks ?? this.remarks,
    latitude: latitude,
    longitude: longitude,
    changedAt: changedAt,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is DeliveryStatusHistory &&
      other.statusHistoryId == statusHistoryId;
  @override
  int get hashCode => statusHistoryId.hashCode;
}
