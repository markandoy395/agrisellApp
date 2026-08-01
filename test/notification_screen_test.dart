import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_load_state.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/notification_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/screens/notification_screen.dart';

void main() {
  test('notification controller supports read, unread, delete, and clear', () {
    final controller = NotificationController();
    addTearDown(controller.dispose);
    final first = _notification(id: 'first', title: 'First update');
    final second = _notification(id: 'second', title: 'Second update');

    expect(controller.isRead(first), isFalse);
    controller.markRead(first);
    expect(controller.isRead(first), isTrue);
    controller.markUnread(first);
    expect(controller.isRead(first), isFalse);

    controller.delete(first);
    expect(controller.isDeleted(first), isTrue);
    controller.clear([second]);
    expect(controller.isDeleted(second), isTrue);
  });

  testWidgets('filters notifications by role and category, then opens it', (
    tester,
  ) async {
    HomeNotification? opened;
    final controller = NotificationController();
    addTearDown(controller.dispose);
    final notifications = [
      _notification(
        id: 'buyer-order',
        title: 'Buyer order',
        visibleTo: const {AuthRole.buyer},
      ),
      _notification(
        id: 'buyer-message',
        title: 'Buyer message',
        type: HomeNotificationType.newMessage,
        category: NotificationCategory.messages,
        destination: HomeNotificationDestination.messages,
        visibleTo: const {AuthRole.buyer},
      ),
      _notification(
        id: 'farmer-order',
        title: 'Farmer order',
        visibleTo: const {AuthRole.farmer},
      ),
    ];

    await _pumpScreen(
      tester,
      NotificationScreen(
        role: AuthRole.buyer,
        notifications: notifications,
        controller: controller,
        onNotificationSelected: (item) => opened = item,
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Buyer order'), findsOneWidget);
    expect(find.text('Buyer message'), findsOneWidget);
    expect(find.text('Farmer order'), findsNothing);

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Buyer order'), findsNothing);
    expect(find.text('Buyer message'), findsOneWidget);

    await tester.tap(find.text('Buyer message'));
    await tester.pumpAndSettle();
    expect(opened?.id, 'buyer-message');
    expect(controller.isRead(notifications[1]), isTrue);
  });

  testWidgets('deletes a notification with the card menu', (tester) async {
    final controller = NotificationController();
    addTearDown(controller.dispose);
    await _pumpScreen(
      tester,
      NotificationScreen(
        notifications: [_notification(id: 'delete-me', title: 'Delete me')],
        controller: controller,
      ),
    );

    await tester.tap(find.byTooltip('Options for Delete me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsNothing);
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('reports unread count changes for the navigation badge', (
    tester,
  ) async {
    final unreadCounts = <int>[];
    await _pumpScreen(
      tester,
      NotificationScreen(
        notifications: [_notification(id: 'badge-alert', title: 'Badge alert')],
        onUnreadCountChanged: unreadCounts.add,
      ),
    );

    expect(unreadCounts, [1]);
    await tester.tap(find.text('Badge alert'));
    await tester.pumpAndSettle();

    expect(unreadCounts, [1, 0]);
  });

  testWidgets('shows loading, offline, error, and empty states', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      const NotificationScreen(loadState: NotificationLoadState.loading),
    );
    expect(find.text('Loading notifications'), findsOneWidget);

    await _pumpScreen(
      tester,
      const NotificationScreen(loadState: NotificationLoadState.offline),
    );
    expect(find.text('You are offline'), findsOneWidget);

    await _pumpScreen(
      tester,
      const NotificationScreen(loadState: NotificationLoadState.error),
    );
    expect(find.text('Notifications unavailable'), findsOneWidget);

    await _pumpScreen(tester, const NotificationScreen());
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('repository failure is visible and retry loads notifications', (
    tester,
  ) async {
    final notification = _notification(
      id: 'retry-success',
      title: 'Loaded after retry',
    );
    final repository = _RetryingNotificationRepository(notification);

    await _pumpScreen(
      tester,
      NotificationScreen(userId: 'buyer-1', repository: repository),
    );

    expect(find.text('Notifications unavailable'), findsOneWidget);
    expect(find.textContaining('notification query failed'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Loaded after retry'), findsOneWidget);
    expect(repository.attempts, 2);
  });
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      home: Scaffold(body: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

HomeNotification _notification({
  required String id,
  required String title,
  HomeNotificationType type = HomeNotificationType.orderConfirmed,
  NotificationCategory category = NotificationCategory.orders,
  HomeNotificationDestination destination = HomeNotificationDestination.orders,
  Set<AuthRole> visibleTo = const {AuthRole.buyer},
}) => HomeNotification(
  id: id,
  title: title,
  description: 'A concise notification description.',
  image: '',
  imageLabel: '',
  createdAt: DateTime.now(),
  type: type,
  category: category,
  destination: destination,
  visibleTo: visibleTo,
);

class _RetryingNotificationRepository extends HomeNotificationRepository {
  _RetryingNotificationRepository(this.notification);

  final HomeNotification notification;
  var attempts = 0;

  @override
  Stream<List<HomeNotification>> watchForUser(String? userId) {
    attempts++;
    if (attempts == 1) {
      return Stream.error(Exception('notification query failed'));
    }
    return Stream.value([notification]);
  }
}
