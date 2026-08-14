import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/profile/domain/rider_account_exit_policy.dart';

void main() {
  test('switching accounts preserves Rider availability', () async {
    var prepareForLogoutCalls = 0;

    final allowed = await RiderAccountExitPolicy.prepare(
      RiderAccountExitAction.switchAccount,
      prepareForLogout: () async {
        prepareForLogoutCalls++;
        return true;
      },
    );

    expect(allowed, isTrue);
    expect(prepareForLogoutCalls, 0);
  });

  test('logging out still prepares Rider availability', () async {
    var prepareForLogoutCalls = 0;

    final allowed = await RiderAccountExitPolicy.prepare(
      RiderAccountExitAction.logout,
      prepareForLogout: () async {
        prepareForLogoutCalls++;
        return true;
      },
    );

    expect(allowed, isTrue);
    expect(prepareForLogoutCalls, 1);
  });
}
