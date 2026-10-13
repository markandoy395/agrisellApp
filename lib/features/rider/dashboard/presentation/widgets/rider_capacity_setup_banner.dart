import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import '../styles/rider_capacity_setup_banner_styles.dart';

class RiderCapacitySetupBanner extends StatelessWidget {
  const RiderCapacitySetupBanner({required this.onSetCapacity, super.key});
  final VoidCallback onSetCapacity;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('rider-capacity-setup-banner'),
    padding: RiderCapacitySetupBannerStyles.padding,
    decoration: RiderCapacitySetupBannerStyles.decoration,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Set your cargo capacity',
          style: RiderCapacitySetupBannerStyles.title,
        ),
        const SizedBox(height: 6),
        const Text(
          'Before accepting multiple orders, enter how many kilograms your vehicle can carry. All items and quantities across your active orders must fit your saved capacity.',
          style: SharedPresentationStyles.caption,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const ValueKey('rider-set-capacity-button'),
          onPressed: onSetCapacity,
          style: RiderCapacitySetupBannerStyles.button,
          icon: const Icon(Icons.scale_outlined, size: 18),
          label: const Text('Set capacity'),
        ),
      ],
    ),
  );
}
