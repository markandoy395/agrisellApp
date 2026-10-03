import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_gcash_refund_sheet_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

Future<void> showFarmerGcashRefundSheet(
  BuildContext context,
  PlacedOrder order,
) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  backgroundColor: AgrisellColors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (_) => _FarmerGcashRefundSheet(order: order),
);

class _FarmerGcashRefundSheet extends StatefulWidget {
  const _FarmerGcashRefundSheet({required this.order});

  final PlacedOrder order;

  @override
  State<_FarmerGcashRefundSheet> createState() =>
      _FarmerGcashRefundSheetState();
}

class _FarmerGcashRefundSheetState extends State<_FarmerGcashRefundSheet> {
  final _referenceController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      18,
      12,
      18,
      18 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Record GCash refund',
                style: SharedPresentationStyles.headingTitleBlack,
              ),
            ),
            IconButton(
              tooltip: 'Close refund form',
              onPressed: _saving ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
        const Text(
          'Send the refund in GCash first. Recording it here updates the buyer and preserves an audit reference.',
          style: SharedPresentationStyles.mutedCaptionLoose,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: FarmerGcashRefundSheetStyles.containerDecoration,
          child: Text(
            'Refund amount: ${formatBasketPeso(widget.order.total)}',
            style: FarmerGcashRefundSheetStyles.textStyle,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('gcash-refund-reference'),
          controller: _referenceController,
          enabled: !_saving,
          maxLength: 40,
          textCapitalization: TextCapitalization.characters,
          style: SharedPresentationStyles.body,
          decoration: FarmerGcashRefundSheetStyles.inputDecoration(_error),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 38,
          child: FilledButton.icon(
            onPressed: _saving ? null : _submit,
            style: FarmerGcashRefundSheetStyles.filledButtonStyle,
            icon: const Icon(Icons.task_alt_outlined, size: 17),
            label: Text(
              _saving ? 'Saving...' : 'Confirm refund completed',
              style: SharedPresentationStyles.captionExtraBold,
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await OrderController.instance.recordGcashRefund(
        orderId: widget.order.id,
        reference: _referenceController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('GCash refund recorded.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString().replaceFirst('Invalid argument(s): ', '');
      });
    }
  }
}
