import 'package:agresell_app/features/rider/presentation/styles/rider_status_pills_styles.dart';
import 'package:flutter/material.dart';

/// A small, color-configurable label for rider availability or delivery state.
class RiderStatusPill extends StatelessWidget {
  const RiderStatusPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: RiderStatusPillsStyles.containerDecoration(backgroundColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon case final icon?) ...[
              Icon(icon, size: 14, color: foregroundColor),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RiderStatusPillsStyles.labelText(foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rider-specific status pill that uses a verification icon by default.
class RiderVerificationPill extends StatelessWidget {
  const RiderVerificationPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon = Icons.verified_rounded,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return RiderStatusPill(
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: icon,
    );
  }
}
