import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/widgets/review_report_appeal_sheet.dart';

void main() {
  final testReview = FarmerReview(
    id: 'rev-101',
    orderId: 42,
    clientOrderId: 'ORD-999',
    commodityId: 5,
    commodityName: 'Organic Carrots',
    rating: 2.0,
    comment: 'Damaged during delivery',
    createdAt: DateTime(2026, 9, 20),
    buyerName: 'Alice Farmer',
  );

  testWidgets(
    'renders report mode and submits reason with details',
    (tester) async {
      String? submittedReason;
      String? submittedDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ReviewReportAppealSheet.show(
                  context,
                  review: testReview,
                  actionType: 'report',
                  onSubmit: ({required reason, details}) async {
                    submittedReason = reason;
                    submittedDetails = details;
                    return true;
                  },
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Report Review'), findsOneWidget);
      expect(find.text('Submit Report'), findsOneWidget);
      expect(
        find.text('Flag abusive or malicious customer feedback'),
        findsOneWidget,
      );
      expect(find.text('Organic Carrots'), findsOneWidget);
      expect(find.text('By Alice Farmer • ORD-999'), findsOneWidget);
      expect(find.text('"Damaged during delivery"'), findsOneWidget);
      expect(find.text('Select Reason for Reporting'), findsOneWidget);
      expect(find.text('Additional Context (Optional)'), findsOneWidget);

      // Pick a different reason
      await tester.tap(find.text(FarmerReview.reportReasons[1]));
      await tester.pumpAndSettle();

      // Enter details
      await tester.enterText(
        find.byType(TextField),
        'Violates marketplace rules',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Report'));
      await tester.pumpAndSettle();

      expect(submittedReason, FarmerReview.reportReasons[1]);
      expect(submittedDetails, 'Violates marketplace rules');
      // Sheet should be popped
      expect(find.text('Select Reason for Reporting'), findsNothing);
    },
  );

  testWidgets('renders appeal mode and handles error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ReviewReportAppealSheet.show(
                context,
                review: testReview,
                actionType: 'appeal',
                onSubmit: ({required reason, details}) async {
                  return false;
                },
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Appeal Moderation'), findsOneWidget);
    expect(find.text('Submit Appeal'), findsOneWidget);
    expect(
      find.text('Request administrator review for penalties'),
      findsOneWidget,
    );
    expect(find.text('Select Grounds for Appeal'), findsOneWidget);
    expect(find.text('Appeal Statement & Explanation'), findsOneWidget);

    // Tap submit -> fails -> error banner
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Appeal'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Unable to submit appeal. Please check your connection and try again.',
      ),
      findsOneWidget,
    );
  });
}
