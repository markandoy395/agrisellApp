import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

Future<void> showGcashReferenceRetrySheet(
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
    builder: (_) => _GcashReferenceRetrySheet(order: order),
  );
}

class _GcashReferenceRetrySheet extends StatefulWidget {
  const _GcashReferenceRetrySheet({required this.order});

  final PlacedOrder order;

  @override
  State<_GcashReferenceRetrySheet> createState() =>
      _GcashReferenceRetrySheetState();
}

class _GcashReferenceRetrySheetState extends State<_GcashReferenceRetrySheet> {
  final _controller = TextEditingController();
  var _saving = false;
  String? _error;

  bool get _isValid =>
      RegExp(r'^[A-Za-z0-9 _-]{6,40}$').hasMatch(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Replace GCash reference',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close payment update',
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AgrisellColors.statusRedBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AgrisellColors.statusRedText,
                  size: 19,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The farmer could not match the previous reference. Copy the exact reference from your GCash receipt.',
                    style: TextStyle(
                      color: AgrisellColors.statusRedText,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('replacement-gcash-reference'),
            controller: _controller,
            enabled: !_saving,
            maxLength: 40,
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'New GCash reference number',
              prefixIcon: const Icon(Icons.receipt_long_outlined, size: 19),
              filled: true,
              fillColor: AgrisellColors.searchBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_error case final message?) ...[
            Text(
              message,
              style: const TextStyle(
                color: AgrisellColors.statusRedText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 7),
          ],
          SizedBox(
            width: double.infinity,
            height: 38,
            child: FilledButton.icon(
              onPressed: _saving || !_isValid ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AgrisellColors.authGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: Text(
                _saving ? 'Submitting…' : 'Submit for verification',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await OrderController.instance.resubmitGcashReference(
        orderId: widget.order.id,
        reference: _controller.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showAppSnackBar(
        const SnackBar(content: Text('New GCash reference submitted.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        final detail = error.toString().replaceFirst('Exception: ', '').trim();
        _error = detail.isEmpty
            ? 'The reference could not be submitted. Please try again.'
            : detail;
      });
    }
  }
}
