import 'package:flutter/material.dart';
import '../styles/farmer_delivery_fee_styles.dart';

Future<double?> showFarmerDeliveryFeeDialog(
  BuildContext context, {
  double? initialFee,
}) => showDialog<double>(
  context: context,
  builder: (_) => _DeliveryFeeDialog(initialFee: initialFee),
);

class _DeliveryFeeDialog extends StatefulWidget {
  const _DeliveryFeeDialog({this.initialFee});
  final double? initialFee;

  @override
  State<_DeliveryFeeDialog> createState() => _DeliveryFeeDialogState();
}

class _DeliveryFeeDialogState extends State<_DeliveryFeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.initialFee?.toStringAsFixed(2) ?? '',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Set the delivery fee'),
    scrollable: true,
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter the fee you are offering for this delivery. The rider sees '
            'this amount before accepting. Arrange funding with your administrator; '
            'entering a fee does not collect payment.',
          ),
          Padding(
            padding: FarmerDeliveryFeeStyles.padding,
            child: TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: FarmerDeliveryFeeStyles.input,
              validator: (value) {
                final text = value?.trim() ?? '';
                final fee = double.tryParse(text);
                if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text) ||
                    fee == null ||
                    !fee.isFinite ||
                    fee <= 0 ||
                    fee > 999999999999.99) {
                  return 'Enter a positive fee with up to two decimals.';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.of(context).pop(double.parse(_amount.text.trim()));
          }
        },
        child: const Text('Review request'),
      ),
    ],
  );
}
