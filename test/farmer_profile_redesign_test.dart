import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_history_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_header.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_info_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = UserProfile(
  name: 'Maria Santos',
  firstName: 'Maria',
  lastName: 'Santos',
  email: 'maria.santos@example.com',
  address: '',
  phoneNumber: '09171234567',
  gender: '',
  dateOfBirth: '2000-01-12',
);

void main() {
  for (final width in [320.0, 430.0]) {
    testWidgets(
      'farmer profile fits width $width with enlarged text and working actions',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var edited = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 900),
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    FarmerProfileHeader(
                      profile: _profile,
                      isVerified: true,
                      followingCount: 2,
                      followerCount: 1,
                    ),
                    const FarmerStatsCard(),
                    const FarmerHistoryCard(),
                    FarmerProfileInfoCard(
                      profile: _profile,
                      onEditProfile: () => edited = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Maria Santos'), findsOneWidget);
        expect(find.text('2 Following  |  1 Follower'), findsOneWidget);
        expect(find.byTooltip('Settings'), findsNothing);
        await tester.drag(find.byType(Scrollable), const Offset(0, -700));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit'));
        expect(edited, isTrue);
        await tester.scrollUntilVisible(find.text('January 12, 2000'), 150);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
