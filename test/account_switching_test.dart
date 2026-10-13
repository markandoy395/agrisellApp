import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/auth/presentation/widgets/account_switcher_content.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/widgets/profile/safe_circle_avatar.dart';
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

  test(
    'switching preserves an outgoing account that was not remembered',
    () async {
      final outgoing = await _register(
        email: 'outgoing@example.com',
        phone: '09555555555',
      );
      final saved = await _register(
        email: 'saved@example.com',
        phone: '09666666666',
      );
      await AuthSessionService.instance.start(saved, rememberMe: true);
      await AuthSessionService.instance.start(outgoing, rememberMe: false);

      await AuthSessionService.instance.switchTo(saved.id);

      expect(
        (await AuthSessionService.instance.availableAccounts()).map(
          (account) => account.id,
        ),
        [saved.id, outgoing.id],
      );
    },
  );

  test(
    'adding an account preserves the outgoing account before login',
    () async {
      final outgoing = await _register(
        email: 'outgoing-add@example.com',
        phone: '09777777777',
      );
      final added = await _register(
        email: 'added@example.com',
        phone: '09888888888',
      );
      await AuthSessionService.instance.start(outgoing, rememberMe: false);

      await AuthSessionService.instance.preserveCurrentAccountForSwitch();
      await AuthSessionService.instance.start(added, rememberMe: true);

      expect(
        (await AuthSessionService.instance.availableAccounts()).map(
          (account) => account.id,
        ),
        [added.id, outgoing.id],
      );
    },
  );

  testWidgets('opening the account switcher preserves the active account', (
    tester,
  ) async {
    final outgoing = await _register(
      email: 'outgoing-navigation@example.com',
      phone: '09999999999',
    );
    await AuthSessionService.instance.start(outgoing, rememberMe: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              await AccountSessionNavigation.openSwitcher(context);
            },
            child: const Text('Open switcher'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open switcher'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('auth.saved-accounts.v1'),
      contains(outgoing.id),
    );
  });

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

    expect(find.text('buyer.switch@example.com'), findsOneWidget);
    expect(find.text('farmer.switch@example.com'), findsOneWidget);
    expect(find.text('Buyer'), findsOneWidget);
    expect(find.text('Farmer'), findsOneWidget);
    await tester.tap(find.text('buyer.switch@example.com'));

    expect(selected, buyer);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('account picker shows an image or first and last initials', (
    tester,
  ) async {
    const withImage = SavedAccount(
      id: 'buyer-image',
      firstName: 'Maria',
      lastName: 'Santos',
      email: 'maria@example.com',
      role: 'buyer',
      profileImageUrl: 'https://example.com/maria.jpg',
    );
    const withoutImage = SavedAccount(
      id: 'farmer-initials',
      firstName: 'Juan',
      lastName: 'Dela Cruz',
      email: 'juan@example.com',
      role: 'farmer',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: AccountSwitcherContent(
            accounts: const [withImage, withoutImage],
            currentAccountId: null,
            switchingAccountId: null,
            onSelect: (_) {},
            onRemove: (_) {},
            onAdd: () {},
          ),
        ),
      ),
    );

    final avatars = tester.widgetList<SafeCircleAvatar>(
      find.byType(SafeCircleAvatar),
    );
    expect(avatars.first.imageUrl, withImage.profileImageUrl);
    expect(find.text('JD'), findsOneWidget);
  });

  test('saved account profile image remains backward compatible', () {
    final legacy = SavedAccount.fromJson(const {
      'id': 'legacy',
      'firstName': 'Ana',
      'lastName': 'Reyes',
      'email': 'ana@example.com',
      'role': 'buyer',
    });
    final restored = SavedAccount.fromJson(const {
      'id': 'new',
      'firstName': 'Leo',
      'lastName': 'Ramos',
      'email': 'leo@example.com',
      'role': 'rider',
      'profileImageUrl': 'https://example.com/leo.jpg',
    });

    expect(legacy.profileImageUrl, isNull);
    expect(restored.profileImageUrl, 'https://example.com/leo.jpg');
    expect(restored.toJson()['profileImageUrl'], restored.profileImageUrl);
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
