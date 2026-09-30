import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/screens/farmer_information_request_screen.dart';
import 'package:agresell_app/features/farmer/verification/presentation/widgets/farmer_information_request_banner.dart';

class FakeFarmerCommodityRepository extends FarmerCommodityRepository {
  const FakeFarmerCommodityRepository(this.products);
  final List<FarmerDashboardProduct> products;

  @override
  bool get isAvailable => true;

  @override
  Future<List<FarmerDashboardProduct>> loadProducts() async => products;
}

void main() {
  group('FarmerVerificationDetails Domain', () {
    test('parses information request from json correctly', () {
      final json = {
        'found': true,
        'farmer_user_id': 101,
        'verification_status': 'pending',
        'account_status': 'active',
        'first_name': 'Juan',
        'last_name': 'Dela Cruz',
        'phone_number': '09171234567',
        'farm_id': 50,
        'farm_name': 'Benguet Berry Farm',
        'farm_address': 'La Trinidad',
        'action': 'needs_information',
        'reason': 'Unclear identification document.',
        'message': 'Please submit a clear, unexpired Government ID and proof of farm ownership.',
        'missing_items': ['Government ID', 'Proof of Farm Ownership'],
        'has_information_request': true,
        'request_id': 88,
        'requested_by': 'admin@agrisell.ph',
        'requested_at': '2026-09-19T14:00:00.000Z',
      };

      final details = FarmerVerificationDetails.fromJson(json);

      expect(details.farmerUserId, 101);
      expect(details.isNeedsInformation, isTrue);
      expect(details.isPending, isFalse);
      expect(details.isVerified, isFalse);
      expect(details.hasInformationRequest, isTrue);
      expect(details.requestId, 88);
      expect(details.hasMessage, isTrue);
      expect(details.message, 'Please submit a clear, unexpired Government ID and proof of farm ownership.');
      expect(details.hasMissingItems, isTrue);
      expect(details.missingItems, ['Government ID', 'Proof of Farm Ownership']);
      expect(details.formattedRequestedDate, 'Sep 19, 2026');
    });

    test('parses normal pending details without information request', () {
      final json = {
        'found': true,
        'farmer_user_id': 102,
        'verification_status': 'pending',
        'account_status': 'active',
        'action': null,
        'has_information_request': false,
      };

      final details = FarmerVerificationDetails.fromJson(json);

      expect(details.isNeedsInformation, isFalse);
      expect(details.isPending, isTrue);
      expect(details.isVerified, isFalse);
    });
  });

  group('FarmerInformationRequestBanner Widget', () {
    testWidgets('renders when isNeedsInformation is true and triggers onTap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var tapped = false;
      const details = FarmerVerificationDetails(
        farmerUserId: 101,
        action: 'needs_information',
        message: 'Please provide a clear copy of your Barangay Certification.',
        missingItems: ['Barangay Certification'],
        hasInformationRequest: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerInformationRequestBanner(
              details: details,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action Required: Information Requested'), findsOneWidget);
      expect(find.text('Please provide a clear copy of your Barangay Certification.'), findsOneWidget);
      expect(find.text('Barangay Certification'), findsOneWidget);
      expect(find.text('Review & Resubmit'), findsOneWidget);

      await tester.tap(find.text('Review & Resubmit'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders nothing when isNeedsInformation is false', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const details = FarmerVerificationDetails(
        farmerUserId: 102,
        verificationStatus: 'verified',
        action: 'verified',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerInformationRequestBanner(
              details: details,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action Required: Information Requested'), findsNothing);
    });
  });

  group('FarmerInformationRequestScreen Widget', () {
    testWidgets('displays reviewer feedback and submits corrections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      String? submittedNotes;
      String? submittedFarmName;
      final repo = FarmerVerificationRepository(
        customResubmitHandler: ({
          String? firstName,
          String? lastName,
          String? phoneNumber,
          String? farmName,
          String? farmAddress,
          Uint8List? profileImageBytes,
          Uint8List? farmImageBytes,
          String? notes,
        }) async {
          submittedFarmName = farmName;
          submittedNotes = notes;
        },
      );

      const details = FarmerVerificationDetails(
        farmerUserId: 101,
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        phoneNumber: '09171234567',
        farmName: 'Old Farm Name',
        farmAddress: 'Old Farm Address',
        action: 'needs_information',
        message: 'Please update your farm name and provide an updated note.',
        missingItems: ['Proof of Farm Ownership', 'Updated Farm Name'],
        hasInformationRequest: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: FarmerInformationRequestScreen(
            details: details,
            repository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Guidance & Reviewer Feedback
      expect(find.text('Information Requested'), findsOneWidget);
      expect(find.text('ACTION REQUIRED'), findsOneWidget);
      expect(find.text('NOTE FROM REVIEWER'), findsOneWidget);
      expect(find.text('Please update your farm name and provide an updated note.'), findsOneWidget);
      expect(find.text('MISSING OR REQUESTED ITEMS'), findsOneWidget);
      expect(find.text('Proof of Farm Ownership'), findsOneWidget);
      expect(find.text('Updated Farm Name'), findsOneWidget);

      // Verify Pre-filled Fields
      expect(find.text('Juan'), findsOneWidget);
      expect(find.text('Dela Cruz'), findsOneWidget);
      expect(find.text('Old Farm Name'), findsOneWidget);

      // Enter Updated Farm Name
      final farmNameFinder = find.widgetWithText(TextField, 'Old Farm Name');
      await tester.ensureVisible(farmNameFinder);
      await tester.enterText(farmNameFinder, 'Highland Organic Haven');

      // Enter Note to Reviewer
      final notesFinder = find.byType(TextField).last;
      await tester.ensureVisible(notesFinder);
      await tester.enterText(notesFinder, 'Updated my farm name and verified coordinates.');
      await tester.pumpAndSettle();

      // Submit Corrections
      final submitFinder = find.text('Submit Corrections');
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(submittedFarmName, 'Highland Organic Haven');
      expect(submittedNotes, 'Updated my farm name and verified coordinates.');
    });
  });

  group('FarmerDashboardScreen Integration', () {
    testWidgets('shows information request banner on dashboard when requested', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const details = FarmerVerificationDetails(
        farmerUserId: 101,
        action: 'needs_information',
        message: 'Admin requested updated credentials.',
        missingItems: ['Government ID'],
        hasInformationRequest: true,
      );

      final verificationRepo = FarmerVerificationRepository(
        customDetailsLoader: () async => details,
      );
      final commodityRepo = const FakeFarmerCommodityRepository([]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: FarmerDashboardScreen(
              commodityRepository: commodityRepo,
              verificationRepository: verificationRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action Required: Information Requested'), findsOneWidget);
      expect(find.text('Admin requested updated credentials.'), findsOneWidget);
      expect(find.text('Review & Resubmit'), findsOneWidget);
    });
  });
}
