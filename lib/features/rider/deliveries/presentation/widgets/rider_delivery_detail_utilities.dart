import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';

class RiderDeliveryContactActions extends StatelessWidget {
  const RiderDeliveryContactActions({required this.onMessage, super.key});

  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _ContactButton(
        icon: Icons.call_outlined,
        label: 'Call',
        onTap: () => onMessage('Secure calling is ready to connect.'),
      ),
      const SizedBox(width: 8),
      _ContactButton(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Message',
        onTap: () => onMessage('Open the rider messages tab to chat.'),
      ),
      const SizedBox(width: 8),
      _ContactButton(
        icon: Icons.share_location_outlined,
        label: 'Location',
        onTap: () => onMessage('Location sharing needs rider consent.'),
      ),
    ],
  );
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AgrisellColors.authGreen,
        side: const BorderSide(color: AgrisellColors.borderLine),
        minimumSize: const Size.fromHeight(38),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

Future<DeliveryProof?> captureRiderDeliveryProof(
  BuildContext context,
  DeliveryProofPurpose purpose,
) async {
  final controller = TextEditingController();
  final label = purpose == DeliveryProofPurpose.pickup
      ? 'pickup confirmation code'
      : 'delivery confirmation code';
  final value = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Proof required'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: 'Enter the $label'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (value == null || value.isEmpty) return null;
  final timestamp = DateTime.now();
  return DeliveryProof(
    id: 'proof-${timestamp.microsecondsSinceEpoch}',
    type: purpose == DeliveryProofPurpose.pickup
        ? DeliveryProofType.pickupOneTimeCode
        : DeliveryProofType.deliveryOneTimeCode,
    secureReference: 'captured-${timestamp.microsecondsSinceEpoch}',
    capturedAt: timestamp,
  );
}

void showRiderDeliverySafetySheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'For safety, report an unsafe pickup, delivery issue, or cancellation reason through the connected support service.',
        style: TextStyle(
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

int riderDeliveryStageIndex(DeliveryStage stage) {
  return switch (stage) {
    DeliveryStage.accepted => 0,
    DeliveryStage.goingToPickup => 1,
    DeliveryStage.arrivedAtPickup => 2,
    DeliveryStage.pickedUp => 3,
    DeliveryStage.goingToDelivery => 4,
    DeliveryStage.arrivedAtDelivery => 5,
    DeliveryStage.delivered => 6,
    DeliveryStage.completed => 7,
    DeliveryStage.readyForPickup ||
    DeliveryStage.cancelled ||
    DeliveryStage.failed => 0,
  };
}
