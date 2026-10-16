import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_filter_tabs.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_state_view.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/screens/notification_screen.dart';
import 'package:agresell_app/features/rider/chat/data/rider_notification_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_notifications_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/screens/rider_notifications_screen.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(640, 240),
    const Size(280, 240),
  ]) {
    testWidgets('notification feed scrolls at $size with large text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pump(
        tester,
        NotificationScreen(
          notifications: [
            for (var i = 0; i < 8; i++)
              HomeNotification(
                id: 'notice-$i',
                title: 'Order update $i',
                description: 'Your order is ready for collection.',
                image: '',
                imageLabel: '',
                createdAt: DateTime.now(),
              ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Notification').hitTestable(), findsNothing);
      for (
        var attempt = 0;
        attempt < 100 &&
            find.text('Order update 7').hitTestable().evaluate().isEmpty;
        attempt++
      ) {
        await tester.drag(find.byType(NestedScrollView), const Offset(0, -120));
        await tester.pumpAndSettle();
      }
      expect(find.text('Order update 7').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('filter strip grows and reveals the selected tab', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(280, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var filter = NotificationFilter.all;
    late StateSetter update;
    await _pump(
      tester,
      Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Align(
              alignment: Alignment.topCenter,
              child: NotificationFilterTabs(
                selected: filter,
                onSelected: (value) => setState(() => filter = value),
              ),
            );
          },
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(NotificationFilterTabs)).height,
      greaterThan(50),
    );
    update(() => filter = NotificationFilter.values.last);
    await tester.pumpAndSettle();
    expect(find.text(filter.label).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retry stays reachable in a short state view', (tester) async {
    await tester.binding.setSurfaceSize(const Size(280, 140));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var retried = false;
    await _pump(
      tester,
      Scaffold(
        body: NotificationStateView(
          icon: Icons.wifi_off,
          title: 'You are offline',
          message: 'Reconnect to receive your latest notifications.',
          actionLabel: 'Try again',
          onAction: () => retried = true,
        ),
      ),
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rider feed fits a short landscape viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = RiderNotificationsController(
      repository: InMemoryRiderNotificationRepository(
        notifications: [
          RiderNotification(
            id: 'rider-notice',
            riderId: 'r1',
            type: RiderNotificationType.deliveryRequest,
            title: 'New delivery nearby',
            message: 'A new delivery is available.',
            createdAt: DateTime.now(),
          ),
        ],
      ),
    );
    addTearDown(controller.dispose);
    await _pump(
      tester,
      RiderNotificationsScreen(riderId: 'r1', controller: controller),
    );
    await tester.drag(find.byType(NestedScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('New delivery nearby').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(2)),
        child: child!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
