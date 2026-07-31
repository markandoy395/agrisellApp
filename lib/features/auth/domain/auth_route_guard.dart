import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';

enum AuthRouteDestination {
  farmerDashboard,
  buyerDashboard,
  riderDashboard,
  riderApplicationStatus,
  accountAccessStatus,
}

class AuthRouteResolution {
  const AuthRouteResolution({required this.destination, this.message});

  final AuthRouteDestination destination;
  final String? message;

  bool get allowsDashboard => switch (destination) {
    AuthRouteDestination.farmerDashboard ||
    AuthRouteDestination.buyerDashboard ||
    AuthRouteDestination.riderDashboard => true,
    _ => false,
  };
}

/// The single source of truth for frontend role and account-status access.
class AuthRouteGuard {
  const AuthRouteGuard._();

  static AuthRouteResolution resolve(RegisteredAccount account) {
    final role = account.assignedRole;
    if (role == null) {
      return const AuthRouteResolution(
        destination: AuthRouteDestination.accountAccessStatus,
        message: 'Your account role is invalid. Please contact support.',
      );
    }

    return switch (account.status) {
      AuthAccountStatus.active => _activeRoleResolution(role),
      AuthAccountStatus.pending when role == AuthRole.rider =>
        const AuthRouteResolution(
          destination: AuthRouteDestination.riderApplicationStatus,
          message: 'Your account is still waiting for approval.',
        ),
      AuthAccountStatus.pending => const AuthRouteResolution(
        destination: AuthRouteDestination.accountAccessStatus,
        message: 'Your account is still waiting for approval.',
      ),
      AuthAccountStatus.suspended => const AuthRouteResolution(
        destination: AuthRouteDestination.accountAccessStatus,
        message: 'Your account has been suspended.',
      ),
      AuthAccountStatus.rejected when role == AuthRole.rider =>
        const AuthRouteResolution(
          destination: AuthRouteDestination.riderApplicationStatus,
          message: 'Your rider application was not approved.',
        ),
      AuthAccountStatus.rejected => const AuthRouteResolution(
        destination: AuthRouteDestination.accountAccessStatus,
        message: 'Your account application was not approved.',
      ),
      AuthAccountStatus.disabled => const AuthRouteResolution(
        destination: AuthRouteDestination.accountAccessStatus,
        message: 'This account is disabled. Please contact support.',
      ),
      AuthAccountStatus.unknown => const AuthRouteResolution(
        destination: AuthRouteDestination.accountAccessStatus,
        message: 'We could not verify your account status. Please try again.',
      ),
    };
  }

  static bool allowsRole(RegisteredAccount account, AuthRole role) {
    final destination = resolve(account).destination;
    return switch (role) {
      AuthRole.farmer => destination == AuthRouteDestination.farmerDashboard,
      AuthRole.buyer => destination == AuthRouteDestination.buyerDashboard,
      AuthRole.rider => destination == AuthRouteDestination.riderDashboard,
    };
  }

  static AuthRouteResolution _activeRoleResolution(AuthRole role) =>
      AuthRouteResolution(
        destination: switch (role) {
          AuthRole.farmer => AuthRouteDestination.farmerDashboard,
          AuthRole.buyer => AuthRouteDestination.buyerDashboard,
          AuthRole.rider => AuthRouteDestination.riderDashboard,
        },
      );
}
