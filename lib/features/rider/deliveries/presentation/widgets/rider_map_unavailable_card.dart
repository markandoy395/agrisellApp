import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_unavailable_card_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// A safe fallback while a map or location provider cannot render a route.
class RiderMapUnavailableCard extends StatelessWidget {
  const RiderMapUnavailableCard({
    required this.title,
    required this.message,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    super.key,
  });

  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final hasPrimaryAction =
        primaryActionLabel != null && onPrimaryAction != null;
    final hasSecondaryAction =
        secondaryActionLabel != null && onSecondaryAction != null;

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: SharedPresentationStyles.borderedSurface,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: RiderMapUnavailableCardStyles.containerDecoration,
                child: const Icon(
                  Icons.map_outlined,
                  color: AgrisellColors.statusBlueText,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: RiderMapUnavailableCardStyles.titleText,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: SharedPresentationStyles.mutedCaptionMediumLoose,
              ),
              if (hasPrimaryAction) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onPrimaryAction,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: Text(primaryActionLabel!),
                  style: RiderMapUnavailableCardStyles.filledButtonStyle,
                ),
              ],
              if (hasSecondaryAction) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(
                    secondaryActionLabel!,
                    style: RiderMapUnavailableCardStyles.textStyle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
