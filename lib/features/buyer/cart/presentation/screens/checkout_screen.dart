import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/agrisellPageRoute.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_payment_repository.dart';
import 'package:agresell_app/features/buyer/cart/domain/farmer_gcash_details.dart';
import 'package:agresell_app/features/buyer/profile/data/user_profile_data.dart';
import 'package:agresell_app/features/buyer/cart/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/presentation/location_selector.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_price_formatter.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/notched_checkout_footer.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

part 'checkout_screen_state.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_header.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_content.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_item_tile.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_item_helpers.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_payment_methods.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/empty_checkout_state.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_bottom_bar.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_payment_sheet.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_payment_notice.dart';
part 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/gcash_multi_farm_notice.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    this.initialDeliveryAddress,
    this.paymentRepository = const SupabaseCheckoutPaymentRepository(),
    this.locationRepository,
    super.key,
  });

  final String? initialDeliveryAddress;
  final CheckoutPaymentRepository paymentRepository;
  final ConfirmedLocationRepository? locationRepository;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
