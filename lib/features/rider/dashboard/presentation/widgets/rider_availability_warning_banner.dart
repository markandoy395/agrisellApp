import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_availability_card_styles.dart';

class RiderAvailabilityWarningBanner extends StatelessWidget {
  const RiderAvailabilityWarningBanner({
    required this.message,
    required this.onDismissed,
    super.key,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: RiderAvailabilityCardStyles.alertDecoration,
    child: Padding(
      padding: RiderAvailabilityCardStyles.warningPadding,
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AgrisellColors.statusOrangeText,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: RiderAvailabilityCardStyles.warningTextStyle,
            ),
          ),
          IconButton(
            tooltip: 'Dismiss warning',
            onPressed: onDismissed,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    ),
  );
}
