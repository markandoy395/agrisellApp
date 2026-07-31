import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';

class RiderDeliveryProgressTimeline extends StatelessWidget {
  const RiderDeliveryProgressTimeline({
    required this.currentStatus,
    this.events = const [],
    super.key,
  });

  static const _stages = <_TimelineStage>[
    _TimelineStage('Accepted', [DeliveryStatus.accepted]),
    _TimelineStage('Going to pickup', [DeliveryStatus.goingToPickup]),
    _TimelineStage('Arrived at pickup', [DeliveryStatus.arrivedAtPickup]),
    _TimelineStage('Waiting for product', [
      DeliveryStatus.waitingForProduct,
      DeliveryStatus.pickupConfirmationRequired,
    ]),
    _TimelineStage('Product picked up', [DeliveryStatus.productPickedUp]),
    _TimelineStage('Going to buyer', [DeliveryStatus.goingToBuyer]),
    _TimelineStage('Arrived at destination', [
      DeliveryStatus.arrivedAtDelivery,
    ]),
    _TimelineStage('Waiting for buyer', [
      DeliveryStatus.waitingForBuyer,
      DeliveryStatus.deliveryConfirmationRequired,
    ]),
    _TimelineStage('Product delivered', [DeliveryStatus.productDelivered]),
    _TimelineStage('Delivery completed', [DeliveryStatus.deliveryCompleted]),
  ];

  final DeliveryStatus currentStatus;
  final List<DeliveryStatusEvent> events;

  @override
  Widget build(BuildContext context) {
    final activeIndex = _indexFor(currentStatus);
    return Semantics(
      label: 'Delivery progress: ${_stages[activeIndex].label}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AgrisellColors.borderLine),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Column(
            children: [
              for (var index = 0; index < _stages.length; index++)
                _TimelineRow(
                  stage: _stages[index],
                  event: _eventFor(_stages[index]),
                  state: index < activeIndex
                      ? _TimelineState.completed
                      : index == activeIndex
                      ? _TimelineState.active
                      : _TimelineState.upcoming,
                  showLine: index < _stages.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _indexFor(DeliveryStatus status) {
    final index = _stages.indexWhere(
      (stage) => stage.statuses.contains(status),
    );
    if (index >= 0) return index;
    return 0;
  }

  DeliveryStatusEvent? _eventFor(_TimelineStage stage) {
    for (final event in events.reversed) {
      if (stage.statuses.contains(event.newStatus)) return event;
    }
    return null;
  }
}

class _TimelineStage {
  const _TimelineStage(this.label, this.statuses);
  final String label;
  final List<DeliveryStatus> statuses;
}

enum _TimelineState { completed, active, upcoming }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.stage,
    required this.event,
    required this.state,
    required this.showLine,
  });

  final _TimelineStage stage;
  final DeliveryStatusEvent? event;
  final _TimelineState state;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final complete = state == _TimelineState.completed;
    final active = state == _TimelineState.active;
    final color = complete
        ? AgrisellColors.forestGreen
        : active
        ? AgrisellColors.limeGreen
        : AgrisellColors.deliveryGray;
    final timestamp = event == null ? null : _timestamp(event!.timestamp);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Icon(
                  complete ? Icons.check_rounded : Icons.circle,
                  size: complete ? 15 : 8,
                  color: AgrisellColors.surface,
                ),
              ),
              if (showLine) Container(width: 2, height: 30, color: color),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.label,
                  style: TextStyle(
                    color: complete || active
                        ? AgrisellColors.headingGreen
                        : AgrisellColors.mutedText,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (timestamp != null)
                  Text(
                    _eventDetail(event!, timestamp),
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _eventDetail(DeliveryStatusEvent event, String timestamp) {
    final details = <String>[timestamp];
    if (event.latitude != null && event.longitude != null) {
      details.add('Location');
    }
    if (event.proofReference != null) {
      details.add('Proof');
    }
    if (event.note != null && event.note!.isNotEmpty) {
      details.add('Note');
    }
    if (event.isManualArrivalOverride) {
      details.add('Manual override');
    }
    return details.join(' · ');
  }

  String _timestamp(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '${value.month}/${value.day} $hour:${value.minute.toString().padLeft(2, '0')} ${value.hour < 12 ? 'AM' : 'PM'}';
  }
}
