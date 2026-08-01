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
import 'support/auth_account_fixture.dart';

void main() {
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
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Name Extension (Optional)'), findsOneWidget);
    expect(find.text('Phone Number (09XXXXXXXXX)'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    await tester.ensureVisible(find.text('Log in'));
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
    await tester.binding.setSurfaceSize(screenSize);
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.binding.setSurfaceSize(null);
    });
    await _pumpAuthScreen(tester, const LoginScreen());
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password',
    );
    await tester.pumpAndSettle();
    expect(
      tester.getBottomLeft(find.widgetWithText(TextField, 'Password')).dy,
      lessThan(keyboardTop),
    );
    await _pumpAuthScreen(tester, const SignUpScreen(role: AuthRole.buyer));
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm Password'),
      'password',
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .getBottomLeft(find.widgetWithText(TextField, 'Confirm Password'))
          .dy,
      lessThan(keyboardTop),
    );
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
    final compactContext = tester.element(find.text('Categories'));
    final compactScaler = MediaQuery.textScalerOf(compactContext);
    expect(compactScaler.scale(12), 12);
    expect(compactScaler.scale(15), closeTo(13.95, 0.001));
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(430, 932);
    await tester.pumpAndSettle();
    final largeContext = tester.element(find.text('Categories'));
    final largeScaler = MediaQuery.textScalerOf(largeContext);
    expect(largeScaler.scale(12), 12);
    expect(largeScaler.scale(15), 15);
    expect(tester.takeException(), isNull);
  });
  testWidgets('farmer tab shows the backend-empty farmer list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpAuthScreen(tester, const HomeScreen());
    expect(find.text('Categories'), findsOneWidget);
    await tester.tap(find.text('Farmers'));
    await tester.pumpAndSettle();
    expect(find.text('0 farmers found'), findsOneWidget);
    expect(find.text('No farmers found'), findsOneWidget);
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
    await _pumpAuthScreen(tester, const HomeScreen());
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Test Account'), findsAtLeastNWidgets(1));
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Edit Profile'), findsNothing);
    expect(find.text('Logout'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit buyer profile'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Name Extension (Optional)'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'DROP TABLE users');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('Remove unsafe command-like text from First Name.'),
      findsOneWidget,
    );
    expect(find.text('Save'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'New');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('New Account'), findsAtLeastNWidgets(1));
    await tester.tap(find.byTooltip('Close settings'));
    await tester.pumpAndSettle();
    expect(find.text('August 1, 2024'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Log In'), findsAtLeastNWidgets(1));
    expect(find.text('Email or phone number'), findsOneWidget);
  });
  testWidgets('buyer settings opens profile account actions', (tester) async {
    await _startProfileSession(AuthRole.buyer, 'buyer.settings@example.com');
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpAuthScreen(tester, const HomeScreen());
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Edit buyer profile'), findsOneWidget);
    expect(find.text('Switch account'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    await tester.tap(find.text('Edit buyer profile'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(5));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Edit buyer profile'), findsOneWidget);
    await tester.tap(find.byTooltip('Close settings'));
    await tester.pumpAndSettle();
    expect(find.text('My Orders'), findsOneWidget);
  });
  testWidgets('farmer me tab shows dashboard and edit profile flow', (
    tester,
  ) async {
    await _startProfileSession(AuthRole.farmer, 'farmer.profile@example.com');
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpAuthScreen(
      tester,
      const FarmerHomeScreen(initialNavIndex: FarmerHomeScreen.profileNavIndex),
    );
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.text('Test Account'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Sales statistics will appear after the backend'),
      findsOneWidget,
    );
    expect(find.text('My history'), findsOneWidget);
    expect(find.text('To Ship'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Edit Profile'), findsNothing);
    expect(find.text('Switch Account'), findsNothing);
    expect(find.text('Logout'), findsNothing);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit farmer profile'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Name Extension (Optional)'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Switch Account'), findsNothing);
    expect(find.text('Logout'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'Farm');
    await tester.tap(find.text('Save'));
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

Future<void> _startProfileSession(AuthRole role, String email) async {
  AuthRegistrationService.instance.clearForTesting();
  AuthSessionService.instance.clearMemoryForTesting();
  final account = await registerTestAccount(role: role, email: email);
  await AuthSessionService.instance.start(account, rememberMe: false);
  addTearDown(() async {
    await AuthSessionService.instance.clear();
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });
}
