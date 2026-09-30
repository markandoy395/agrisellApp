import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/auth_role_selection_helpers.dart';

const _connectivityMethodChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);
const _connectivityEventChannel = EventChannel(
  'dev.fluttercommunity.plus/connectivity_status',
);
const _connectivityEventMethodChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity_status',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_installConnectivityPlusMock);
  tearDownAll(_clearConnectivityPlusMock);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  tearDown(() {
    AuthRegistrationService.instance.clearForTesting();
    AuthSessionService.instance.clearMemoryForTesting();
  });

  testWidgets('signup starts with a role choice before the form', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Are you a'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Farmer'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Buyer'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Rider'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Buyer'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 2'), findsOneWidget);
    expect(find.text('Account credentials'), findsOneWidget);
    expect(find.text('First Name'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Are you a'), findsNothing);
  });

  testWidgets('buyer role opens buyer home after signup', (tester) async {
    await pumpRoleSelection(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Buyer'));
    await tester.pumpAndSettle();
    await enterValidSignUpDetails(tester, email: 'Ana@Example.com');
    final signUpButton = find.widgetWithText(FilledButton, 'Sign up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await _pumpUntilFound(tester, find.byType(CustomBottomNavBar));

    final account = AuthRegistrationService.instance.registeredAccounts.single;

    expect(account.firstName, 'Ana');
    expect(account.lastName, 'Reyes');
    expect(account.email, 'ana@example.com');
    expect(account.extensionName, 'Jr.');
    expect(account.phoneNumber, '+639171234567');
    expect(account.dateOfBirth, '2000-01-01');
    expect(account.shippingAddress, 'Purok 5, Lianga, Surigao del Sur');
    expect(account.role, 'buyer');
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(
      find.text('Your Buyer account was created successfully.'),
      findsWidgets,
    );
    expect(find.text('Search in AgriSell'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Add new products'), findsNothing);
  });

  testWidgets('farmer role opens the multi-step Farmer signup', (tester) async {
    await pumpRoleSelection(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Farmer'));
    await tester.pumpAndSettle();

    expect(find.byType(FarmerSignUpScreen), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('Account information'), findsOneWidget);
    expect(find.text('Submit registration'), findsNothing);
  });

  testWidgets('discarding Farmer signup returns to role selection', (
    tester,
  ) async {
    await pumpRoleSelection(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Farmer'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard registration?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Are you a'), findsOneWidget);
    expect(find.byType(FarmerSignUpScreen), findsNothing);
  });

  testWidgets('discarding Rider signup returns to role selection', (
    tester,
  ) async {
    await pumpRoleSelection(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Rider'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back to role selection'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Your Rider Sign-Up is not yet complete'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Discard Registration'));
    await tester.pumpAndSettle();

    expect(find.text('Are you a'), findsOneWidget);
    expect(find.byType(RiderSignUpScreen), findsNothing);
  });

  testWidgets('rider role opens the rider registration form', (tester) async {
    await pumpRoleSelection(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Rider'));
    await tester.pumpAndSettle();

    expect(find.byType(RiderSignUpScreen), findsOneWidget);
    expect(find.text('Rider Sign-Up'), findsOneWidget);
    expect(find.text('1 of 6'), findsOneWidget);
    expect(find.text('Account credentials'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('First name'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'rider@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'Strong123!',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'Strong123!',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('2 of 6'), findsOneWidget);
    expect(find.text('Personal information'), findsWidgets);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Phone number (09XXXXXXXXX)'), findsOneWidget);
  });

  testWidgets('rider account returns to the rider dashboard after login', (
    tester,
  ) async {
    await AuthRegistrationService.instance.register(
      const SignUpAccountData(
        firstName: 'Rider',
        lastName: 'One',
        email: 'rider@example.com',
        password: 'password123',
      ),
      AuthRole.rider,
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: const LoginScreen(),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Email or phone number'),
      'rider@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    // Rider Home intentionally keeps reconnect checks alive. Wait only for the
    // navigation result instead of settling unrelated background timers.
    await _pumpUntilFound(tester, find.byType(RiderHomeScreen));

    expect(find.byType(RiderHomeScreen), findsOneWidget);
  });
}

void _installConnectivityPlusMock() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(_connectivityMethodChannel, (
    MethodCall methodCall,
  ) async {
    if (methodCall.method == 'check') return <String>['wifi'];
    return null;
  });

  messenger.setMockMethodCallHandler(_connectivityEventMethodChannel, (
    MethodCall methodCall,
  ) async {
    switch (methodCall.method) {
      case 'listen':
        await messenger.handlePlatformMessage(
          _connectivityEventChannel.name,
          _connectivityEventChannel.codec.encodeSuccessEnvelope(<String>[
            'wifi',
          ]),
          (_) {},
        );
        return null;
      case 'cancel':
        return null;
    }
    return null;
  });
}

void _clearConnectivityPlusMock() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(_connectivityMethodChannel, null);
  messenger.setMockMethodCallHandler(_connectivityEventMethodChannel, null);
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final pumps = timeout.inMilliseconds ~/ 100;
  for (var index = 0; index < pumps; index++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  final visibleText = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .toSet()
      .take(20)
      .join(' | ');
  fail(
    'Timed out waiting for ${finder.describeMatch(Plurality.one)}; '
    'activeAccount=${AuthSessionService.instance.currentAccount?.email}; '
    'visibleText=$visibleText.',
  );
}
