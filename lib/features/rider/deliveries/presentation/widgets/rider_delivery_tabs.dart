import 'package:flutter/material.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_stage.dart';
import '../controllers/rider_delivery_controller.dart';
import '../controllers/rider_location_controller.dart';
import '../screens/rider_delivery_details_screen.dart';
import '../../../presentation/widgets/rider_state_cards.dart';
import 'rider_active_trip_card.dart';
import 'rider_active_trip_summary.dart';

class RiderActiveDeliveryList extends StatelessWidget {
  const RiderActiveDeliveryList({
    required this.controller,
    required this.riderId,
    this.locationController,
    this.onOpenConversation,
    this.onOpenMap,
    this.capacityKg,
    super.key,
  });
  final RiderDeliveryController controller;
  final String? riderId;
  final RiderLocationController? locationController;
  final Future<bool> Function(String deliveryId)? onOpenConversation;
  final VoidCallback? onOpenMap;
  final double? capacityKg;

  @override
  Widget build(BuildContext context) {
    final active = controller.routeOrderedRequests
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
      key: const PageStorageKey('rider-active-list'),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: active.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return RiderActiveTripSummary(
            deliveries: active,
            plan: controller.batchPlan,
            capacityKg: capacityKg,
          );
        }
        final request = active[index - 1];
        return RiderActiveTripCard(
          key: ValueKey(request.id),
          request: request,
          status: controller.statusFor(request),
          onManage: riderId == null ? null : () => _manage(context, request),
          onMap: riderId == null || onOpenMap == null
              ? null
              : () {
                  controller.selectActiveDelivery(request.id);
                  onOpenMap!();
                },
        );
      },
    );
  }

  void _manage(BuildContext context, DeliveryRequest request) {
    controller.selectActiveDelivery(request.id);
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderDeliveryDetailsScreen(
          request: request,
          controller: controller,
          riderId: riderId!,
          locationController: locationController,
          onOpenConversation: onOpenConversation,
        ),
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
