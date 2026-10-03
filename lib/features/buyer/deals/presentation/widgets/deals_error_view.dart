import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/deals/presentation/styles/deals_and_promos_screen_styles.dart';

class DealsErrorView extends StatelessWidget {
  const DealsErrorView({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Unable to load deals.',
            style: DealsAndPromosScreenStyles.errorTextStyle,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onRetry,
            style: DealsAndPromosScreenStyles.tryAgainButtonStyle,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
