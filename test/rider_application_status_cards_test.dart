import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';
import 'package:agresell_app/features/rider/profile/presentation/utils/rider_application_status_content.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_application_status_cards.dart';

void main() {
  testWidgets('reference remains selectable', (tester) async {
    await tester.pumpWidget(
      _host(const RiderApplicationReferenceCard(reference: 'REF-123')),
    );
    expect(find.text('APPLICATION REFERENCE'), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      'REF-123',
    );
  });

  testWidgets('status cards preserve fallbacks, precedence, and review dates', (
    tester,
  ) async {
    final cases = [
      (
        true,
        null,
        'Pending verification',
        AgrisellColors.statusOrangeBackground,
      ),
      (
        false,
        null,
        'Application not approved',
        AgrisellColors.statusRedBackground,
      ),
      (
        false,
        _details(),
        'Pending verification',
        AgrisellColors.statusOrangeBackground,
      ),
      (
        true,
        _details(status: RiderVerificationStatus.rejected),
        'Application not approved',
        AgrisellColors.statusRedBackground,
      ),
      (
        true,
        _details(
          status: RiderVerificationStatus.rejected,
          action: 'needs_information',
        ),
        'Information requested',
        AgrisellColors.statusOrangeBackground,
      ),
      (
        true,
        _details(
          status: RiderVerificationStatus.verified,
          action: 'needs_information',
        ),
        'Application approved',
        AgrisellColors.statusGreenBackground,
      ),
    ];
    for (final (pending, details, title, background) in cases) {
      await tester.pumpWidget(
        _host(RiderApplicationStatusCard(isPending: pending, details: details)),
      );
      expect(find.text(title), findsOneWidget);
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(RiderApplicationStatusCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((container.decoration! as BoxDecoration).color, background);
      expect(find.textContaining('Reviewed on'), findsNothing);
    }
    await tester.pumpWidget(
      _host(
        RiderApplicationStatusCard(
          details: _details(reviewedAt: DateTime(2026, 9, 19, 13, 5)),
        ),
      ),
    );
    expect(find.text('Reviewed on Sep 19, 2026 at 1:05 PM'), findsOneWidget);
  });

  testWidgets('next steps retain independent information-request precedence', (
    tester,
  ) async {
    final cases = [
      (true, null, 'What happens next?'),
      (false, null, 'Need assistance?'),
      (false, _details(), 'What happens next?'),
      (
        true,
        _details(status: RiderVerificationStatus.verified),
        'What happens next?',
      ),
      (
        true,
        _details(status: RiderVerificationStatus.rejected),
        'Need assistance?',
      ),
      (
        true,
        _details(
          status: RiderVerificationStatus.verified,
          action: 'needs_information',
        ),
        'What should I do now?',
      ),
    ];
    for (final (pending, details, title) in cases) {
      await tester.pumpWidget(
        _host(
          RiderApplicationNextStepsCard(isPending: pending, details: details),
        ),
      );
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('feedback sections remain conditional and keep their order', (
    tester,
  ) async {
    for (var mask = 0; mask < 8; mask++) {
      final reason = mask & 1 != 0;
      final note = mask & 2 != 0;
      final missing = mask & 4 != 0;
      await tester.pumpWidget(
        _host(
          RiderVerificationFeedbackCard(
            details: _details(
              reason: reason ? 'Expired license' : '   ',
              message: note ? 'Upload a clear copy' : '\n',
              missing: missing ? ['Government ID', 'Vehicle OR'] : [],
            ),
          ),
        ),
      );
      expect(
        find.text('ADMIN REVIEW FEEDBACK'),
        mask == 0 ? findsNothing : findsOneWidget,
      );
      expect(
        find.text('REJECTION REASON'),
        reason ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('NOTE FROM REVIEWER'),
        note ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('MISSING OR REQUESTED ITEMS'),
        missing ? findsOneWidget : findsNothing,
      );
      if (missing) {
        expect(find.text('Government ID'), findsOneWidget);
        expect(find.text('Vehicle OR'), findsOneWidget);
      }
      if (mask == 7) {
        expect(
          tester.getTopLeft(find.text('REJECTION REASON')).dy,
          lessThan(tester.getTopLeft(find.text('NOTE FROM REVIEWER')).dy),
        );
        expect(
          tester.getTopLeft(find.text('NOTE FROM REVIEWER')).dy,
          lessThan(
            tester.getTopLeft(find.text('MISSING OR REQUESTED ITEMS')).dy,
          ),
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('document feedback filters documents and optional metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(RiderRejectedDocumentsCard(details: _details())),
    );
    expect(find.text('DOCUMENT FEEDBACK'), findsNothing);
    final details = RiderVerificationDetails(
      reference: 'REF-123',
      verificationStatus: RiderVerificationStatus.pending,
      documents: const [
        RiderVerificationDocumentItem(
          documentId: '1',
          documentType: RiderDocumentType.validId,
          rejectionReason: 'Image is unclear',
          documentNumber: 'ID-42',
        ),
        RiderVerificationDocumentItem(
          documentId: '2',
          documentType: RiderDocumentType.driversLicense,
          verificationStatus: RiderDocumentVerificationStatus.rejected,
          documentNumber: '',
          rejectionReason: '   ',
        ),
        RiderVerificationDocumentItem(
          documentId: '3',
          documentType: RiderDocumentType.vehiclePhoto,
          verificationStatus: RiderDocumentVerificationStatus.verified,
        ),
      ],
    );
    await tester.pumpWidget(
      _host(RiderRejectedDocumentsCard(details: details)),
    );
    expect(find.text('DOCUMENT FEEDBACK'), findsOneWidget);
    expect(find.text('Government-Issued ID'), findsOneWidget);
    expect(find.text("Driver's License"), findsOneWidget);
    expect(find.text('Vehicle Photo'), findsNothing);
    expect(find.text('Rejected'), findsNWidgets(2));
    expect(find.text('Number: ID-42'), findsOneWidget);
    expect(find.text('Number: '), findsNothing);
    expect(find.text('Image is unclear'), findsOneWidget);
    expect(find.text('   '), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('review timestamps keep midnight, noon, and padded minutes', () {
    expect(
      formatRiderReviewDate(DateTime(2026, 1, 1, 0, 3)),
      'Jan 1, 2026 at 12:03 AM',
    );
    expect(
      formatRiderReviewDate(DateTime(2026, 12, 31, 12)),
      'Dec 31, 2026 at 12:00 PM',
    );
    expect(
      formatRiderReviewDate(DateTime(2026, 9, 19, 23, 9)),
      'Sep 19, 2026 at 11:09 PM',
    );
  });
}

RiderVerificationDetails _details({
  RiderVerificationStatus status = RiderVerificationStatus.pending,
  String? action,
  String? reason,
  String? message,
  List<String> missing = const [],
  DateTime? reviewedAt,
}) => RiderVerificationDetails(
  reference: 'REF-123',
  verificationStatus: status,
  action: action,
  reason: reason,
  message: message,
  missingItems: missing,
  reviewedAt: reviewedAt,
);

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
