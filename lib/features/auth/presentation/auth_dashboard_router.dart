import 'package:flutter/widgets.dart';

import 'package:agresell_app/features/auth/domain/auth_route_guard.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/auth_role_gate.dart';
import 'package:agresell_app/features/auth/presentation/screens/account_access_status_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_home_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_application_submitted_screen.dart';

class AuthDashboardRouter {
  const AuthDashboardRouter._();

  static Widget destinationFor(
    RegisteredAccount account, {
    String? initialMessage,
  }) {
    final resolution = AuthRouteGuard.resolve(account);
    if (resolution.destination == AuthRouteDestination.riderDashboard) {
      RiderRegistrationService.instance.selectProfile(account.email);
    }
    return switch (resolution.destination) {
      AuthRouteDestination.farmerDashboard => const AuthRoleGate(
        requiredRole: AuthRole.farmer,
        redirectFor: AuthDashboardRouter.destinationFor,
        child: FarmerHomeScreen(
          initialNavIndex: FarmerHomeScreen.productNavIndex,
        ),
      ),
      AuthRouteDestination.buyerDashboard => AuthRoleGate(
        requiredRole: AuthRole.buyer,
        redirectFor: AuthDashboardRouter.destinationFor,
        child: HomeScreen(
          initialNavIndex: HomeScreen.homeNavIndex,
          initialMessage: initialMessage,
        ),
      ),
      AuthRouteDestination.riderDashboard => const AuthRoleGate(
        requiredRole: AuthRole.rider,
        redirectFor: AuthDashboardRouter.destinationFor,
        child: RiderHomeScreen(),
      ),
      AuthRouteDestination.riderApplicationStatus =>
        RiderApplicationStatusScreen(
          reference: account.id,
          status: account.status == AuthAccountStatus.rejected
              ? RiderApplicationStatus.rejected
              : RiderApplicationStatus.pending,
        ),
      AuthRouteDestination.accountAccessStatus => AccountAccessStatusScreen(
        message:
            resolution.message ??
            'You do not have permission to access this page.',
      ),
    };
  }
}
