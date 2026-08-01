import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_history_details_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_history_widgets.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderHistoryList extends StatelessWidget {
  const RiderHistoryList({required this.controller, super.key});

  final RiderDeliveryController controller;

  @override
  Widget build(BuildContext context) {
    final completedIds = {
      for (final record in controller.completionHistory) record.request.id,
    };
    final history = <RiderDeliveryHistoryEntry>[
      for (final record in controller.completionHistory)
        RiderDeliveryHistoryEntry.fromCompletion(record),
      for (final request in controller.requests)
        if (request.stage.isTerminal && !completedIds.contains(request.id))
          _fromClosedRequest(request),
    ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    if (history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: RiderEmptyStateCard(
            title: 'No delivery history',
            message:
                'Completed, cancelled, failed, returned, and disputed deliveries will appear here.',
            icon: Icons.history_rounded,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 156),
      itemCount: history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = history[index];
        return RiderHistoryEntryCard(
          entry: entry,
          onTap: () => Navigator.of(context).push(
            agrisellPageRoute<void>(
              builder: (_) => RiderHistoryDetailsScreen(entry: entry),
            ),
          ),
        );
      },
    );
  }

  RiderDeliveryHistoryEntry _fromClosedRequest(DeliveryRequest request) =>
      RiderDeliveryHistoryEntry(
        id: request.id,
        orderNumber: request.orderNumber,
        completedAt:
            request.closedAt ?? request.outcome?.recordedAt ?? DateTime.now(),
        pickupAddress: request.pickupLocation.address,
        deliveryAddress: request.deliveryLocation.address,
        productName: request.productName,
        quantityDescription: request.quantityDescription,
        deliveryFee: request.deliveryFee,
        status: request.stage == DeliveryStage.cancelled
            ? RiderHistoryStatus.cancelled
            : RiderHistoryStatus.failed,
        sellerName: request.sellerName,
        buyerName: request.buyerName,
        proofTypes: [for (final proof in request.proofs) proof.type],
      );
}
