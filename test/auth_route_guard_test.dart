import 'package:agresell_app/features/auth/domain/auth_route_guard.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active accounts resolve to their assigned dashboards', () {
    expect(
      AuthRouteGuard.resolve(_account(role: 'farmer')).destination,
      AuthRouteDestination.farmerDashboard,
    );
    expect(
      AuthRouteGuard.resolve(_account(role: 'buyer')).destination,
      AuthRouteDestination.buyerDashboard,
    );
    expect(
      AuthRouteGuard.resolve(_account(role: 'rider')).destination,
      AuthRouteDestination.riderDashboard,
    );
  });

  test('pending and rejected rider accounts stay out of the dashboard', () {
    expect(
      AuthRouteGuard.resolve(
        _account(role: 'rider', status: 'pending'),
      ).destination,
      AuthRouteDestination.riderApplicationStatus,
    );
    expect(
      AuthRouteGuard.resolve(
        _account(role: 'rider', status: 'rejected'),
      ).destination,
      AuthRouteDestination.riderApplicationStatus,
    );
  });

  test('invalid roles and blocked statuses never receive a dashboard', () {
    expect(
      AuthRouteGuard.resolve(_account(role: 'admin')).allowsDashboard,
      isFalse,
    );
    expect(
      AuthRouteGuard.resolve(
        _account(role: 'buyer', status: 'suspended'),
      ).destination,
      AuthRouteDestination.accountAccessStatus,
    );
    expect(
      AuthRouteGuard.allowsRole(_account(role: 'farmer'), AuthRole.buyer),
      isFalse,
    );
  });

  test('only verified farmers may create products', () {
    expect(
      _account(
        role: 'farmer',
        verificationStatus: 'pending',
      ).isFarmerVerified,
      isFalse,
    );
    expect(
      _account(
        role: 'farmer',
        verificationStatus: 'verified',
      ).isFarmerVerified,
      isTrue,
    );
    expect(
      _account(
        role: 'buyer',
        verificationStatus: 'pending',
      ).isFarmerVerified,
      isFalse,
    );
  });
}

RegisteredAccount _account({
  required String role,
  String status = 'active',
  String? verificationStatus,
}) => RegisteredAccount(
  id: 'test-account',
  firstName: 'Test',
  lastName: 'User',
  email: 'test@example.com',
  passwordHash: 'hash',
  passwordSalt: 'salt',
  role: role,
  accountStatus: status,
  verificationStatus: verificationStatus,
);
