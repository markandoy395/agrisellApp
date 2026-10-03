import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_request_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_gcash_review_sheet_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_gcash_review_summary.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

Future<void> showFarmerGcashReviewSheet(
  BuildContext context,
  PlacedOrder order,
) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AgrisellColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FarmerGcashReviewSheet(order: order),
  );
}

class _FarmerGcashReviewSheet extends StatefulWidget {
  const _FarmerGcashReviewSheet({required this.order});

  final PlacedOrder order;

  @override
  State<_FarmerGcashReviewSheet> createState() =>
      _FarmerGcashReviewSheetState();
}

class _FarmerGcashReviewSheetState extends State<_FarmerGcashReviewSheet> {
  var _saving = false;
  String? _error;
  bool get _expired => widget.order.isExpired;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _expired
                    ? 'Review expired GCash payment'
                    : 'Review GCash reference',
                style: SharedPresentationStyles.headingTitleBlack,
              ),
            ),
            IconButton(
              tooltip: 'Close payment review',
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          _expired
              ? 'Check whether the payment was received. Confirming it will require a buyer refund and will not restore the expired order.'
              : 'Confirm the reference against your GCash transaction history before accepting this order.',
          style: SharedPresentationStyles.mutedCaptionLoose,
        ),
        const SizedBox(height: 13),
        FarmerGcashReviewSummary(order: widget.order),
        if (_error case final message?) ...[
          const SizedBox(height: 9),
          Text(message, style: SharedPresentationStyles.errorCaptionSemibold),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _decisionButton(approved: false)),
            const SizedBox(width: 9),
            Expanded(child: _decisionButton(approved: true)),
          ],
        ),
      ],
    ),
  );

  Widget _decisionButton({required bool approved}) => SizedBox(
    height: 38,
    child: approved
        ? FilledButton.icon(
            onPressed: _saving ? null : () => _review(true),
            style: FarmerRiderRequestStyles.chooseAnotherButtonStyle,
            icon: const Icon(Icons.verified_outlined, size: 16),
            label: Text(
              _expired ? 'Received' : 'Verify',
              style: SharedPresentationStyles.caption,
            ),
          )
        : OutlinedButton.icon(
            onPressed: _saving ? null : () => _review(false),
            style: FarmerGcashReviewSheetStyles.outlinedButtonStyle,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text(
              'Reject',
              style: SharedPresentationStyles.caption,
            ),
          ),
  );

  Future<void> _review(bool approved) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await OrderController.instance.reviewGcashPayment(
        orderId: widget.order.id,
        approved: approved,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showAppSnackBar(
        SnackBar(
          content: Text(
            _expired
                ? approved
                      ? 'Payment received. A refund is now required.'
                      : 'Payment marked as not received.'
                : approved
                ? 'GCash payment verified.'
                : 'GCash reference rejected.',
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        final detail = error.toString().replaceFirst('Exception: ', '').trim();
        _error = detail.isEmpty
            ? 'The payment decision could not be saved. Try again.'
            : detail;
      });
    }
  }
}
