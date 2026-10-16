import 'package:flutter/material.dart';

import '../styles/rider_delivery_confirmation_styles.dart';

class RiderDeliveryConfirmationFooter extends StatelessWidget {
  const RiderDeliveryConfirmationFooter({
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: RiderDeliveryConfirmationStyles.footerPadding,
      child: FilledButton(
        style: RiderDeliveryConfirmationStyles.submitButton,
        onPressed: isSubmitting ? null : onSubmit,
        child: Text(isSubmitting ? 'Confirming...' : 'Complete delivery'),
      ),
    ),
  );
}
