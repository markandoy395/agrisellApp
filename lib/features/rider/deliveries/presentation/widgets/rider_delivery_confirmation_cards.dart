import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_delivery_confirmation_styles.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderDeliveryRequiredProofCard extends StatelessWidget {
  const RiderDeliveryRequiredProofCard({
    required this.configuration,
    super.key,
  });

  final DeliveryCompletionConfiguration configuration;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required delivery proof',
          style: RiderDeliveryConfirmationStyles.requiredProofTitle,
        ),
        const SizedBox(height: RiderDeliveryConfirmationStyles.spacing6),
        for (final method in configuration.requiredMethods)
          Padding(
            padding: RiderDeliveryConfirmationStyles.bulletPadding,
            child: Text(
              '• ${method.label}',
              style: RiderDeliveryConfirmationStyles.bulletText,
            ),
          ),
        if (!configuration.requiredMethods.contains(
          DeliveryConfirmationMethod.handoverPhoto,
        ))
          const Padding(
            padding: RiderDeliveryConfirmationStyles.bulletPadding,
            child: Text(
              '• Delivery evidence photo',
              style: RiderDeliveryConfirmationStyles.bulletText,
            ),
          ),
      ],
    ),
  );
}

class RiderDeliveryRecipientCard extends StatelessWidget {
  const RiderDeliveryRecipientCard({
    required this.recipientName,
    super.key,
  });

  final String recipientName;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Row(
      children: [
        const Icon(
          Icons.person_outline,
          size: RiderDeliveryConfirmationStyles.iconSize20,
        ),
        const SizedBox(width: RiderDeliveryConfirmationStyles.spacing10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recipient name',
                style: RiderDeliveryConfirmationStyles.recipientLabel,
              ),
              Text(
                recipientName,
                style: RiderDeliveryConfirmationStyles.recipientValue,
              ),
              const Text(
                'From the buyer information',
                style: RiderDeliveryConfirmationStyles.recipientHelper,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class RiderDeliveryProofButton extends StatelessWidget {
  const RiderDeliveryProofButton({
    required this.label,
    required this.icon,
    required this.complete,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool complete;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(
      complete ? Icons.check_circle_outline : icon,
      size: RiderDeliveryConfirmationStyles.iconSize18,
    ),
    label: Text(label),
  );
}
