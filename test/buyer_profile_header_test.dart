import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_header.dart';

void main() {
  final testProfile = UserProfile(
    name: 'Maria Santos',
    firstName: 'Maria',
    lastName: 'Santos',
    email: 'maria@example.com',
    phoneNumber: '09171234567',
    address: 'Brgy 1, City',
    gender: 'Female',
    dateOfBirth: '1995-01-01',
  );

  testWidgets('renders buyer profile header with default elements', (
    tester,
  ) async {
    var backPressed = false;
    var cartPressed = false;
    var settingsPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            profile: testProfile,
            isVerified: true,
            title: 'Account',
            onBack: () => backPressed = true,
            onBasketTap: () => cartPressed = true,
            showSettingsIcon: true,
            onSettingsTap: () => settingsPressed = true,
            followingCount: 15,
            followerCount: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('Verified Buyer'), findsOneWidget);
    expect(find.text('15 Following  |  1 Follower'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == '15 Following',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == '1 Follower',
      ),
      findsOneWidget,
    );

    // Tap back button
    await tester.tap(find.byTooltip('Back'));
    expect(backPressed, isTrue);

    // Tap cart button
    await tester.tap(find.byTooltip('Cart'));
    expect(cartPressed, isTrue);

    // Tap settings button
    await tester.tap(find.byTooltip('Settings'));
    expect(settingsPressed, isTrue);
  });

  testWidgets('renders unverified buyer account and edit avatar badge', (
    tester,
  ) async {
    var avatarEditPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            profile: testProfile,
            isVerified: false,
            title: 'Edit Profile',
            showAvatarEditBadge: true,
            onAvatarEdit: () => avatarEditPressed = true,
            followingCount: 0,
            followerCount: 5,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Buyer Account'), findsOneWidget);
    expect(find.text('0 Following  |  5 Followers'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == '0 Following',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == '5 Followers',
      ),
      findsOneWidget,
    );

    // Tap edit avatar button
    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    expect(avatarEditPressed, isTrue);
  });
}
