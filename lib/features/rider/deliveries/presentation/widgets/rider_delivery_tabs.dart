import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_progress_timeline.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_details.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_batch_delivery_summary.dart';

class RiderActiveDeliveryList extends StatelessWidget {
  const RiderActiveDeliveryList({
    required this.controller,
    required this.riderId,
    super.key,
  });

  final RiderDeliveryController controller;
  final String? riderId;

  @override
  Widget build(BuildContext context) {
    final active = controller.requests
        .where(
          (item) =>
              item.stage != DeliveryStage.readyForPickup &&
              !item.stage.isTerminal,
        )
        .toList();
    if (active.isEmpty) {
      return const RiderDeliveryTabEmptyState(
        title: 'No active delivery',
        message: 'Accepted delivery trips will appear here.',
        icon: Icons.route_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 156),
      itemCount: active.length + (active.length > 1 ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (active.length > 1 && index == 0) {
          return RiderBatchDeliverySummary(
            deliveries: active,
            plan: controller.batchPlan,
          );
        }
        final deliveryIndex = active.length > 1 ? index - 1 : index;
        return _ActiveDeliveryCard(
          request: active[deliveryIndex],
          controller: controller,
          riderId: riderId,
        );
      },
    );
  }
}

class _ActiveDeliveryCard extends StatelessWidget {
  const _ActiveDeliveryCard({
    required this.request,
    required this.controller,
    required this.riderId,
  });

  final DeliveryRequest request;
  final RiderDeliveryController controller;
  final String? riderId;

  @override
  Widget build(BuildContext context) {
    return RiderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.productName,
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          RiderRequestDetailLine(
            icon: Icons.place_outlined,
            text: 'Pick up from: ${request.pickupLocation.address}',
          ),
          RiderRequestDetailLine(
            icon: Icons.location_on_outlined,
            text: 'Deliver to: ${request.deliveryLocation.address}',
          ),
          const SizedBox(height: 8),
          RiderDeliveryProgressTimeline(
            currentStatus: controller.statusFor(request),
            events: controller.statusEventsFor(request.id),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: riderId == null
                ? null
                : () {
                    controller.selectActiveDelivery(request.id);
                    Navigator.of(context).push(
                      agrisellPageRoute<void>(
                        builder: (_) => RiderDeliveryDetailsScreen(
                          request: request,
                          controller: controller,
                          riderId: riderId!,
                        ),
                      ),
                    );
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AgrisellColors.authGreen,
              minimumSize: const Size.fromHeight(38),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Manage delivery'),
          ),
        ],
      ),
    );
  }
}

class RiderDeliveryTabEmptyState extends StatelessWidget {
  const RiderDeliveryTabEmptyState({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: RiderEmptyStateCard(title: title, message: message, icon: icon),
    ),
  );
}
