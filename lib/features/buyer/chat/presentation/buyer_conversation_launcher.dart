import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

abstract final class BuyerConversationLauncher {
  static Future<void> open(
    BuildContext context, {
    required String sellerName,
    String? commodityId,
    int? farmId,
    String? clientOrderId,
    String? productName,
    MarketplaceMessagingRepository? repository,
  }) async {
    assert(commodityId != null || farmId != null);
    await Navigator.of(context).push<void>(
      agrisellPageRoute<void>(
        builder: (routeContext) => Scaffold(
          backgroundColor: AgrisellColors.homeBackground,
          body: BuyerMessageScreen(
            repository: repository,
            initialConversation: MarketplaceConversationSeed(
              sellerName: sellerName,
              commodityId: commodityId,
              farmId: farmId,
              clientOrderId: clientOrderId,
              productName: productName,
            ),
            chatBottomPadding: MediaQuery.paddingOf(routeContext).bottom + 10,
            onExit: () => Navigator.of(routeContext).maybePop(),
          ),
        ),
      ),
    );
  }
}
