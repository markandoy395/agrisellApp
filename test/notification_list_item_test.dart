import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_notification_card.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_list_item.dart';

void main() {
  const shortText = 'Your order is being prepared by the farmer.';
  const longText =
      'Your order #ORD-2026-9817 has been accepted by Farmer Juan. The harvest will begin tomorrow at 6:00 AM, and your package will be sanitized and prepared for the delivery rider.';

  group('NotificationListItem text length and expand/collapse', () {
    testWidgets('short description displays full text without arrow down button', (
      tester,
    ) async {
      final item = _createHomeNotification(description: shortText);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: NotificationListItem(
              item: item,
              isRead: false,
              onTap: () {},
              onToggleRead: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text(shortText), findsOneWidget);
      expect(find.byKey(const Key('notification_expand_button')), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });

    testWidgets('long description truncates text and displays all when arrow down is clicked', (
      tester,
    ) async {
      final item = _createHomeNotification(description: longText);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: NotificationListItem(
              item: item,
              isRead: false,
              onTap: () {},
              onToggleRead: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Initially, the full long text is NOT displayed in its entirety
      expect(find.text(longText), findsNothing);
      expect(find.textContaining('...'), findsOneWidget);

      // The arrow down button is present
      final expandButton = find.byKey(const Key('notification_expand_button'));
      expect(expandButton, findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Click the arrow down button
      await tester.tap(expandButton);
      await tester.pumpAndSettle();

      // Now all the text is displayed
      expect(find.text(longText), findsOneWidget);

      // Click the arrow button again to collapse
      await tester.tap(expandButton);
      await tester.pumpAndSettle();

      // Collapses back to truncated text
      expect(find.text(longText), findsNothing);
      expect(find.textContaining('...'), findsOneWidget);
    });
  });

  group('RiderNotificationCard text length and expand/collapse', () {
    testWidgets('short message displays full text without arrow down button', (
      tester,
    ) async {
      final notification = _createRiderNotification(message: shortText);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: RiderNotificationCard(
              notification: notification,
              onTap: () {},
              onToggleRead: () {},
            ),
          ),
        ),
      );

      expect(find.text(shortText), findsOneWidget);
      expect(find.byKey(const Key('rider_notification_expand_button')), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });

    testWidgets('long message truncates text and displays all when arrow down is clicked', (
      tester,
    ) async {
      final notification = _createRiderNotification(message: longText);

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: RiderNotificationCard(
              notification: notification,
              onTap: () {},
              onToggleRead: () {},
            ),
          ),
        ),
      );

      // Initially, full text is not displayed
      expect(find.text(longText), findsNothing);
      expect(find.textContaining('...'), findsOneWidget);

      // Arrow down button is visible
      final expandButton = find.byKey(const Key('rider_notification_expand_button'));
      expect(expandButton, findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Click the arrow down button
      await tester.tap(expandButton);
      await tester.pumpAndSettle();

      // Now all text is displayed
      expect(find.text(longText), findsOneWidget);

      // Click again to collapse
      await tester.tap(expandButton);
      await tester.pumpAndSettle();

      // Collapsed again
      expect(find.text(longText), findsNothing);
      expect(find.textContaining('...'), findsOneWidget);
    });
  });
}

HomeNotification _createHomeNotification({required String description}) =>
    HomeNotification(
      id: 'test-1',
      title: 'Order status update',
      description: description,
      image: '',
      imageLabel: '',
      createdAt: DateTime.now(),
    );

RiderNotification _createRiderNotification({required String message}) =>
    RiderNotification(
      id: 'rider-test-1',
      riderId: 'rider-1',
      type: RiderNotificationType.deliveryRequest,
      title: 'New Delivery Assignment',
      message: message,
      createdAt: DateTime.now(),
    );
