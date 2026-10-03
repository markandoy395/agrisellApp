import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_screen_styles.dart';
import 'package:agresell_app/features/buyer/chat/presentation/buyer_conversation_launcher.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

abstract final class CheckoutFarmerMessenger {
  static Future<void> openFarmerConversation(
    BuildContext context, {
    required List<BasketCartItem> items,
    MarketplaceMessagingRepository? messagingRepository,
  }) async {
    if (items.isEmpty) {
      _showMessage(context, CheckoutScreenStyles.selectItemBeforeMessaging);
      return;
    }

    final item = items.first;
    if (!items.every((candidate) => hasSameSeller(item, candidate))) {
      _showMessage(
        context,
        CheckoutScreenStyles.multipleFarmersMessagingNotice,
      );
      return;
    }

    final parsedCommodityId = int.tryParse(item.productId.trim());
    final commodityId = parsedCommodityId != null && parsedCommodityId > 0
        ? item.productId.trim()
        : null;
    final farmId = item.farmId != null && item.farmId! > 0 ? item.farmId : null;
    if (commodityId == null && farmId == null) {
      _showMessage(context, CheckoutScreenStyles.invalidConversationRefNotice);
      return;
    }

    await BuyerConversationLauncher.open(
      context,
      sellerName: item.sellerName,
      commodityId: commodityId,
      farmId: farmId,
      productName: item.productName,
      repository: messagingRepository,
    );
  }

  static bool hasSameSeller(BasketCartItem first, BasketCartItem candidate) {
    final firstFarmId = first.farmId;
    final candidateFarmId = candidate.farmId;
    if (firstFarmId != null &&
        firstFarmId > 0 &&
        candidateFarmId != null &&
        candidateFarmId > 0) {
      return firstFarmId == candidateFarmId;
    }
    return first.sellerName.trim() == candidate.sellerName.trim() &&
        first.sellerLocation.trim() == candidate.sellerLocation.trim();
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showAppSnackBar(
      CheckoutScreenStyles.snackBar(message),
    );
  }
}
