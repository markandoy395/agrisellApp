import 'package:agresell_app/features/farmer/reservations/presentation/styles/reserve_action_buttons_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class MessageBuyerButton extends StatelessWidget {
  const MessageBuyerButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: ReserveActionButtonsStyles.filledButtonStyle,
        icon: const Icon(Icons.chat_bubble_rounded, size: 15),
        label: const Text(
          'Message Buyer',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ConfirmDeliveryButton extends StatelessWidget {
  const ConfirmDeliveryButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ReserveActionButtonsStyles.outlinedButtonStyle,
          child: const Text(
            'Confirm order to deliver',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class ToShipStatusNotice extends StatelessWidget {
  const ToShipStatusNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: ReserveActionButtonsStyles.containerDecoration,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: AgrisellColors.authGreen,
              size: 15,
            ),
            SizedBox(width: 7),
            Text(
              'Moved to To Ship',
              style: ReserveActionButtonsStyles.movedToToShipText,
            ),
          ],
        ),
      ),
    );
  }
}
