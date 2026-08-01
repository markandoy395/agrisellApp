import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class BuyerChatProductContext extends StatelessWidget {
  const BuyerChatProductContext({required this.thread, super.key});

  final MarketplaceConversation thread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ResponsiveAssetImage(
              asset: thread.productImageUrl == null
                  ? 'assets/images/vege.jpeg'
                  : null,
              imageUrl: thread.productImageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              semanticLabel: '${thread.productName ?? thread.farmName} context',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Talking about',
                  style: TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                Text(
                  thread.contextLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
