import 'package:agresell_app/main.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/core/utils/profile_edit_validator.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_home_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/auth_account_fixture.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('profile image validation rejects unsafe files', () {
    expect(
      ProfileEditValidator.validateProfileImage(
        fileName: 'profile.png',
        fileSizeBytes: 1024,
      ),
      isNull,
    );
    expect(
      ProfileEditValidator.validateProfileImage(
        fileName: 'profile.exe',
        fileSizeBytes: 1024,
      ),
      isNotNull,
    );
    expect(
      ProfileEditValidator.validateProfileImage(
        fileName: 'profile.png',
        fileSizeBytes: ProfileEditValidator.maxProfileImageBytes + 1,
      ),
      isNotNull,
    );
  });
  testWidgets('Agrisell auth flow opens universal login and registration', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const AgrisellApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Log In'), findsAtLeastNWidgets(1));
    expect(find.text('Email or phone number'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Are you a'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Farmer'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Buyer'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Rider'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Buyer'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Account credentials'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    expect(find.text('First Name'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Log in'),
      240,
      scrollable: find
          .ancestor(of: find.text('Log in'), matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Email or phone number'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Email or phone number is required.'), findsOneWidget);
  });
  testWidgets('auth forms keep focused fields above the keyboard', (
    tester,
  ) async {
    const screenSize = Size(430, 932);
    const keyboardHeight = 330.0;
    const keyboardTop = 602.0;
    tester.view.devicePixelRatio = 1;
    await tester.binding.setSurfaceSize(screenSize);
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.view.resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });
    await _pumpAuthScreen(tester, const LoginScreen());
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
    await tester.pumpAndSettle();
    final loginPasswordField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.controller?.text == 'password',
    );
    expect(tester.getBottomLeft(loginPasswordField).dy, lessThan(keyboardTop));
    tester.view.resetViewInsets();
    await _pumpAuthScreen(tester, const SignUpScreen(role: AuthRole.buyer));
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm Password'),
      'password',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
    await tester.pumpAndSettle();
    final confirmationField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.controller?.text == 'password',
    );
    expect(tester.getBottomLeft(confirmationField).dy, lessThan(keyboardTop));
  });
  testWidgets('login typography adapts across mobile widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    tester.view.physicalSize = const Size(320, 568);
    await _pumpAuthScreen(tester, const LoginScreen());
    final compactField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Email or phone number'),
    );
    final compactButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Log In'),
    );
    expect(compactField.decoration?.hintStyle?.fontSize, 12);
    expect(compactButton.style?.textStyle?.resolve({})?.fontSize, 12);
    expect(tester.getSize(find.byType(AuthTextField).first).height, 56);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Log In')).height,
      50,
    );
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(430, 932);
    await tester.pumpAndSettle();
    final largeField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Email or phone number'),
    );
    final largeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Log In'),
    );
    expect(largeField.decoration?.hintStyle?.fontSize, 14);
    expect(largeButton.style?.textStyle?.resolve({})?.fontSize, 13);
    expect(tester.getSize(find.byType(AuthTextField).first).height, 56);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Log In')).height,
      50,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Facebook social logo keeps wider circular proportions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SocialSignInButton(
                brand: SocialBrand.facebook,
                label: 'Sign in with Facebook',
              ),
              SocialSignInButton(
                brand: SocialBrand.google,
                label: 'Sign in with Google',
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.bySemanticsLabel('Facebook')).width, 34);
    expect(tester.getSize(find.bySemanticsLabel('Google')).width, 30);
    expect(
      tester
          .widgetList<ResponsiveAssetImage>(find.byType(ResponsiveAssetImage))
          .every((image) => image.maxDecodedWidth == 0),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('buyer typography adapts across mobile widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    tester.view.physicalSize = const Size(320, 568);
    await _pumpAuthScreen(tester, const HomeScreen());
    final compactContext = tester.element(find.text('Show all'));
    final compactScaler = MediaQuery.textScalerOf(compactContext);
    expect(compactScaler.scale(12), 12);
    expect(compactScaler.scale(15), closeTo(13.95, 0.001));
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(430, 932);
    await tester.pumpAndSettle();
    final largeContext = tester.element(find.text('Show all'));
    final largeScaler = MediaQuery.textScalerOf(largeContext);
    expect(largeScaler.scale(12), 12);
    expect(largeScaler.scale(15), 15);
    expect(tester.takeException(), isNull);
  });
  testWidgets('farmer tab shows the backend-empty farmer list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpAuthScreen(tester, const HomeScreen());
    expect(find.text('Show all'), findsOneWidget);
    await tester.tap(find.text('Farmers'));
    await tester.pumpAndSettle();
    expect(find.text('0 farmers found'), findsOneWidget);
    expect(find.text('No farmers found'), findsOneWidget);
    await tester.drag(find.text('Following'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Available now'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Follow'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Shop'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Pedro');
    await tester.pumpAndSettle();
    expect(find.text('0 farmers found'), findsOneWidget);
    expect(find.text('No farmers found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('notification tab opens the notification screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpAuthScreen(tester, const HomeScreen());
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Order Updates'), findsOneWidget);
    expect(find.text('Read All'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Deliveries'), findsOneWidget);
    expect(find.text('Messages'), findsAtLeastNWidgets(1));
    expect(find.text('No notifications yet'), findsOneWidget);
  });
  testWidgets('me tab opens the profile screen', (tester) async {
    await _startProfileSession(AuthRole.buyer, 'buyer.profile@example.com');
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpScreen(tester, const HomeScreen());
    await _pumpUntilFound(tester, find.text('Account'));
    await tester.tap(find.text('Account'));
    await _pumpUntilFound(tester, find.text('My orders').hitTestable());
    expect(find.text('Test Account'), findsAtLeastNWidgets(1));
    expect(find.text('My orders'), findsOneWidget);
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('Edit Profile'), findsNothing);
    expect(find.text('Logout'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Settings').hitTestable());
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Edit buyer profile'));
    await tester.tap(find.text('Edit buyer profile'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Save changes'));
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Name extension'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'DROP TABLE users');
    await _ensureVisibleCentered(tester, find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await _pumpUntilFound(
      tester,
      find.text('Remove unsafe command-like text from First Name.'),
    );
    expect(
      find.text('Remove unsafe command-like text from First Name.'),
      findsOneWidget,
    );
    expect(find.text('Save changes'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'New');
    await _ensureVisibleCentered(tester, find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('New Account'));
    expect(find.text('New Account'), findsAtLeastNWidgets(1));
    await tester.tap(find.byTooltip('Close settings'));
    await tester.pumpAndSettle();
    expect(find.text('August 1, 2024'), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Settings').hitTestable());
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Logout'));
    await _ensureVisibleCentered(tester, find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await _pumpUntilFound(
      tester,
      find.widgetWithText(TextField, 'Email or phone number'),
    );
    expect(find.text('Log In'), findsAtLeastNWidgets(1));
    expect(find.text('Email or phone number'), findsOneWidget);
  });
  testWidgets('buyer settings opens profile account actions', (tester) async {
    await _startProfileSession(AuthRole.buyer, 'buyer.settings@example.com');
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpScreen(tester, const HomeScreen());
    await _pumpUntilFound(tester, find.text('Account'));
    await tester.tap(find.text('Account'));
    await _pumpUntilFound(tester, find.text('My orders').hitTestable());
    await tester.tap(find.bySemanticsLabel('Settings').hitTestable());
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Edit buyer profile'));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Edit buyer profile'), findsOneWidget);
    expect(find.text('Switch account'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    await tester.tap(find.text('Edit buyer profile'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Save changes'));
    expect(find.byType(TextField), findsNWidgets(5));
    await _ensureVisibleCentered(tester, find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Edit buyer profile'));
    expect(find.text('Edit buyer profile'), findsOneWidget);
    await tester.tap(find.byTooltip('Close settings'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('My orders'), findsOneWidget);
  });
  testWidgets('farmer me tab shows dashboard and edit profile flow', (
    tester,
  ) async {
    await _startProfileSession(AuthRole.farmer, 'farmer.profile@example.com');
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpScreen(
      tester,
      const FarmerHomeScreen(initialNavIndex: FarmerHomeScreen.profileNavIndex),
    );
    await _pumpUntilFound(tester, find.text('My orders'));
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.text('Test Account'), findsAtLeastNWidgets(1));
    expect(
      find.text('Payouts & Disbursements'),
      findsOneWidget,
    );
    expect(find.text('My orders'), findsOneWidget);
    expect(find.text('To Ship'), findsOneWidget);
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('Edit Profile'), findsNothing);
    expect(find.text('Switch Account'), findsNothing);
    expect(find.text('Logout'), findsNothing);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Edit farmer profile'));
    await tester.tap(find.text('Edit farmer profile'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Save changes'));
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Name extension'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Switch Account'), findsNothing);
    expect(find.text('Logout'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'Farm');
    await _ensureVisibleCentered(tester, find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Farm Account'));
    await tester.scrollUntilVisible(
      find.text('Switch account'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Farm Account'), findsAtLeastNWidgets(1));
    expect(find.text('Switch account'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}

Future<void> _pumpAuthScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: screen,
    ),
  );
  await tester.pump();
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final attempts = timeout.inMilliseconds ~/ 100;
  for (var index = 0; index < attempts; index++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for ${finder.describeMatch(Plurality.one)}.');
}

Future<void> _startProfileSession(AuthRole role, String email) async {
  AuthRegistrationService.instance.clearForTesting();
  AuthSessionService.instance.clearMemoryForTesting();
  final account = await registerTestAccount(role: role, email: email);
  await AuthSessionService.instance.start(account, rememberMe: false);
  addTearDown(() {
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });
}

Future<void> _ensureVisibleCentered(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}
