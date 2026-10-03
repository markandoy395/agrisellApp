import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_history_screen_styles.dart';

class FarmerHistoryLoadFailure extends StatelessWidget {
  const FarmerHistoryLoadFailure({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Unable to load order history.',
          style: FarmerHistoryScreenStyles.errorTextStyle,
        ),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
