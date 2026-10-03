import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

import '../styles/order_dispute_styles.dart';
import '../utils/order_dispute_helpers.dart';
import 'order_dispute_dropdown.dart';
import 'order_dispute_header.dart';

class OrderDisputeForm extends StatelessWidget {
  const OrderDisputeForm({
    required this.order,
    required this.formKey,
    required this.reasonController,
    required this.category,
    required this.resolution,
    required this.onCategoryChanged,
    required this.onResolutionChanged,
    required this.onSubmit,
    required this.isSubmitting,
    super.key,
  });

  final PlacedOrder order;
  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final OrderDisputeCategory category;
  final OrderDisputeResolution resolution;
  final ValueChanged<OrderDisputeCategory> onCategoryChanged;
  final ValueChanged<OrderDisputeResolution> onResolutionChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderDisputeHeader(order: order),
        const SizedBox(height: 16),
        OrderDisputeDropdown<OrderDisputeCategory>(
          label: 'What is the issue with your delivered produce?',
          value: category,
          values: OrderDisputeCategory.values,
          labelForValue: (value) => value.label,
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 14),
        OrderDisputeDropdown<OrderDisputeResolution>(
          label: 'Requested Resolution',
          value: resolution,
          values: OrderDisputeResolution.values,
          labelForValue: (value) => value.label,
          onChanged: onResolutionChanged,
        ),
        const SizedBox(height: 14),
        const Text(
          'Details & Evidence Description',
          style: OrderDisputeStyles.fieldLabel,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: reasonController,
          maxLines: 4,
          maxLength: 500,
          validator: validateOrderDisputeReason,
          decoration: OrderDisputeStyles.reasonDecoration,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: OrderDisputeStyles.submitButton,
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Dispute Claim',
                    style: OrderDisputeStyles.submitText,
                  ),
          ),
        ),
      ],
    ),
  );
}
