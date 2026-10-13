import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_evidence_capture.dart';

void main() {
  testWidgets('delivery evidence supports camera capture, preview, and retake', (
    tester,
  ) async {
    var captureRequests = 0;
    final bytes = Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RiderDeliveryEvidenceCapture(
              captured: true,
              previewBytes: bytes,
              capturedAt: DateTime(2026, 8, 10, 14, 30),
              location: DeliveryStatusLocation(
                latitude: 8.49,
                longitude: 124.66,
                accuracyMeters: 5,
              ),
              enabled: true,
              onCapture: () => captureRequests++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Retake delivery evidence'), findsOneWidget);
    expect(find.textContaining('GPS 8.49000, 124.66000'), findsOneWidget);
    expect(
      find.text('Captured 2026-08-10 14:30 | GPS 8.49000, 124.66000'),
      findsOneWidget,
    );
    await tester.tap(
      find.bySemanticsLabel('Preview captured delivery evidence'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Close preview'), findsOneWidget);
    await tester.tap(find.text('Close preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retake delivery evidence'));
    expect(captureRequests, 1);
  });
}
