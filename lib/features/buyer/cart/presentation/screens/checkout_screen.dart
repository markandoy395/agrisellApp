import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_bottom_bar_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_header_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_item_helpers_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_item_tile_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_order_summary_panel_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_payment_methods_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/empty_checkout_state_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/gcash_multi_farm_notice_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/gcash_payment_notice_styles.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_payment_repository.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_inventory_repository.dart';
import 'package:agresell_app/features/shared/payments/domain/farmer_gcash_details.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_data.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/notched_checkout_footer.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_content_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_screen_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_voucher_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/gcash_payment_sheet_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_delivery_location_coordinator.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_farmer_messenger.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_order_submission.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_price_calculator.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_voucher_coordinator.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';

part 'checkout_screen_state.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_header.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_content.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_delivery_address_panel.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_item_tile.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_item_helpers.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_payment_methods.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/empty_checkout_state.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_bottom_bar.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_payment_sheet.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_receipt_helper.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_sheet_header.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_receipt_picker.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_submit_button.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_payment_notice.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_multi_farm_notice.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_voucher_panel.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_applied_voucher_view.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_voucher_input_view.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_order_summary_panel.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    this.initialDeliveryAddress,
    this.paymentRepository = const SupabaseCheckoutPaymentRepository(),
    this.inventoryRepository = const SupabaseCheckoutInventoryRepository(),
    this.voucherService = const CheckoutVoucherService(),
    this.locationRepository,
    this.gcashReceiptImagePicker,
    this.messagingRepository,
    super.key,
  });

  final String? initialDeliveryAddress;
  final CheckoutPaymentRepository paymentRepository;
  final CheckoutInventoryRepository inventoryRepository;
  final CheckoutVoucherService voucherService;
  final ConfirmedLocationRepository? locationRepository;
  final GcashReceiptImagePicker? gcashReceiptImagePicker;
  final MarketplaceMessagingRepository? messagingRepository;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
