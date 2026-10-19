import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/controllers/farmer_rider_assignment_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_order_details_screen.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/delivery_waybill_sheet.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_html_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeliveryWaybill model', () {
    test('fromFarmerOrder extracts complete waybill details for COD order', () {
      final order = PlacedOrder(
        id: '101',
        buyerName: 'Maria Santos',
        phoneNumber: '09171234567',
        deliveryAddress: 'Brgy 1, Malaybalay City, Bukidnon',
        status: PlacedOrderStatus.readyForPickup,
        placedAt: DateTime.utc(2026, 8, 10, 8, 30),
        items: const [
          PlacedOrderItem(
            productId: 'prod-1',
            productName: 'Fresh Cabbage',
            image: '',
            sellerName: 'Bukidnon Highlands Farm',
            pricePerKg: 45.0,
            unit: 'kg',
            quantity: 10,
          ),
          PlacedOrderItem(
            productId: 'prod-2',
            productName: 'Red Tomatoes',
            image: '',
            sellerName: 'Bukidnon Highlands Farm',
            pricePerKg: 60.0,
            unit: 'kg',
            quantity: 5,
          ),
        ],
        payment: const OrderPayment.cashOnDelivery(),
      );

      final waybill = DeliveryWaybill.fromFarmerOrder(
        order,
        farmerContact: '09189876543',
        pickupAddress: 'Highlands Farm, Malaybalay',
      );

      expect(waybill.orderId, '101');
      expect(waybill.waybillNumber, 'WB-101');
      expect(waybill.buyerName, 'Maria Santos');
      expect(waybill.buyerContact, '09171234567');
      expect(waybill.deliveryAddress, 'Brgy 1, Malaybalay City, Bukidnon');
      expect(waybill.sellerName, 'Bukidnon Highlands Farm');
      expect(waybill.pickupAddress, 'Highlands Farm, Malaybalay');
      expect(waybill.pickupContact, '09189876543');
      expect(waybill.courierName, 'Unassigned');
      expect(waybill.isCod, isTrue);
      expect(waybill.codAmount, 750.0);
      expect(waybill.totalAmount, 750.0);
      expect(waybill.items.length, 2);
      expect(waybill.items.first.name, 'Fresh Cabbage');
      expect(waybill.items.first.quantity, 10);
      expect(waybill.items.first.unitPrice, 45.0);
      expect(waybill.items.first.total, 450.0);
    });

    test('fromFarmerOrder captures assigned rider request info', () {
      final order = PlacedOrder(
        id: '102',
        buyerName: 'Carlos D.',
        phoneNumber: '09221112222',
        deliveryAddress: 'Valencia City Center',
        status: PlacedOrderStatus.readyForPickup,
        placedAt: DateTime.utc(2026, 8, 12, 10, 0),
        items: const [
          PlacedOrderItem(
            productId: 'prod-3',
            productName: 'Sweet Corn',
            image: '',
            sellerName: 'Sunny Farm',
            pricePerKg: 30.0,
            unit: 'kg',
            quantity: 20,
          ),
        ],
      );

      final riderRequest = FarmerRiderRequest(
        id: 'req-1',
        deliveryId: 'del-1',
        orderId: '102',
        riderId: 'rider-55',
        riderName: 'Pedro Penduko',
        riderBarangay: 'Poblacion',
        riderMunicipality: 'Valencia City',
        status: RiderAssignmentRequestStatus.accepted,
        requestedSchedule: DateTime.utc(2026, 8, 12, 14, 0),
        requestedAt: DateTime.utc(2026, 8, 12, 10, 30),
        expiresAt: DateTime.utc(2026, 8, 12, 11, 30),
      );

      final waybill = DeliveryWaybill.fromFarmerOrder(
        order,
        riderRequest: riderRequest,
      );

      expect(waybill.courierName, 'Pedro Penduko');
      expect(waybill.courierContact, 'Poblacion, Valencia City');
    });

    test('fromRiderDelivery extracts delivery request fields', () {
      final request = DeliveryRequest(
        id: 'del-201',
        orderNumber: 'ORD-201',
        productName: 'Organic Carrots',
        sellerName: 'Green Valley',
        buyerName: 'Elena Reyes',
        pickupLocation: const DeliveryLocation(
          address: 'Impasugong, Bukidnon',
          contactNumber: '09334445555',
          latitude: 8.3,
          longitude: 125.0,
        ),
        deliveryLocation: const DeliveryLocation(
          address: 'Cagayan de Oro City',
          contactNumber: '09445556666',
          latitude: 8.48,
          longitude: 124.65,
        ),
        pickupDeadline: DateTime.utc(2026, 8, 15, 12, 0),
        deliveryFee: 150.0,
        cashOnDelivery: const CashOnDeliveryRequirement(
          amountToCollect: 650.0,
          currencyCode: 'PHP',
        ),
        pickupInstructions: 'Gate 2 near warehouse',
        deliveryInstructions: 'Leave with guard if unavailable',
      );

      final waybill = DeliveryWaybill.fromRiderDelivery(
        request,
        riderName: 'Juan Rider',
        riderContact: '09778889999',
      );

      expect(waybill.orderId, 'ORD-201');
      expect(waybill.waybillNumber, 'WB-ORD-201');
      expect(waybill.buyerName, 'Elena Reyes');
      expect(waybill.buyerContact, '09445556666');
      expect(waybill.sellerName, 'Green Valley');
      expect(waybill.pickupAddress, 'Impasugong, Bukidnon');
      expect(waybill.courierName, 'Juan Rider');
      expect(waybill.courierContact, '09778889999');
      expect(waybill.isCod, isTrue);
      expect(waybill.codAmount, 650.0);
      expect(waybill.instructions, contains('Gate 2 near warehouse'));
      expect(waybill.instructions, contains('Leave with guard'));
    });
  });

  group('WaybillHtmlService', () {
    test('generateHtml produces complete waybill with all sections', () async {
      final waybill = DeliveryWaybill(
        orderId: '500',
        waybillNumber: 'WB-500',
        buyerName: 'Ana Gomez',
        buyerContact: '09123456789',
        deliveryAddress: 'Poblacion, Malaybalay City',
        sellerName: 'Golden Fields Farm',
        pickupAddress: 'Golden Fields, Dalwangan',
        pickupContact: '09987654321',
        courierName: 'Lito Logistics',
        courierContact: '09556667777',
        schedule: '2026-08-20 14:00',
        paymentMethod: 'GCASH',
        paymentStatus: 'VERIFIED',
        totalAmount: 1200.0,
        isCod: false,
        items: const [
          DeliveryWaybillItem(
            name: 'Fresh Strawberries',
            quantity: 4,
            unit: 'punnets',
            unitPrice: 300.0,
            total: 1200.0,
          ),
        ],
        instructions: 'Handle with care - fragile fruit',
      );

      final html = await WaybillHtmlService.generateHtml(waybill);

      expect(html, contains('AgriSell Delivery Waybill'));
      expect(html, contains('ORD-500'));
      expect(html, contains('WB-500'));
      expect(html, contains('Ana Gomez'));
      expect(html, contains('09123456789'));
      expect(html, contains('Golden Fields Farm'));
      expect(html, contains('Golden Fields, Dalwangan'));
      expect(html, contains('Lito Logistics'));
      expect(html, contains('Fresh Strawberries'));
      expect(html, contains('PHP 1200.00'));
      expect(html, contains('PREPAID'));
      expect(html, contains('Handle with care'));
      expect(html, contains('window.print()'));
      final stylesheet = RegExp('href="([^"]+)"').firstMatch(html)!.group(1)!;
      expect(
        Uri.parse(stylesheet).data!.contentAsString(),
        contains('@media print'),
      );
    });

    test('formatPlainText formats plain text summary correctly', () {
      final waybill = DeliveryWaybill(
        orderId: '501',
        waybillNumber: 'WB-501',
        buyerName: 'Ben Santos',
        buyerContact: '09112223333',
        deliveryAddress: 'Sayre Highway, Valencia',
        sellerName: 'Bukidnon Farm',
        pickupAddress: 'Brgy 5, Valencia',
        pickupContact: '',
        courierName: 'Express Rider',
        courierContact: '09445556666',
        schedule: '2026-08-21 09:30',
        paymentMethod: 'CASH ON DELIVERY',
        paymentStatus: 'COLLECT ON DELIVERY',
        totalAmount: 450.0,
        isCod: true,
        codAmount: 450.0,
        items: const [
          DeliveryWaybillItem(
            name: 'Lettuce',
            quantity: 3,
            unit: 'kg',
            unitPrice: 150.0,
            total: 450.0,
          ),
        ],
      );

      final text = WaybillHtmlService.formatPlainText(waybill);

      expect(text, contains('AGRISELL DELIVERY WAYBILL'));
      expect(text, contains('WB-501'));
      expect(text, contains('ORD-501'));
      expect(text, contains('Ben Santos'));
      expect(text, contains('Sayre Highway, Valencia'));
      expect(text, contains('Bukidnon Farm'));
      expect(text, contains('Express Rider'));
      expect(text, contains('COLLECT COD: PHP 450.00'));
      expect(text, contains('TOTAL: PHP 450.00'));
    });
  });

  group('DeliveryWaybillSheet widget', () {
    testWidgets('renders all waybill details and buttons', (tester) async {
      final waybill = DeliveryWaybill(
        orderId: '600',
        waybillNumber: 'WB-600',
        buyerName: 'Clara Oswald',
        buyerContact: '09990001111',
        deliveryAddress: 'Barangay 9, Malaybalay',
        sellerName: 'Oswald Farms',
        pickupAddress: 'Farm Road 1',
        pickupContact: '09887776666',
        courierName: 'Rider Ace',
        courierContact: '09112223333',
        schedule: '2026-08-25 15:00',
        paymentMethod: 'GCASH',
        paymentStatus: 'VERIFIED',
        totalAmount: 880.0,
        items: const [
          DeliveryWaybillItem(
            name: 'Bell Peppers',
            quantity: 4,
            unit: 'kg',
            unitPrice: 220.0,
            total: 880.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryWaybillSheet(waybill: waybill)),
        ),
      );

      expect(find.text('Delivery Waybill'), findsOneWidget);
      expect(find.byKey(const Key('waybill-preview-card')), findsOneWidget);
      expect(find.text('WB-600'), findsOneWidget);
      expect(find.text('Order ORD-600'), findsOneWidget);
      expect(find.text('Clara Oswald'), findsOneWidget);
      expect(find.text('Rider Ace'), findsOneWidget);
      expect(find.text('Oswald Farms'), findsOneWidget);
      expect(find.text('Bell Peppers (4 kg)'), findsOneWidget);
      expect(find.text('PHP 880.00'), findsWidgets);
      expect(find.byKey(const Key('waybill-print-button')), findsOneWidget);
      expect(find.byKey(const Key('waybill-download-button')), findsOneWidget);
      expect(find.byKey(const Key('waybill-copy-button')), findsOneWidget);
    });
  });

  group('Screen integration', () {
    testWidgets(
      'FarmerOrderDetailsScreen displays print waybill actions and opens sheet',
      (tester) async {
        final order = PlacedOrder(
          id: '701',
          buyerName: 'David Lee',
          phoneNumber: '09551234567',
          deliveryAddress: 'Central Market, Malaybalay',
          status: PlacedOrderStatus.readyForPickup,
          placedAt: DateTime.utc(2026, 8, 28),
          items: const [
            PlacedOrderItem(
              productId: 'p-1',
              productName: 'Carrots',
              image: '',
              sellerName: 'Lee Vegetable Farm',
              pricePerKg: 50,
              unit: 'kg',
              quantity: 10,
            ),
          ],
        );

        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final orderRepository = OrderLocalRepository(preferences: preferences);
        await orderRepository.save('farmer-1', [order]);
        final orderController = OrderController(repository: orderRepository);
        await orderController.loadForAccount('farmer-1');

        final riderController = FarmerRiderAssignmentController(
          const UnavailableFarmerRiderSelectionRepository(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: FarmerOrderDetailsScreen(
              order: order,
              controller: orderController,
              riderController: riderController,
              onChooseRider: (_) async {},
              onCancelRiderRequest: (_) async {},
              onCancelOrder: (_) async {},
            ),
          ),
        );

        expect(
          find.byKey(const Key('farmer-print-waybill-appbar-button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('farmer-open-waybill-button')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const Key('farmer-print-waybill-appbar-button')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('waybill-preview-card')), findsOneWidget);
        expect(find.text('WB-701'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('waybill-preview-card')),
            matching: find.text('David Lee'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'RiderDeliveryDetailsScreen includes waybill action in quick actions and header',
      (tester) async {
        final request = DeliveryRequest(
          id: 'del-801',
          orderNumber: 'ORD-801',
          productName: 'Organic Potatoes',
          sellerName: 'Potato Farm',
          buyerName: 'Grace Hopper',
          pickupLocation: const DeliveryLocation(
            address: 'Manolo Fortich',
            contactNumber: '09123456789',
            latitude: 8.37,
            longitude: 124.86,
          ),
          deliveryLocation: const DeliveryLocation(
            address: 'CDO City',
            contactNumber: '09987654321',
            latitude: 8.48,
            longitude: 124.65,
          ),
          pickupDeadline: DateTime.utc(2026, 9, 1),
          deliveryFee: 120.0,
        );

        final repository = InMemoryRiderDeliveryRepository(requests: [request]);
        final controller = RiderDeliveryController(repository: repository);

        await tester.pumpWidget(
          MaterialApp(
            home: RiderDeliveryDetailsScreen(
              request: request,
              controller: controller,
              riderId: 'rider-1',
            ),
          ),
        );

        expect(
          find.byKey(const Key('rider-print-waybill-button')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('rider-print-waybill-button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('waybill-preview-card')), findsOneWidget);
        expect(find.text('WB-ORD-801'), findsOneWidget);
        expect(find.text('Grace Hopper'), findsOneWidget);
      },
    );
  });
}
