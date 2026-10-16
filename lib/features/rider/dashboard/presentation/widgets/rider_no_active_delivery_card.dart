import 'package:flutter/material.dart';
import '../../../presentation/widgets/rider_page_widgets.dart';
import '../styles/rider_home_design_styles.dart';
import 'rider_empty_illustration.dart';

class RiderNoActiveDeliveryCard extends StatelessWidget {
  const RiderNoActiveDeliveryCard({required this.onContinue, super.key});
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    decoration: RiderHomeDesignStyles.card,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(
              Icons.delivery_dining_rounded,
              size: 22,
              color: RiderHomeDesignStyles.green,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No active delivery',
                style: RiderHomeDesignStyles.title,
              ),
            ),
          ],
        ),
        const RiderEmptyIllustration(delivery: true),
        const Text(
          'Accepted jobs and route progress will appear here.',
          textAlign: TextAlign.center,
          style: RiderHomeDesignStyles.body,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onContinue,
          style: RiderHomeDesignStyles.primaryButton,
          icon: const Icon(Icons.search_rounded, size: 20),
          label: const Text('Browse delivery requests'),
        ),
      ],
    ),
  );
}
