import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_details_screen_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/controllers/farmer_rider_assignment_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_information.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_card.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/delivery_waybill_sheet.dart';

class FarmerOrderDetailsScreen extends StatelessWidget {
  const FarmerOrderDetailsScreen({
    required this.order,
    required this.controller,
    required this.riderController,
    required this.onChooseRider,
    required this.onCancelRiderRequest,
    required this.onCancelOrder,
    super.key,
  });

  final PlacedOrder order;
  final OrderController controller;
  final FarmerRiderAssignmentController riderController;
  final Future<void> Function(PlacedOrder order) onChooseRider;
  final Future<void> Function(FarmerRiderRequest request) onCancelRiderRequest;
  final Future<void> Function(PlacedOrder order) onCancelOrder;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    appBar: AppBar(
      backgroundColor: AgrisellColors.surface,
      foregroundColor: AgrisellColors.headingGreen,
      surfaceTintColor: AgrisellColors.surface,
      title: const Text(
        'Order Details',
        style: SharedPresentationStyles.titleExtraBold,
      ),
      actions: [
        IconButton(
          key: const Key('farmer-print-waybill-appbar-button'),
          tooltip: 'Print Delivery Waybill',
          icon: const Icon(Icons.print_outlined),
          onPressed: () => _openWaybill(context),
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: Listenable.merge([controller, riderController]),
      builder: (context, _) {
        final currentOrder = _currentOrder;
        final riderRequest = riderController.requestFor(currentOrder.id);
        return SingleChildScrollView(
          key: const ValueKey('farmer-order-details-scroll'),
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 380 ? 12 : 14,
            14,
            MediaQuery.sizeOf(context).width < 380 ? 12 : 14,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FarmerOrderBuyerInformation(order: currentOrder),
              const SizedBox(height: 14),
              FarmerOrderInformation(order: currentOrder),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  key: const Key('farmer-open-waybill-button'),
                  onPressed: () => _openWaybill(context),
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text(
                    'Print / Download Delivery Waybill',
                    style: FarmerOrderDetailsScreenStyles
                        .printDownloadDeliveryWaybillText,
                  ),
                  style: FarmerOrderDetailsScreenStyles.outlinedButtonStyle,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Fulfillment',
                style: SharedPresentationStyles.headingTitleExtraBold,
              ),
              const SizedBox(height: 8),
              FarmerOrderWorkflowCard(
                order: currentOrder,
                controller: controller,
                riderRequest: riderRequest,
                onChooseRider: () => onChooseRider(currentOrder),
                onCancelRiderRequest: onCancelRiderRequest,
                isCancellingRiderRequest: riderController.isCancelling(
                  riderRequest?.id ?? '',
                ),
                onCancelOrder: () => onCancelOrder(currentOrder),
              ),
            ],
          ),
        );
      },
    ),
  );

  void _openWaybill(BuildContext context) {
    final currentOrder = _currentOrder;
    final riderRequest = riderController.requestFor(currentOrder.id);
    final courierLocation = riderRequest != null
        ? [
            riderRequest.riderBarangay,
            riderRequest.riderMunicipality,
          ].where((s) => s.isNotEmpty).join(', ')
        : null;
    final waybill = DeliveryWaybill.fromFarmerOrder(
      currentOrder,
      courierName: riderRequest?.riderName,
      courierContact: courierLocation,
    );
    showDeliveryWaybillSheet(context, waybill);
  }

  PlacedOrder get _currentOrder {
    for (final candidate in controller.orders) {
      if (candidate.id == order.id) return candidate;
    }
    return order;
  }
}
