import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/message_filter_tabs.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_conversation_tile.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_inbox_body.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/marketplace_message_inbox.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  testWidgets('scrolling farmer chats stays below the fixed filters', (
    tester,
  ) async {
    await _pumpInbox(tester, MarketplaceActorRole.farmer, [
      for (var index = 0; index < 30; index++)
        marketplaceConversationFixture(id: '$index').copyWith(
          lastMessage: 'Conversation $index: pickup tomorrow morning.',
        ),
    ]);
    final filters = find.byType(MessageFilterTabs);
    final body = find.byType(ChatInboxBody);
    final list = find.descendant(of: body, matching: find.byType(ListView));
    final filterBounds = tester.getRect(filters);
    final listBounds = tester.getRect(list);
    expect(listBounds.top - filterBounds.bottom, greaterThanOrEqualTo(12));
    final clip = find.ancestor(of: body, matching: find.byType(ClipRect)).first;
    expect(tester.getRect(clip), listBounds);

    await tester.drag(list, const Offset(0, -247));
    await tester.pumpAndSettle();
    expect(tester.getRect(filters), filterBounds);
    expect(tester.getRect(list), listBounds);
    final scrollable = find.descendant(
      of: list,
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      greaterThan(0),
    );
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MessageFilterTabs>(filters).activeFilter,
      FarmerMessageFilter.unread,
    );
    expect(tester.takeException(), isNull);
  });

  for (final role in MarketplaceActorRole.values) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('${role.name} preview fits compact screen at $scale', (
        tester,
      ) async {
        const preview = 'Pickup at 9 AM.';
        final thread = marketplaceConversationFixture().copyWith(
          lastMessage: preview,
        );
        await _pumpInbox(tester, role, [thread], scale: scale);

        expect(find.byType(MarketplaceMessageInbox), findsOneWidget);
        final tile = tester.widget<ChatConversationTile>(
          find.byType(ChatConversationTile),
        );
        expect(
          tile.data.participant.name,
          role == MarketplaceActorRole.buyer ? 'Maria Santos' : 'Alex Buyer',
        );
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(preview),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          tester
              .renderObject<RenderParagraph>(find.text(thread.timeLabel))
              .didExceedMaxLines,
          isFalse,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('${role.name} shows latest reply after returning to list', (
      tester,
    ) async {
      final repository = await _pumpInbox(tester, role, [
        marketplaceConversationFixture(),
      ]);
      await tester.tap(find.byType(ChatConversationTile));
      await tester.pumpAndSettle();
      final hint = role == MarketplaceActorRole.buyer
          ? 'Write a message'
          : 'Type a reply';
      await tester.enterText(
        find.widgetWithText(TextField, hint),
        'See you soon',
      );
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back to messages'));
      await tester.pumpAndSettle();

      expect(repository.sentTexts, ['See you soon']);
      expect(find.text('See you soon'), findsOneWidget);
      expect(find.byType(MarketplaceMessageInbox), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('farmer filters and searches the shared conversation list', (
    tester,
  ) async {
    await _pumpInbox(tester, MarketplaceActorRole.farmer, [
      marketplaceConversationFixture(),
      marketplaceConversationFixture(
        id: '13',
        unreadCount: 0,
      ).copyWith(lastMessage: 'Already read'),
    ]);
    expect(find.byType(ChatConversationTile), findsNWidgets(2));
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatConversationTile), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Search buyers or products'),
      'no matching buyer',
    );
    await tester.pumpAndSettle();
    expect(find.byType(ChatConversationTile), findsNothing);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatConversationTile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<FakeMarketplaceMessagingRepository> _pumpInbox(
  WidgetTester tester,
  MarketplaceActorRole role,
  List<MarketplaceConversation> threads, {
  double scale = 1,
}) async {
  await tester.binding.setSurfaceSize(const Size(320, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repository = FakeMarketplaceMessagingRepository(
    actorRole: role,
    conversations: threads,
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: role == MarketplaceActorRole.buyer
            ? BuyerMessageScreen(
                repository: repository,
                autoRefreshInterval: Duration.zero,
              )
            : FarmerMessageScreen(
                repository: repository,
                autoRefreshInterval: Duration.zero,
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
