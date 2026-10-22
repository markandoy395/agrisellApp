import 'dart:async';

import 'package:agresell_app/core/services/notification_permission_gateway.dart';
import 'package:agresell_app/core/widgets/notification_permission_benefit.dart';
import 'package:agresell_app/core/widgets/notification_permission_card.dart';
import 'package:agresell_app/core/widgets/notification_permission_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePermissionGateway implements NotificationPermissionGateway {
  var state = NotificationPermissionState.requestable;
  var result = NotificationPermissionState.enabled;
  var offered = false;
  var requests = 0;
  var settingsOpened = 0;
  var settingsAvailable = true;
  Completer<void>? requestCompleter;

  @override
  Future<NotificationPermissionState> read() async => state;
  @override
  Future<bool> hasOffered() async => offered;
  @override
  Future<void> markOffered() async => offered = true;
  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return settingsAvailable;
  }

  @override
  Future<NotificationPermissionState> request() async {
    requests++;
    await requestCompleter?.future;
    return state = result;
  }
}

void main() {
  late FakePermissionGateway gateway;
  late BuildContext hostContext;
  var enabledCount = 0;

  setUp(() {
    gateway = FakePermissionGateway();
    enabledCount = 0;
  });

  Future<void> pumpHost(WidgetTester tester, {bool card = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              hostContext = context;
              return card
                  ? SingleChildScrollView(
                      child: NotificationPermissionCard(
                        gateway: gateway,
                        benefit: NotificationPermissionBenefit.buyer,
                        onEnabled: () async {
                          enabledCount++;
                        },
                      ),
                    )
                  : const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> offer(WidgetTester tester, {bool automatic = true}) async {
    unawaited(
      NotificationPermissionPrompt.offer(
        hostContext,
        benefit: NotificationPermissionBenefit.buyer,
        gateway: gateway,
        automatic: automatic,
        onEnabled: () async {
          enabledCount++;
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loading the notification card never requests OS permission', (
    tester,
  ) async {
    await pumpHost(tester, card: true);
    expect(find.text('Know when your order is on its way'), findsOneWidget);
    expect(find.text('Turn on notifications'), findsOneWidget);
    expect(gateway.requests, 0);
    expect(gateway.offered, false);
  });

  testWidgets('enabling from the card registers exactly once', (tester) async {
    await pumpHost(tester, card: true);
    await tester.tap(find.text('Turn on notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();
    expect(gateway.requests, 1);
    expect(enabledCount, 1);
    expect(find.byType(NotificationPermissionCard), findsOneWidget);
    expect(find.text('Turn on notifications'), findsNothing);
  });

  testWidgets(
    'Not now preserves OS permission and suppresses later automatic offers',
    (tester) async {
      await pumpHost(tester);
      await offer(tester);
      expect(gateway.requests, 0);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(gateway.state, NotificationPermissionState.requestable);
      expect(gateway.requests, 0);
      await offer(tester);
      expect(find.byType(AlertDialog), findsNothing);
      // A deliberate later action still opens the pre-permission explanation.
      await offer(tester, automatic: false);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Turn on requests once and registers alerts only after approval',
    (tester) async {
      await pumpHost(tester);
      await offer(tester);
      expect(enabledCount, 0);
      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();
      expect(gateway.requests, 1);
      expect(enabledCount, 1);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'denial shows Settings recovery without another permission request',
    (tester) async {
      gateway.result = NotificationPermissionState.blocked;
      await pumpHost(tester);
      await offer(tester);
      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();
      expect(find.text('Notifications are off'), findsOneWidget);
      expect(enabledCount, 0);
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();
      expect(gateway.settingsOpened, 1);
      expect(gateway.requests, 1);
      gateway.state = NotificationPermissionState.enabled;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(enabledCount, 1);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('only one dialog and system request may be active', (
    tester,
  ) async {
    gateway.requestCompleter = Completer<void>();
    await pumpHost(tester);
    await offer(tester);
    await offer(tester, automatic: false);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Turn on'));
    await tester.pump();
    expect(gateway.requests, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    gateway.requestCompleter!.complete();
    await tester.pumpAndSettle();
    expect(enabledCount, 1);
  });

  testWidgets(
    'blocked card opens Settings in one tap and refreshes on return',
    (tester) async {
      gateway.state = NotificationPermissionState.blocked;
      await pumpHost(tester, card: true);
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();
      expect(gateway.settingsOpened, 1);
      expect(gateway.requests, 0);
      gateway.state = NotificationPermissionState.enabled;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Notifications are off'), findsNothing);
      expect(enabledCount, 1);
    },
  );

  testWidgets('failed Settings link provides manual recovery directions', (
    tester,
  ) async {
    gateway.state = NotificationPermissionState.blocked;
    gateway.settingsAvailable = false;
    await pumpHost(tester, card: true);
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();
    expect(
      find.text('Open device Settings > Apps > AgriSell > Notifications.'),
      findsOneWidget,
    );
    expect(gateway.requests, 0);
  });

  testWidgets(
    'unavailable and already enabled permissions never show an offer',
    (tester) async {
      await pumpHost(tester);
      for (final state in [
        NotificationPermissionState.unavailable,
        NotificationPermissionState.enabled,
      ]) {
        gateway.state = state;
        await offer(tester);
        expect(find.byType(AlertDialog), findsNothing);
      }
      expect(gateway.requests, 0);
    },
  );

  testWidgets('benefit card and dialog fit narrow screens with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(280, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHost(tester, card: true);
    expect(tester.takeException(), isNull);
    await offer(tester);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Not now'));
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
  });
}
