import 'package:agresell_app/features/buyer/cart/presentation/styles/quantity_stepper_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: QuantityStepperStyles.decoratedBoxDecoration,
      child: SizedBox(
        height: 36,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperButton(
              tooltip: 'Decrease quantity',
              icon: Icons.remove,
              onPressed: onDecrement,
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$quantity',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: QuantityStepperStyles.textStyle,
              ),
            ),
            _StepperButton(
              tooltip: 'Increase quantity',
              icon: Icons.add,
              onPressed: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon, size: 17, color: AgrisellColors.authGreen),
    );
  }
}
