import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_confirmation_styles.dart';

class FarmerRiderConfirmationActions extends StatelessWidget {
  const FarmerRiderConfirmationActions({super.key});

  @override
  Widget build(BuildContext context) {
    final back = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(false),
      style: FarmerRiderConfirmationStyles.backButtonStyle,
      child: const Text(
        'Back',
        style: FarmerRiderConfirmationStyles.buttonTextStyle,
      ),
    );

    final send = FilledButton(
      onPressed: () => Navigator.of(context).pop(true),
      style: FarmerRiderConfirmationStyles.sendButtonStyle,
      child: const Text(
        'Send request',
        textAlign: TextAlign.center,
        style: FarmerRiderConfirmationStyles.buttonTextStyle,
      ),
    );

    if (MediaQuery.sizeOf(context).width < 336 ||
        MediaQuery.textScalerOf(context).scale(14) > 19) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [send, const SizedBox(height: 8), back],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: back),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: send),
      ],
    );
  }
}
