import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class MessageBuyerButton extends StatelessWidget {
  const MessageBuyerButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AgrisellColors.authGreen,
          foregroundColor: AgrisellColors.surface,
          elevation: 3,
          shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.18),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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
          style: OutlinedButton.styleFrom(
            foregroundColor: AgrisellColors.authGreen,
            side: const BorderSide(color: AgrisellColors.authGreen, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            textStyle: const TextStyle(
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
        decoration: BoxDecoration(
          color: AgrisellColors.statusGreenBackground,
          borderRadius: BorderRadius.circular(8),
        ),
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
              style: TextStyle(
                color: AgrisellColors.authGreen,
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
