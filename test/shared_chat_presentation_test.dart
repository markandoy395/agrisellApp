import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_conversation_tile.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_inbox_header.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_composer.dart';

void main() {
  test('shared timestamp and initials formatting remain stable', () {
    final clock = DateTime(2026, 8, 1, 14);

    expect(marketplaceTimeLabel(DateTime(2026, 8, 1, 13, 5), clock), '1:05 PM');
    expect(
      marketplaceTimeLabel(DateTime(2026, 7, 31, 13, 5), clock),
      '7/31/2026',
    );
    expect(marketplaceInitials('Maria Dela Cruz'), 'MC');
  });

  testWidgets('shared inbox header preserves search and clear behavior', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final queries = <String>[];

    await _pump(
      tester,
      ChatInboxHeader(
        title: 'Chats',
        searchHint: 'Search people or products',
        controller: controller,
        onQueryChanged: queries.add,
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Search people or products'),
      'Tomatoes',
    );
    await tester.pump();
    expect(queries, ['Tomatoes']);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(queries, ['Tomatoes', '']);
  });

  testWidgets('shared conversation tile preserves avatar, unread, and tap', (
    tester,
  ) async {
    var tapped = false;
    await _pump(
      tester,
      ChatConversationTile(
        data: const ChatConversationTileData(
          participant: ChatParticipantData(
            name: 'Maria Santos',
            initials: 'MS',
            imageSemanticLabel: 'Maria Santos profile photo',
          ),
          previewText: 'Fresh tomatoes are available.',
          timeLabel: '8:00 AM',
          hasUnread: true,
          semanticLabel: 'Open chat with Maria Santos',
        ),
        onTap: () => tapped = true,
      ),
    );

    expect(find.text('MS'), findsOneWidget);
    expect(find.text('Fresh tomatoes are available.'), findsOneWidget);
    expect(find.text('8:00 AM'), findsOneWidget);
    final conversation = _semanticsLabel('Open chat with Maria Santos');
    expect(conversation, findsOneWidget);

    await tester.tap(conversation);
    expect(tapped, isTrue);
  });

  testWidgets('shared message bubble exposes failure and retry semantics', (
    tester,
  ) async {
    var retries = 0;
    final message = MarketplaceMessage(
      id: 'failed-1',
      senderRole: MarketplaceActorRole.farmer,
      text: 'Please try this reply again.',
      sentAt: DateTime.utc(2026, 8, 1, 8),
      state: MarketplaceMessageState.failed,
    );

    await _pump(
      tester,
      ChatMessageBubble(
        message: message,
        currentActorRole: MarketplaceActorRole.farmer,
        onRetry: () => retries++,
      ),
    );

    expect(find.text('Not sent - Tap to retry'), findsOneWidget);
    final retry = _semanticsLabel('Message failed. Tap to retry.');
    expect(retry, findsOneWidget);
    await tester.tap(retry);
    expect(retries, 1);
  });

  testWidgets('shared composer preserves labels and send callback', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var sends = 0;

    await _pump(
      tester,
      ChatMessageComposer(
        controller: controller,
        onSend: () => sends++,
        style: const ChatMessageComposerStyle(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: AgrisellColors.surface),
          hintText: 'Write a message',
          inputDecoration: InputDecoration(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Write a message'),
      'Hello',
    );
    await tester.tap(find.byTooltip('Send message'));
    expect(sends, 1);
  });

  testWidgets('shared content states retain accessible loading labels', (
    tester,
  ) async {
    await _pump(
      tester,
      const ChatLoadingState(semanticLabel: 'Loading conversations'),
    );

    expect(find.bySemanticsLabel('Loading conversations'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pump();
}

Finder _semanticsLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);
