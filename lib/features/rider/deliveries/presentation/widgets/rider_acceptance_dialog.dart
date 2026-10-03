import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_acceptance_dialog_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';

Future<DeliveryAcceptanceOutcome?> showRiderAcceptanceDialog(
  BuildContext context, {
  required DeliveryRequest request,
  required Future<DeliveryAcceptanceOutcome> Function() onConfirm,
}) => showDialog<DeliveryAcceptanceOutcome>(
  context: context,
  barrierDismissible: false,
  builder: (_) =>
      _RiderAcceptanceDialog(request: request, onConfirm: onConfirm),
);

class _RiderAcceptanceDialog extends StatefulWidget {
  const _RiderAcceptanceDialog({
    required this.request,
    required this.onConfirm,
  });

  final DeliveryRequest request;
  final Future<DeliveryAcceptanceOutcome> Function() onConfirm;

  @override
  State<_RiderAcceptanceDialog> createState() => _RiderAcceptanceDialogState();
}

class _RiderAcceptanceDialogState extends State<_RiderAcceptanceDialog> {
  bool _processing = false;
  DeliveryAcceptanceOutcome? _failure;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_processing,
    child: AlertDialog(
      title: const Text(
        'Accept this delivery?',
        style: SharedPresentationStyles.titleExtraBold,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryLine('Product', widget.request.productName),
              _SummaryLine('Pickup', widget.request.pickupLocation.address),
              _SummaryLine(
                'Destination',
                widget.request.deliveryLocation.address,
              ),
              _SummaryLine(
                'Estimated earning',
                'PHP ${widget.request.deliveryFee.toStringAsFixed(2)}',
                emphasized: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'The server will recheck your eligibility and reserve the '
                'delivery before confirming.',
                style: RiderAcceptanceDialogStyles.textStyle,
              ),
              if (_processing) ...[
                const SizedBox(height: 14),
                Semantics(
                  liveRegion: true,
                  label: 'Acceptance is processing',
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Securing this delivery...',
                          style: SharedPresentationStyles.captionBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_failure != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _failure!.message ?? 'The delivery could not be accepted.',
                    style: RiderAcceptanceDialogStyles.textStyle2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: _processing
          ? const []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
              if (_failure == null || (_failure!.failure?.canRetry ?? false))
                FilledButton(
                  onPressed: _confirm,
                  child: Text(
                    _failure == null ? 'Confirm acceptance' : 'Retry',
                  ),
                ),
            ],
    ),
  );

  Future<void> _confirm() async {
    if (_processing) return;
    setState(() {
      _processing = true;
      _failure = null;
    });
    final result = await widget.onConfirm();
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(result);
      return;
    }
    setState(() {
      _processing = false;
      _failure = result;
    });
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value, {this.emphasized = false});
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SharedPresentationStyles.mutedCaptionSemibold),
        const SizedBox(height: 2),
        Text(value, style: RiderAcceptanceDialogStyles.valueText(emphasized)),
      ],
    ),
  );
}
