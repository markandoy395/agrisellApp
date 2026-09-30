import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/data/rider_verification_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_application_submitted_screen.dart';

class _FakeRiderVerificationRepository implements RiderVerificationRepository {
  _FakeRiderVerificationRepository(this.details);
  final RiderVerificationDetails details;

  @override
  Future<RiderVerificationDetails> getVerificationDetails({
    String? reference,
  }) async =>
      details;
}

void main() {
  group('RiderVerificationDetails Domain', () {
    test('parses structured rejection details from json', () {
      final json = {
        'found': true,
        'rider_id': 'rider-uuid-123',
        'verification_status': 'rejected',
        'employment_status': 'inactive',
        'action': 'rejected',
        'reason': 'The driver license provided is expired and illegible.',
        'message': 'Please upload a valid, unexpired driver license.',
        'missing_items': ['Government ID', 'Certification or license'],
        'reviewed_at': '2026-09-19T10:30:00.000Z',
        'documents': [
          {
            'document_id': 'doc-1',
            'document_type': 'drivers_license',
            'document_number': 'N01-12-345678',
            'verification_status': 'rejected',
            'rejection_reason': 'License expired on 2025-12-31.',
          },
          {
            'document_id': 'doc-2',
            'document_type': 'vehicle_or',
            'document_number': 'OR-998877',
            'verification_status': 'verified',
            'rejection_reason': null,
          },
        ],
      };

      final details = RiderVerificationDetails.fromJson(json);

      expect(details.reference, 'rider-uuid-123');
      expect(details.verificationStatus, RiderVerificationStatus.rejected);
      expect(details.isRejected, isTrue);
      expect(details.isPending, isFalse);
      expect(details.isNeedsInformation, isFalse);
      expect(details.hasRejectionReason, isTrue);
      expect(
        details.reason,
        'The driver license provided is expired and illegible.',
      );
      expect(details.hasMessage, isTrue);
      expect(
        details.message,
        'Please upload a valid, unexpired driver license.',
      );
      expect(details.hasMissingItems, isTrue);
      expect(details.missingItems, [
        'Government ID',
        'Certification or license',
      ]);
      expect(details.hasRejectedDocuments, isTrue);
      expect(details.rejectedDocuments.length, 1);
      expect(
        details.rejectedDocuments.first.documentType,
        RiderDocumentType.driversLicense,
      );
      expect(
        details.rejectedDocuments.first.rejectionReason,
        'License expired on 2025-12-31.',
      );
    });

    test('parses needs_information action correctly', () {
      final json = {
        'found': true,
        'rider_id': 'rider-uuid-456',
        'verification_status': 'pending',
        'action': 'needs_information',
        'reason': null,
        'message':
            'Please update your vehicle plate number and provide proof of address.',
        'missing_items': [
          'Proof of address or farm',
          'Farm or vehicle details',
        ],
        'documents': [],
      };

      final details = RiderVerificationDetails.fromJson(json);

      expect(details.isNeedsInformation, isTrue);
      expect(details.isRejected, isFalse);
      expect(details.isPending, isFalse);
      expect(details.hasMessage, isTrue);
      expect(details.hasMissingItems, isTrue);
      expect(details.missingItems, [
        'Proof of address or farm',
        'Farm or vehicle details',
      ]);
    });
  });

  group('RiderApplicationStatusScreen Widget', () {
    testWidgets('renders pending state cleanly', (tester) async {
      const details = RiderVerificationDetails(
        reference: 'REF-PENDING-001',
        verificationStatus: RiderVerificationStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RiderApplicationStatusScreen(
            reference: 'REF-PENDING-001',
            initialDetails: details,
            repository: _FakeRiderVerificationRepository(details),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Application status'), findsOneWidget);
      expect(find.text('REF-PENDING-001'), findsOneWidget);
      expect(find.text('Pending verification'), findsOneWidget);
      expect(
        find.text('Your information and documents are waiting for review.'),
        findsOneWidget,
      );
      expect(find.text('What happens next?'), findsOneWidget);
      expect(find.text('ADMIN REVIEW FEEDBACK'), findsNothing);
      expect(find.text('DOCUMENT FEEDBACK'), findsNothing);
    });

    testWidgets('renders rejected state with admin rejection reason', (
      tester,
    ) async {
      final details = RiderVerificationDetails(
        reference: 'REF-REJECTED-002',
        verificationStatus: RiderVerificationStatus.rejected,
        action: 'rejected',
        reason:
            'Background check indicates suspended license. Application denied.',
        reviewedAt: DateTime(2026, 9, 19, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RiderApplicationStatusScreen(
            reference: 'REF-REJECTED-002',
            initialDetails: details,
            repository: _FakeRiderVerificationRepository(details),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Application not approved'), findsOneWidget);
      expect(find.text('ADMIN REVIEW FEEDBACK'), findsOneWidget);
      expect(find.text('REJECTION REASON'), findsOneWidget);
      expect(
        find.text(
          'Background check indicates suspended license. Application denied.',
        ),
        findsOneWidget,
      );
      expect(find.text('Need assistance?'), findsOneWidget);
    });

    testWidgets(
      'renders needs_information state with reviewer note and checklist',
      (tester) async {
        const details = RiderVerificationDetails(
          reference: 'REF-NEEDS-INFO-003',
          verificationStatus: RiderVerificationStatus.pending,
          action: 'needs_information',
          message:
              'Please submit a clearer photo of your Government ID and update vehicle info.',
          missingItems: ['Government ID', 'Farm or vehicle details'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RiderApplicationStatusScreen(
              reference: 'REF-NEEDS-INFO-003',
              initialDetails: details,
              repository: _FakeRiderVerificationRepository(details),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Information requested'), findsOneWidget);
        expect(find.text('ADMIN REVIEW FEEDBACK'), findsOneWidget);
        expect(find.text('NOTE FROM REVIEWER'), findsOneWidget);
        expect(
          find.text(
            'Please submit a clearer photo of your Government ID and update vehicle info.',
          ),
          findsOneWidget,
        );
        expect(find.text('MISSING OR REQUESTED ITEMS'), findsOneWidget);
        expect(find.text('Government ID'), findsOneWidget);
        expect(find.text('Farm or vehicle details'), findsOneWidget);
        expect(find.text('What should I do now?'), findsOneWidget);
      },
    );

    testWidgets(
      'renders document feedback card with rejected document reasons',
      (tester) async {
        const details = RiderVerificationDetails(
          reference: 'REF-DOCS-004',
          verificationStatus: RiderVerificationStatus.pending,
          action: 'needs_information',
          message: 'Please review the rejected documents below.',
          documents: [
            RiderVerificationDocumentItem(
              documentId: 'd-1',
              documentType: RiderDocumentType.driversLicense,
              documentNumber: 'LIC-12345',
              verificationStatus: RiderDocumentVerificationStatus.rejected,
              rejectionReason:
                  'Driver license is blurred and text cannot be read.',
            ),
            RiderVerificationDocumentItem(
              documentId: 'd-2',
              documentType: RiderDocumentType.vehicleOr,
              documentNumber: 'OR-67890',
              verificationStatus: RiderDocumentVerificationStatus.rejected,
              rejectionReason:
                  'Official Receipt is expired. Provide current year OR.',
            ),
            RiderVerificationDocumentItem(
              documentId: 'd-3',
              documentType: RiderDocumentType.profileSelfie,
              verificationStatus: RiderDocumentVerificationStatus.verified,
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RiderApplicationStatusScreen(
              reference: 'REF-DOCS-004',
              initialDetails: details,
              repository: _FakeRiderVerificationRepository(details),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('DOCUMENT FEEDBACK'), findsOneWidget);
        expect(find.text("Driver's License"), findsOneWidget);
        expect(find.text('Number: LIC-12345'), findsOneWidget);
        expect(
          find.text('Driver license is blurred and text cannot be read.'),
          findsOneWidget,
        );
        expect(find.text('Vehicle Official Receipt (OR)'), findsOneWidget);
        expect(find.text('Number: OR-67890'), findsOneWidget);
        expect(
          find.text('Official Receipt is expired. Provide current year OR.'),
          findsOneWidget,
        );
        expect(find.text('Profile Photo / Selfie'), findsNothing);
      },
    );
  });
}
