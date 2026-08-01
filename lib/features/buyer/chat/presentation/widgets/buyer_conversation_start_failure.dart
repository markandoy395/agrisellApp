import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';

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
      child: ChatContentState(
        data: ChatContentStateData(
          icon: Icons.error_outline_rounded,
          title: 'Could not message $sellerName',
          message:
              'Check your connection and try opening the conversation again.',
        ),
        style: const ChatContentStateStyle(
          padding: EdgeInsets.all(24),
          iconSize: 36,
          titleStyle: TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          titleMessageSpacing: 6,
          actionSpacing: 14,
        ),
        action: Wrap(
          spacing: 8,
          children: [
            if (onBack != null)
              SizedBox(
                height: 36,
                child: TextButton(onPressed: onBack, child: const Text('Back')),
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
      ),
    ),
  );
}
