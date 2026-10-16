import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/delivery_waybill_sheet.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/waybill_preview_card.dart';

void main() {
  for (final width in [280.0, 320.0, 414.0, 800.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('waybill preview fits width=$width text=$scale', (
        tester,
      ) async {
        _size(tester, Size(width, 700));
        await _pump(
          tester,
          scale,
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: WaybillPreviewCard(waybill: _waybill()),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        for (final paragraph in tester.renderObjectList<RenderParagraph>(
          find.byType(Text),
        )) {
          expect(paragraph.didExceedMaxLines, isFalse);
        }
        expect(find.text('CASH ON DELIVERY'), findsOneWidget);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -10000),
        );
        await tester.pumpAndSettle();
        expect(find.text('Total Amount').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final size in [const Size(320, 640), const Size(640, 360)]) {
    testWidgets('waybill sheet fits $size with enlarged text', (tester) async {
      _size(tester, size);
      await _pump(
        tester,
        1.5,
        Align(
          alignment: Alignment.bottomCenter,
          child: DeliveryWaybillSheet(waybill: _waybill()),
        ),
      );
      expect(
        find.byKey(const Key('waybill-print-button')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pump(WidgetTester tester, double scale, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

DeliveryWaybill _waybill() => DeliveryWaybill(
  orderId: 'Order #76 with a long identifier',
  waybillNumber: 'WB-Order-76-12345678901234567890',
  buyerName: 'Buyer with a long full name',
  buyerContact: '09123456789',
  deliveryAddress: 'A long delivery address in a distant barangay',
  sellerName: 'Farm',
  pickupAddress: 'Pickup address',
  pickupContact: '09987654321',
  courierName: 'Rider',
  courierContact: '09123456789',
  schedule: 'Tomorrow',
  paymentMethod: 'Cash on delivery',
  paymentStatus: 'Pending',
  totalAmount: 12345678.90,
  isCod: true,
  codAmount: 12345678.90,
  items: const [
    DeliveryWaybillItem(
      name: 'Fresh produce with a long product name',
      quantity: 123,
      unit: 'baskets',
      unitPrice: 100000,
      total: 12345678.90,
    ),
  ],
);
