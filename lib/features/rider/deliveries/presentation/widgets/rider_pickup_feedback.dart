import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/pickup_confirmation.dart';
import '../styles/rider_pickup_design_styles.dart';

class RiderPickupFeedback extends StatelessWidget {
  const RiderPickupFeedback({required this.onDismiss, super.key});
  final VoidCallback onDismiss;
  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderPickupDesignStyles.tint(AgrisellColors.authGreen),
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AgrisellColors.authGreen,
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Problem saved', style: RiderPickupDesignStyles.title),
              Text(
                'Contact support before continuing pickup.',
                style: RiderPickupDesignStyles.body,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Dismiss saved problem',
          onPressed: onDismiss,
          icon: const Icon(Icons.close_rounded, size: 18),
        ),
      ],
    ),
  );
}

class RiderPickupValidationFeedback extends StatelessWidget {
  const RiderPickupValidationFeedback({
    required this.message,
    required this.issues,
    super.key,
  });
  final String message;
  final List<PickupValidationIssue> issues;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: RiderPickupDesignStyles.tint(AgrisellColors.statusRedText),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: RiderPickupDesignStyles.error),
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '• ${issue.message}',
              style: RiderPickupDesignStyles.error,
            ),
          ),
      ],
    ),
  );
}
