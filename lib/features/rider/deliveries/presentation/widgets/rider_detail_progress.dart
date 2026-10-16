import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_status.dart';
import '../../domain/delivery_status_event.dart';
import '../delivery_status_presentation.dart';
import '../styles/rider_delivery_reference_styles.dart';
import 'rider_detail_card.dart';

class RiderDetailProgress extends StatelessWidget {
  const RiderDetailProgress({
    required this.status,
    required this.events,
    required this.nextAction,
    super.key,
  });
  final DeliveryStatus status;
  final List<DeliveryStatusEvent> events;
  final Widget nextAction;
  static const _steps = [
    (DeliveryStatus.accepted, 'Accepted', Icons.check_rounded),
    (
      DeliveryStatus.goingToPickup,
      'Going to Pickup',
      Icons.local_shipping_outlined,
    ),
    (
      DeliveryStatus.arrivedAtPickup,
      'Arrived at Pickup',
      Icons.location_on_outlined,
    ),
    (DeliveryStatus.productPickedUp, 'Picked up', Icons.inventory_2_outlined),
    (
      DeliveryStatus.goingToBuyer,
      'Going to Buyer',
      Icons.local_shipping_outlined,
    ),
    (
      DeliveryStatus.arrivedAtDelivery,
      'Arrived at Delivery',
      Icons.location_on_outlined,
    ),
    (DeliveryStatus.deliveryCompleted, 'Completed', Icons.check_rounded),
  ];
  @override
  Widget build(BuildContext context) => RiderDetailSection(
    title: 'Delivery progress',
    icon: Icons.location_on_rounded,
    trailing: Text(
      'Current: ${status.displayLabel}',
      style: RiderDeliveryReferenceStyles.strongCaption,
    ),
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth =
              constraints.maxWidth >= 330 &&
                  MediaQuery.textScalerOf(context).scale(1) <= 1.1
              ? constraints.maxWidth / _steps.length
              : 66.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < _steps.length; index++)
                  _step(context, index, stepWidth),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      nextAction,
      if (events.isNotEmpty) ...[
        const SizedBox(height: 8),
        ExpansionTile(
          key: const PageStorageKey('rider-detail-status-events'),
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Status history',
            style: RiderDeliveryReferenceStyles.caption,
          ),
          children: [
            for (final event in events.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${event.newStatus.displayLabel} · ${riderDetailDate(context, event.timestamp)}'
                    '${event.isManualArrivalOverride ? ' · Manual override' : ''}'
                    '${event.latitude != null && event.longitude != null ? ' · Location' : ''}'
                    '${event.proofReference != null ? ' · Proof' : ''}'
                    '${event.note == null ? '' : ' · ${event.note}'}',
                    style: RiderDeliveryReferenceStyles.caption,
                  ),
                ),
              ),
          ],
        ),
      ],
    ],
  );

  Widget _step(BuildContext context, int index, double width) {
    final step = _steps[index];
    final reached = status.isNormalFlow && status.index >= step.$1.index;
    final complete = status.isNormalFlow && status.index > step.$1.index;
    final color = reached
        ? AgrisellColors.authGreen
        : AgrisellColors.deliveryGray;
    final event = events
        .where((event) => event.newStatus == step.$1)
        .lastOrNull;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(height: index == 0 ? 0 : 3, color: color),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: RiderDeliveryReferenceStyles.marker(color),
                child: Icon(
                  complete ? Icons.check_rounded : step.$3,
                  size: 18,
                  color: AgrisellColors.surface,
                ),
              ),
              Expanded(
                child: Container(
                  height: index == _steps.length - 1 ? 0 : 3,
                  color: complete
                      ? AgrisellColors.authGreen
                      : AgrisellColors.deliveryGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            step.$2,
            textAlign: TextAlign.center,
            style: RiderDeliveryReferenceStyles.timelineText(reached),
          ),
          if (event != null)
            Text(
              MaterialLocalizations.of(context).formatTimeOfDay(
                TimeOfDay.fromDateTime(event.timestamp.toLocal()),
              ),
              textAlign: TextAlign.center,
              style: RiderDeliveryReferenceStyles.timelineLabel,
            ),
        ],
      ),
    );
  }
}
