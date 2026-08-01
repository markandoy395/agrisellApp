import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/app_font_size_controller.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/core/services/system_ui_service.dart';
import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/system_ui_scope.dart';
import 'package:agresell_app/core/widgets/app_font_size_scope.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/auth_role_gate.dart';
import 'package:agresell_app/features/auth/presentation/screens/splashScreen.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/basket_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/farmer_shop_screen.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  _configureImageCache();
  unawaited(AgrisellSystemUi.applyAppSystemUi());
  await AppFontSizeController.instance.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.instance.initialize();
  await AgrisellSupabase.initialize();

  runApp(const AgrisellApp());
}

void _configureImageCache() {
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 120;
  imageCache.maximumSizeBytes = 64 << 20;
}

class AgrisellApp extends StatelessWidget {
  const AgrisellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSell',
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      builder: (context, child) {
        return AppFontSizeScope(
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontFamily: AgrisellTheme.fontFamily),
            child: SystemUiScope(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
      routes: {
        AgrisellRoutes.basket: (_) => const AuthRoleGate(
          requiredRole: AuthRole.buyer,
          redirectFor: AuthDashboardRouter.destinationFor,
          child: BasketScreen(),
        ),
        AgrisellRoutes.checkout: (_) => const AuthRoleGate(
          requiredRole: AuthRole.buyer,
          redirectFor: AuthDashboardRouter.destinationFor,
          child: CheckoutScreen(),
        ),
        AgrisellRoutes.toShip: (_) => const AuthRoleGate(
          requiredRole: AuthRole.farmer,
          redirectFor: AuthDashboardRouter.destinationFor,
          child: OrderTrackingScreen(),
        ),
      },
      onGenerateRoute: _onGenerateRoute,
      home: const SplashScreen(),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == AgrisellRoutes.farmerShop) {
      final farmer = settings.arguments;
      if (farmer is FarmerProfile) {
        return agrisellPageRoute<void>(
          builder: (_) => AuthRoleGate(
            requiredRole: AuthRole.buyer,
            redirectFor: AuthDashboardRouter.destinationFor,
            child: FarmerShopScreen(farmer: farmer),
          ),
        );
      }
    }

    return null;
  }
}
