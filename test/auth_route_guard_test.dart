import 'package:agresell_app/features/auth/domain/auth_route_guard.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
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

  test('verification badges remain accurate', () {
    expect(
      _account(role: 'farmer', verificationStatus: 'pending').isFarmerVerified,
      isFalse,
    );
    expect(
      _account(role: 'farmer', verificationStatus: 'verified').isFarmerVerified,
      isTrue,
    );
    expect(
      _account(role: 'buyer', verificationStatus: 'pending').isFarmerVerified,
      isFalse,
    );
  });

  test('active pending farmers may upload while blocked accounts cannot', () {
    for (final verification in ['pending', 'verified', 'needs_information']) {
      expect(
        _account(
          role: 'farmer',
          verificationStatus: verification,
        ).canUploadProducts,
        isTrue,
      );
    }
    for (final status in ['pending', 'suspended', 'disabled', 'rejected']) {
      expect(
        _account(
          role: 'farmer',
          status: status,
          verificationStatus: 'verified',
        ).canUploadProducts,
        isFalse,
      );
    }
    expect(_account(role: 'buyer').canUploadProducts, isFalse);
    expect(
      _account(
        role: 'farmer',
        verificationStatus: 'rejected',
      ).canUploadProducts,
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
