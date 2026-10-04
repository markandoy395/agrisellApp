import 'support/authenticated_test_session.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/profile/presentation/controllers/farmer_profile_controller.dart';
import 'package:agresell_app/features/farmer/profile/presentation/screens/farmer_profile_screen.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_edit_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_view.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/widgets/farmer_information_request_banner.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/screens/farmer_reviews_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';

const profile = UserProfile(
  name: 'Maria Santos',
  firstName: 'Maria',
  lastName: 'Santos',
  email: 'maria@example.com',
  address: '',
  phoneNumber: '09171234567',
  gender: '',
  dateOfBirth: 'January 31, 2000',
);
const details = FarmerVerificationDetails(action: 'needs_information');

void main() {
  configureAuthenticatedTests(role: AuthRole.farmer);
  test(
    'profile save preserves mode transitions and loaded verification details',
    () async {
      final controller = FarmerProfileController(
        verificationRepository: FarmerVerificationRepository(
          customDetailsLoader: () async => details,
        ),
      );
      addTearDown(controller.dispose);
      await controller.loadFollowCounts();
      expect(controller.followCounts.followingCount, 0);
      await controller.loadVerificationDetails();
      expect(controller.verificationDetails, details);
      controller.openEditProfile(returnMode: FarmerProfileMode.settings);
      expect(controller.mode, FarmerProfileMode.edit);
      expect(await controller.saveProfile(profile), isTrue);
      expect(controller.profile, profile);
      expect(controller.mode, FarmerProfileMode.overview);
      expect(controller.returnModeAfterEdit, FarmerProfileMode.settings);
      controller.openEditFarm();
      expect(controller.mode, FarmerProfileMode.editFarm);
      controller.showOverview();
      controller.openEditProfile();
      expect(controller.returnModeAfterEdit, FarmerProfileMode.overview);
      controller.verificationRepository = FarmerVerificationRepository(
        customDetailsLoader: () async => null,
      );
      await controller.loadVerificationDetails();
      expect(controller.verificationDetails, details);
    },
  );

  test(
    'late verification load does not notify a disposed controller',
    () async {
      final pending = Completer<FarmerVerificationDetails?>();
      final controller = FarmerProfileController(
        verificationRepository: FarmerVerificationRepository(
          customDetailsLoader: () => pending.future,
        ),
      );
      final loading = controller.loadVerificationDetails();
      controller.dispose();
      pending.complete(details);
      await loading;
    },
  );

  testWidgets(
    'verification banner and saved profile stay visible in overview',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerProfileScreen(
              verificationRepository: FarmerVerificationRepository(
                customDetailsLoader: () async => details,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FarmerInformationRequestBanner), findsOneWidget);
      final controller = tester
          .widget<FarmerProfileView>(find.byType(FarmerProfileView))
          .controller;
      controller.openEditProfile();
      await tester.pumpAndSettle();
      expect(find.byType(FarmerInformationRequestBanner), findsNothing);
      final editor = tester.widget<FarmerProfileEditCard>(
        find.byType(FarmerProfileEditCard),
      );
      editor.onSave(profile);
      await tester.pumpAndSettle();
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('Profile saved.'), findsOneWidget);
      expect(find.byType(FarmerInformationRequestBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  final destinations = <String, Type>{
    'Customer Reviews & Ratings': FarmerReviewsScreen,
    'Incident History & Status': IncidentTrackingScreen,
    'Customer Support Tickets': SupportCenterScreen,
  };
  for (final entry in destinations.entries) {
    testWidgets('${entry.key} keeps its destination and farmer identity', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const Scaffold(body: FarmerProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final controller = tester
          .widget<FarmerProfileView>(find.byType(FarmerProfileView))
          .controller;
      await controller.saveProfile(profile);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(entry.key),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      if (entry.value == IncidentTrackingScreen) {
        final screen = tester.widget<IncidentTrackingScreen>(
          find.byType(IncidentTrackingScreen),
        );
        expect(screen.role, 'farmer');
        expect(screen.userName, 'Maria Santos');
        expect(screen.userContact, profile.phoneNumber);
        expect(screen.userEmail, profile.email);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
