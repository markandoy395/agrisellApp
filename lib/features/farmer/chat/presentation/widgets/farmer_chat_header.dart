import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class FarmerChatHeader extends StatelessWidget {
  const FarmerChatHeader({
    required this.thread,
    required this.onBack,
    super.key,
  });

  final MarketplaceConversation thread;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        6,
        (topInset > 0 ? topInset : 24) + 8,
        14,
        12,
      ),
      decoration: BoxDecoration(
        color: AgrisellColors.authGreen,
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AgrisellColors.surface,
            tooltip: 'Back to messages',
          ),
          _BuyerAvatar(thread: thread),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.buyerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AgrisellColors.surface,
                    fontSize: 15,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  thread.contextLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AgrisellColors.surface.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _BuyerAvatar extends StatelessWidget {
  const _BuyerAvatar({required this.thread});
  final MarketplaceConversation thread;

  @override
  Widget build(BuildContext context) {
    final imageUrl = thread.buyerImageUrl;
    if (imageUrl != null) {
      return ClipOval(
        child: ResponsiveAssetImage(
          imageUrl: imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          semanticLabel: '${thread.buyerName} profile photo',
        ),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AgrisellColors.surface,
      child: Text(
        thread.initials,
        style: const TextStyle(
          color: AgrisellColors.authGreen,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
