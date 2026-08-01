import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/auth/presentation/widgets/account_switcher_content.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_account_fixture.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  tearDown(() {
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });

  test(
    'switches between remembered accounts and isolates basket state',
    () async {
      final first = await _register(
        role: AuthRole.buyer,
        email: 'first@example.com',
        phone: '09111111111',
      );
      final second = await _register(
        role: AuthRole.farmer,
        email: 'second@example.com',
        phone: '09222222222',
      );
      await AuthSessionService.instance.start(first, rememberMe: true);
      BasketController.instance.addProduct(_product);
      expect(BasketController.instance.hasItems, isTrue);

      await AuthSessionService.instance.start(second, rememberMe: true);
      expect(BasketController.instance.hasItems, isFalse);
      expect(
        (await AuthSessionService.instance.availableAccounts()).map(
          (account) => account.id,
        ),
        [second.id, first.id],
      );

      final switched = await AuthSessionService.instance.switchTo(first.id);
      expect(switched.id, first.id);
      expect(AuthSessionService.instance.currentAccount?.id, first.id);
      expect(BasketController.instance.hasItems, isFalse);
      expect(
        (await SharedPreferences.getInstance()).getString(
          'auth.session.account-id',
        ),
        first.id,
      );
    },
  );

  test(
    'logout removes only the active saved account from this device',
    () async {
      final first = await _register(
        email: 'saved@example.com',
        phone: '09333333333',
      );
      final second = await _register(
        email: 'active@example.com',
        phone: '09444444444',
      );
      await AuthSessionService.instance.start(first, rememberMe: true);
      await AuthSessionService.instance.start(second, rememberMe: true);

      await AuthSessionService.instance.clear();

      final remaining = await AuthSessionService.instance.availableAccounts();
      expect(remaining.map((account) => account.id), [first.id]);
      expect(AuthSessionService.instance.currentAccount, isNull);
    },
  );

  test('saved account metadata never contains password material', () async {
    final account = await _register(
      email: 'private@example.com',
      phone: '09555555555',
    );
    await AuthSessionService.instance.start(account, rememberMe: true);

    final preferences = await SharedPreferences.getInstance();
    final metadata = preferences.getString('auth.saved-accounts.v1');

    expect(metadata, isNotNull);
    expect(metadata, isNot(contains('password')));
    expect(metadata, isNot(contains(account.passwordHash)));
    expect(metadata, isNot(contains(account.passwordSalt)));
  });

  testWidgets('account picker identifies current and selectable accounts', (
    tester,
  ) async {
    const buyer = SavedAccount(
      id: 'buyer-id',
      firstName: 'Buyer',
      lastName: 'Account',
      email: 'buyer.switch@example.com',
      role: 'buyer',
    );
    const farmer = SavedAccount(
      id: 'farmer-id',
      firstName: 'Farmer',
      lastName: 'Account',
      email: 'farmer.switch@example.com',
      role: 'farmer',
    );
    SavedAccount? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: AccountSwitcherContent(
            accounts: const [farmer, buyer],
            currentAccountId: farmer.id,
            switchingAccountId: null,
            onSelect: (account) => selected = account,
            onRemove: (_) {},
            onAdd: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('buyer.switch@example.com • Buyer'), findsOneWidget);
    expect(find.text('farmer.switch@example.com • Farmer'), findsOneWidget);
    await tester.tap(find.text('buyer.switch@example.com • Buyer'));

    expect(selected, buyer);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}

Future<RegisteredAccount> _register({
  AuthRole role = AuthRole.buyer,
  required String email,
  required String phone,
}) {
  return registerTestAccount(role: role, email: email, phoneNumber: phone);
}

const _product = HomeProduct(
  id: '1',
  name: 'Tomato',
  price: '50',
  unit: 'kg',
  image: '',
  harvestDate: 'Today',
  availableWeight: '10 kg',
  sellerName: 'Farmer',
  sellerLocation: 'Laguna',
);
