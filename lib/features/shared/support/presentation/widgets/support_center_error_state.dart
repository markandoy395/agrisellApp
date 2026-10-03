import 'package:flutter/material.dart';

import '../styles/support_center_styles.dart';

class SupportCenterErrorState extends StatelessWidget {
  const SupportCenterErrorState({
    required this.errorMessage,
    required this.onRetry,
    super.key,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: SupportCenterStyles.errorPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: SupportCenterStyles.errorIconSize,
            color: SupportCenterStyles.errorIconColor,
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: SupportCenterStyles.errorTextStyle,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    ),
  );
}
