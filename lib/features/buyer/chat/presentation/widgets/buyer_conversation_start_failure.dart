import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class BuyerConversationStartFailure extends StatelessWidget {
  const BuyerConversationStartFailure({
    required this.sellerName,
    required this.onRetry,
    required this.onBack,
    super.key,
  });

  final String sellerName;
  final VoidCallback onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AgrisellColors.homeBackground,
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AgrisellColors.authGreen,
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                'Could not message $sellerName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Check your connection and try opening the conversation again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  if (onBack != null)
                    SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: onBack,
                        child: const Text('Back'),
                      ),
                    ),
                  SizedBox(
                    height: 36,
                    child: FilledButton(
                      onPressed: onRetry,
                      child: const Text('Try again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
