import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import '../styles/order_dispute_styles.dart';
import '../utils/order_dispute_helpers.dart';
import 'order_dispute_form.dart';
import 'order_dispute_summary.dart';

Future<void> showOrderDisputeSheet(
  BuildContext context, {
  required PlacedOrder order,
  required SubmitOrderDispute onSubmitDispute,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: AgrisellColors.surface,
  shape: OrderDisputeStyles.sheetShape,
  builder: (_) =>
      _OrderDisputeSheet(order: order, onSubmitDispute: onSubmitDispute),
);

class _OrderDisputeSheet extends StatefulWidget {
  const _OrderDisputeSheet({
    required this.order,
    required this.onSubmitDispute,
  });

  final PlacedOrder order;
  final SubmitOrderDispute onSubmitDispute;

  @override
  State<_OrderDisputeSheet> createState() => _OrderDisputeSheetState();
}

class _OrderDisputeSheetState extends State<_OrderDisputeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  var _selectedCategory = OrderDisputeCategory.damagedRottenProduce;
  var _selectedResolution = OrderDisputeResolution.fullRefund;
  var _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmitDispute(
        orderId: widget.order.id,
        category: _selectedCategory,
        reason: _reasonController.text.trim(),
        requestedResolution: _selectedResolution,
      );

      if (mounted) {
        Navigator.of(context).pop();
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showAppSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Dispute submitted for administrator review.'),
          ),
        );
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showAppSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(orderDisputeErrorMessage(error)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dispute = widget.order.dispute;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: OrderDisputeStyles.sheetPadding(bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: OrderDisputeStyles.handleDecoration,
                ),
              ),
              const SizedBox(height: 16),
              if (dispute != null)
                OrderDisputeSummary(order: widget.order, dispute: dispute)
              else
                OrderDisputeForm(
                  order: widget.order,
                  formKey: _formKey,
                  reasonController: _reasonController,
                  category: _selectedCategory,
                  resolution: _selectedResolution,
                  onCategoryChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  onResolutionChanged: (value) =>
                      setState(() => _selectedResolution = value),
                  onSubmit: _submit,
                  isSubmitting: _isSubmitting,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
