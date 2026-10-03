import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/profile/domain/farmer_history_section.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_feedback_card.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_card.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

class FarmerHistoryOrderList extends StatelessWidget {
  const FarmerHistoryOrderList({
    required this.section,
    required this.orders,
    required this.controller,
    required this.riderRequestFor,
    required this.onChooseRider,
    required this.onCancelRiderRequest,
    required this.isCancellingRiderRequest,
    super.key,
  });

  final FarmerHistorySection section;
  final List<PlacedOrder> orders;
  final OrderController controller;
  final FarmerRiderRequest? Function(String orderId) riderRequestFor;
  final Future<void> Function(PlacedOrder order) onChooseRider;
  final Future<void> Function(FarmerRiderRequest request) onCancelRiderRequest;
  final bool Function(String requestId) isCancellingRiderRequest;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return _EmptyHistorySection(section: section);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 14.0;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        14,
        horizontalPadding,
        24,
      ),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        if (section == FarmerHistorySection.feedback) {
          return FarmerFeedbackCard(order: order);
        }
        final riderRequest = riderRequestFor(order.id);
        return FarmerOrderWorkflowCard(
          order: order,
          controller: controller,
          riderRequest: riderRequest,
          onChooseRider: section == FarmerHistorySection.toShip
              ? () => onChooseRider(order)
              : null,
          onCancelRiderRequest: section == FarmerHistorySection.toShip
              ? onCancelRiderRequest
              : null,
          isCancellingRiderRequest: isCancellingRiderRequest(
            riderRequest?.id ?? '',
          ),
        );
      },
    );
  }
}

class _EmptyHistorySection extends StatelessWidget {
  const _EmptyHistorySection({required this.section});

  final FarmerHistorySection section;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: AgrisellColors.authGreen,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No ${section.label.toLowerCase()} orders',
            textAlign: TextAlign.center,
            style: SharedPresentationStyles.headingSubtitleExtraBold,
          ),
          const SizedBox(height: 5),
          Text(
            section == FarmerHistorySection.feedback
                ? 'Buyer feedback on completed products will appear here.'
                : 'Orders will appear here when they reach this stage.',
            textAlign: TextAlign.center,
            style: SharedPresentationStyles.mutedCaption,
          ),
        ],
      ),
    ),
  );
}
