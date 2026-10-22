import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/notification_permission_prompt.dart';
import 'package:agresell_app/core/widgets/notification_permission_benefit.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_inventory_repository.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_screen_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_inventory_reconciler.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_price_calculator.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

abstract final class CheckoutOrderSubmission {
  static bool isGcashMatched({
    required OrderPayment payment,
    required List<BasketCartItem> items,
    required int? gcashFarmId,
  }) {
    if (payment.method != OrderPaymentMethod.gcash) return true;
    final farmIds = items.map((item) => item.farmId).toSet();
    return farmIds.length == 1 && farmIds.single == gcashFarmId;
  }

  static Future<bool> placeOrder({
    required BuildContext context,
    required OrderController orderController,
    required CheckoutInventoryRepository inventoryRepository,
    required BasketController basketController,
    required List<BasketCartItem> items,
    required ConfirmedLocation? location,
    required String phoneNumber,
    required OrderPayment payment,
    required int? gcashFarmId,
    AppliedVoucher? appliedVoucher,
  }) async {
    if (items.isEmpty) return false;
    if (!isGcashMatched(
      payment: payment,
      items: items,
      gcashFarmId: gcashFarmId,
    )) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        CheckoutScreenStyles.snackBar(CheckoutScreenStyles.gcashReviewNotice),
      );
      return false;
    }

    final deliveryAddress = WrittenAddress.valueOrNull(location?.address);
    if (location == null || deliveryAddress == null) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        CheckoutScreenStyles.snackBar(
          CheckoutScreenStyles.confirmLocationFirstNotice,
        ),
      );
      return false;
    }

    final List<PlacedOrder> orders;
    try {
      final itemsToSubmit = CheckoutPriceCalculator.applyVoucherDiscounts(
        items: items,
        selectedTotal: basketController.selectedTotal,
        appliedVoucher: appliedVoucher,
      );

      orders = await orderController.placeToShipOrders(
        items: itemsToSubmit,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        deliveryLatitude: location.latitude,
        deliveryLongitude: location.longitude,
        payment: payment,
      );
    } on OrderPlacementException catch (error) {
      if (!context.mounted) return false;
      await CheckoutInventoryReconciler.refreshIfNeeded(
        repository: inventoryRepository,
        controller: basketController,
        errorMessage: error.message,
        submittedItems: items,
      );
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(CheckoutScreenStyles.snackBar(error.message));
      return false;
    } on Object {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showAppSnackBar(
        CheckoutScreenStyles.snackBar(
          CheckoutScreenStyles.orderSaveFailedNotice,
        ),
      );
      return false;
    }

    if (!context.mounted) return false;
    if (orders.isEmpty) return false;
    basketController.removeSelected();
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(
      CheckoutScreenStyles.snackBar(
        CheckoutScreenStyles.orderPlacedSuccessNotice,
      ),
    );
    await NotificationPermissionPrompt.offer(
      context,
      benefit: NotificationPermissionBenefit.buyer,
    );
    if (!context.mounted) return true;
    Navigator.of(context).pushReplacement(
      agrisellPageRoute<void>(builder: (_) => const OrderTrackingScreen()),
    );
    return true;
  }
}
