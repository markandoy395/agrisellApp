import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
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
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('Verified Buyer'), findsOneWidget);
    expect(find.bySemanticsLabel('15 following'), findsOneWidget);
    expect(find.textContaining('Follower', findRichText: true), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == '15 Following',
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
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Buyer Account'), findsOneWidget);
    expect(find.bySemanticsLabel('0 following'), findsOneWidget);
    expect(find.textContaining('Follower', findRichText: true), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == '0 Following',
      ),
      findsOneWidget,
    );

    // Tap edit avatar button
    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    expect(avatarEditPressed, isTrue);
  });

  testWidgets('overview hides avatar editing even with an edit callback', (
    tester,
  ) async {
    var avatarEditPressed = false;
    for (final isVerified in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(
              profile: testProfile,
              isVerified: isVerified,
              onAvatarEdit: () => avatarEditPressed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
      expect(find.bySemanticsLabel('Change avatar'), findsNothing);
      await tester.tap(find.byIcon(Icons.person_rounded));
      expect(avatarEditPressed, isFalse);
      expect(
        find.byIcon(Icons.check_rounded),
        isVerified ? findsOneWidget : findsNothing,
      );
    }
  });

  testWidgets(
    'loads saved avatar through authenticated storage with fallback',
    (tester) async {
      final origin = AgrisellSupabase.projectUrl;
      const path = 'buyer-avatars/owner/avatar.png';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(
              profile: testProfile.copyWith(
                avatarUrl: '$origin/storage/v1/object/public/$path',
              ),
              isVerified: true,
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<NetworkImage>());
      expect(
        (image.image as NetworkImage).url,
        '$origin/storage/v1/object/authenticated/$path',
      );
      expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
