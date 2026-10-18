import 'package:agresell_app/main_styles.dart';
import 'dart:async';
import 'package:agresell_app/core/updates/app_update_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/core/services/system_ui_service.dart';
import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/system_ui_scope.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/auth_role_gate.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_scope.dart';
import 'package:agresell_app/features/auth/presentation/auth_navigation_observer.dart';
import 'package:agresell_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/basket_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/farmer_shop_screen.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/farmer/profile/presentation/screens/farmer_history_screen.dart';
import 'package:agresell_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  _configureImageCache();
  unawaited(AgrisellSystemUi.applyAppSystemUi());
  final supabaseInitialization = AgrisellSupabase.initialize();

  runApp(AgrisellApp(supabaseInitialization: supabaseInitialization));
  unawaited(_initializeNotifications());
}

Future<void> _initializeNotifications() async {
  try {
    await _initializeFirebase();
    await PushNotificationService.instance.initialize();
    final account = AuthSessionService.instance.currentAccount;
    if (AuthSessionService.instance.isAuthenticated && account != null) {
      await PushNotificationService.instance.registerForUser(account.id);
    }
  } on Object {
    // Optional messaging must not prevent startup or produce an unhandled error.
  }
}

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  } catch (_) {}
}

void _configureImageCache() {
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 120;
  imageCache.maximumSizeBytes = 64 << 20;
}

class AgrisellApp extends StatelessWidget {
  const AgrisellApp({this.supabaseInitialization, super.key});

  final Future<bool>? supabaseInitialization;
  static final _navigatorKey = GlobalKey<NavigatorState>();
  static final _authNavigationObserver = AuthNavigationObserver();
  static final _appUpdateObserver = AppUpdateObserver();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [_authNavigationObserver, _appUpdateObserver],
      title: 'AgriSell App',
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      themeMode: ThemeMode.light,
      builder: (context, child) {
        return AuthNavigationScope(
          navigatorKey: _navigatorKey,
          observer: _authNavigationObserver,
          child: DefaultTextStyle.merge(
            style: MainStyles.textStyle,
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
        AgrisellRoutes.buyerOrders: (_) => const AuthRoleGate(
          requiredRole: AuthRole.buyer,
          redirectFor: AuthDashboardRouter.destinationFor,
          child: OrderTrackingScreen(),
        ),
        AgrisellRoutes.toShip: (_) => const AuthRoleGate(
          requiredRole: AuthRole.farmer,
          redirectFor: AuthDashboardRouter.destinationFor,
          child: FarmerHistoryScreen(),
        ),
      },
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: (_) =>
          agrisellPageRoute<void>(builder: (_) => const LoginScreen()),
      home: SplashScreen(supabaseInitialization: supabaseInitialization),
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
