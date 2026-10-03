import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutScreenStyles {
  // Colors
  static const Color scaffoldBackground = AgrisellColors.homeBackground;

  // Feedback Messages
  static const String enterVoucherPrompt = 'Please enter a voucher code.';
  static const String voucherValidationFailure =
      'Unable to validate voucher. Please try again.';
  static const String deliveryLocationConfirmed =
      'Delivery location successfully confirmed.';
  static const String gcashReviewNotice =
      'Review the GCash details for the selected farmer.';
  static const String confirmLocationFirstNotice =
      'Confirm your exact delivery map location first.';
  static const String orderSaveFailedNotice =
      'The order could not be saved. Please try again.';
  static const String orderPlacedSuccessNotice = 'Order placed successfully.';
  static const String selectItemBeforeMessaging =
      'Select an item before messaging its farmer.';
  static const String multipleFarmersMessagingNotice =
      'This checkout contains multiple farmers. Select items from one farmer to open the correct conversation.';
  static const String invalidConversationRefNotice =
      'This farmer conversation is unavailable because its reference is invalid.';
  static const String selectDeliveryLocationHint = 'Select a delivery location';

  // Components
  static SnackBar snackBar(String message) => SnackBar(content: Text(message));
}
