import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/chat/data/rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/styles/rider_messaging_design_styles.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_chat_panel.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_message_composer.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_messages_header.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_messages_inbox.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_messages_status.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'support/memory_offline_queue_repository.dart';

const _access = RiderConversationAccess(
  activeDeliveryIds: {'d1'},
  supportAuthorized: true,
);
const _farm = RiderConversation(
  id: 'farm',
  participantLabel: 'Dela Cruz Farm',
  party: RiderConversationParty.seller,
  deliveryId: 'd1',
  riderId: 'r1',
  unreadCount: 2,
  lastMessagePreview: 'Ready for pickup',
);
const _support = RiderConversation(
  id: 'support',
  participantLabel: 'AgriSell Support',
  party: RiderConversationParty.support,
  riderId: 'r1',
  supportAuthorized: true,
);

Future<RiderMessagesController> _controller() async {
  final queue = RiderOfflineActionQueue(
    repository: MemoryOfflineQueueRepository(),
  );
  final controller = RiderMessagesController(
    offlineQueue: queue,
    repository: InMemoryRiderMessageRepository(
      access: _access,
      conversations: [_farm, _support],
    ),
  );
  addTearDown(controller.dispose);
  addTearDown(queue.dispose);
  await controller.load(riderId: 'r1', access: _access);
  return controller;
}

void main() {
  setUpAll(() async {
    final font = FontLoader('Poppins');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      font.addFont(rootBundle.load('assets/fonts/Poppins/Poppins-$weight.ttf'));
    }
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets(
    'inbox searches, filters, opens authorized rows and keeps header fixed',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = await _controller();
      var notifications = 0;
      RiderConversation? opened;
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            backgroundColor: RiderMessagingDesignStyles.background,
            body: RepaintBoundary(
              key: boundary,
              child: ColoredBox(
                color: RiderMessagingDesignStyles.background,
                child: Column(
                  children: [
                    RiderMessagesHeader(
                      onNotifications: () => notifications++,
                      unreadCount: 3,
                    ),
                    Expanded(
                      child: RiderMessagesInbox(
                        controller: controller,
                        onOpen: (value) => opened = value,
                        onRetry: () async {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('All 2'), findsOneWidget);
      expect(find.text('Unread 1'), findsOneWidget);
      await tester.tap(find.byTooltip('Notifications'));
      expect(notifications, 1);
      await tester.tap(find.text('Unread 1'));
      await tester.pumpAndSettle();
      expect(find.text('AgriSell Support'), findsNothing);
      await tester.tap(find.text('Dela Cruz Farm'));
      expect(opened?.id, 'farm');
      await tester.tap(find.text('Support'));
      await tester.pumpAndSettle();
      expect(find.text('Dela Cruz Farm'), findsNothing);
      expect(find.text('AgriSell Support'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'missing');
      await tester.pump();
      expect(find.text('No delivery conversations'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('All 2'));
      await tester.pumpAndSettle();
      final header = tester.getTopLeft(find.text('Messages'));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Messages')), header);
      await _capture(tester, boundary, 'inbox');
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 430.0]) {
    testWidgets('text-only chat and confirmed quick replies at $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = await _controller();
      await controller.selectConversation(_farm);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: RepaintBoundary(key: boundary, child: child!),
          ),
          home: RiderConversationPanel(
            controller: controller,
            quickReplies: RiderQuickReply.defaults,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Attach photo'), findsNothing);
      expect(find.byIcon(Icons.attach_file), findsNothing);
      expect(find.text('Share location'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Text delivery update');
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(controller.messages.single.body, 'Text delivery update');
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(-800, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quick replies'));
      await tester.pumpAndSettle();
      expect(controller.messages.length, 1);
      final sendQuickReply = find.widgetWithText(
        FilledButton,
        'Send quick reply',
      );
      expect(tester.getSize(sendQuickReply).height, greaterThanOrEqualTo(52));
      final onMyWay = find.widgetWithText(OutlinedButton, 'On my way').last;
      expect(tester.getSize(onMyWay).height, greaterThanOrEqualTo(58));
      await _capture(tester, boundary, 'quick_replies_${width.toInt()}');
      await tester.tap(find.text('Send quick reply'));
      await tester.pumpAndSettle();
      expect(controller.messages.last.body, 'I am on the way.');
      expect(
        controller.messages.every(
          (m) =>
              m.kind == RiderMessageKind.text && m.attachmentReference == null,
        ),
        isTrue,
      );
      await _capture(tester, boundary, 'chat_${width.toInt()}');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.byType(RiderMessageComposer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'composer keeps failed draft and prevents duplicate submissions',
    (tester) async {
      final result = Completer<bool>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiderMessageComposer(
              enabled: true,
              isSending: false,
              onSend: (_) {
                calls++;
                return result.future;
              },
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Keep this text');
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pump();
      await tester.tap(find.byTooltip('Send message'));
      expect(calls, 1);
      result.complete(false);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Keep this text',
      );
    },
  );

  testWidgets(
    'pending summary hides unauthorized conversations and retries failed text',
    (tester) async {
      final queue = RiderOfflineActionQueue(
        repository: MemoryOfflineQueueRepository(),
      );
      final controller = RiderMessagesController(
        offlineQueue: queue,
        repository: InMemoryRiderMessageRepository(
          access: _access,
          conversations: [_farm],
        ),
      );
      addTearDown(queue.dispose);
      addTearDown(controller.dispose);
      await controller.load(riderId: 'r1', access: _access);
      await controller.selectConversation(_farm);
      controller.setBackendReachable(false);
      await controller.send('Please confirm pickup.');
      final action = queue.actions.single;
      await queue.update(
        action.copyWith(status: OfflineDeliveryActionStatus.failed),
      );
      await queue.add(
        riderId: 'r1',
        deliveryId: 'unauthorized',
        type: OfflineDeliveryActionType.message,
        payload: {
          'conversationId': 'other',
          'body': 'Hidden private draft',
          'kind': 'text',
        },
        originalTimestamp: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => RiderMessagesStatus(
                controller: controller,
                onRetry: () async {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('Please confirm pickup.'), findsOneWidget);
      expect(find.text('Hidden private draft'), findsNothing);
      controller.setBackendReachable(true);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(controller.pendingTextMessages, isEmpty);
      expect(controller.messages.last.body, 'Please confirm pickup.');
    },
  );
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/rider_message_previews')
      ..createSync(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
