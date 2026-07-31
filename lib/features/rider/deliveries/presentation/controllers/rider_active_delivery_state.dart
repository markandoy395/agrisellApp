import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

class RiderActiveDeliveryState {
  final Map<String, ActiveDeliveryRecord> _records = {};
  final Map<String, DeliveryStatus> _statuses = {};
  final Map<String, List<DeliveryStatusEvent>> _events = {};
  String? _selectedDeliveryId;

  List<ActiveDeliveryRecord> get records => List.unmodifiable(_records.values);

  ActiveDeliveryRecord? get selectedRecord {
    final selected = _selectedDeliveryId;
    return selected == null ? _records.values.firstOrNull : _records[selected];
  }

  DeliveryStatus? get selectedStatus {
    final selected = selectedRecord?.requestId ?? _selectedDeliveryId;
    return selected == null ? null : _statuses[selected];
  }

  List<DeliveryStatusEvent> get selectedEvents {
    final selected = selectedRecord?.requestId ?? _selectedDeliveryId;
    return List.unmodifiable(_events[selected] ?? const []);
  }

  DeliveryStatus? statusFor(String deliveryId) => _statuses[deliveryId];

  List<DeliveryStatusEvent> eventsFor(String deliveryId) =>
      List.unmodifiable(_events[deliveryId] ?? const []);

  void accept(
    ActiveDeliveryRecord record, {
    required DeliveryStatus status,
    required Iterable<DeliveryStatusEvent> events,
  }) {
    _records[record.requestId] = record;
    _statuses[record.requestId] = status;
    _events[record.requestId] = List.unmodifiable(events);
    _selectedDeliveryId = record.requestId;
  }

  void update(DeliveryStatusSnapshot snapshot) {
    _statuses[snapshot.request.id] = snapshot.currentStatus;
    _events[snapshot.request.id] = List.unmodifiable(snapshot.events);
    _selectedDeliveryId ??= snapshot.request.id;
    _records.putIfAbsent(
      snapshot.request.id,
      () => ActiveDeliveryRecord(
        id: 'restored-${snapshot.request.id}',
        requestId: snapshot.request.id,
        riderId: snapshot.request.assignedRiderId ?? '',
        acceptedAt: snapshot.events.firstOrNull?.timestamp ?? DateTime.now(),
        estimatedEarning: snapshot.request.deliveryFee,
      ),
    );
  }

  void restore({
    required ActiveDeliveryRecord record,
    required DeliveryStatus status,
    required Iterable<DeliveryStatusEvent> events,
  }) => accept(record, status: status, events: events);

  void select(String deliveryId) {
    if (_records.containsKey(deliveryId) || _statuses.containsKey(deliveryId)) {
      _selectedDeliveryId = deliveryId;
    }
  }

  void remove(String deliveryId) {
    _records.remove(deliveryId);
    _statuses.remove(deliveryId);
    _events.remove(deliveryId);
    if (_selectedDeliveryId == deliveryId) {
      _selectedDeliveryId = _records.keys.firstOrNull;
    }
  }

  void clear() {
    _records.clear();
    _statuses.clear();
    _events.clear();
    _selectedDeliveryId = null;
  }
}
