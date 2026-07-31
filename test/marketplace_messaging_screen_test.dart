import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/buyer/chat/presentation/buyer_conversation_launcher.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_home_screen.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_tab.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  testWidgets('buyer loads a thread and persists a sent message', (
    tester,
  ) async {
    final repository = FakeMarketplaceMessagingRepository();
    await _pump(
      tester,
      BuyerMessageScreen(repository: repository, chatBottomPadding: 10),
    );

    expect(find.text('Maria Santos'), findsOneWidget);
    await tester.tap(find.text('Maria Santos'));
    await tester.pumpAndSettle();
    expect(find.text('Hello buyer'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Write a message'),
      'Is this fresh?',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(repository.sentTexts, ['Is this fresh?']);
    expect(find.text('Is this fresh?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('farmer loads a buyer thread and persists a reply', (
    tester,
  ) async {
    final repository = FakeMarketplaceMessagingRepository(
      actorRole: MarketplaceActorRole.farmer,
    );
    await _pump(tester, FarmerMessageScreen(repository: repository));

    expect(find.text('Alex Buyer'), findsOneWidget);
    await tester.tap(find.text('Alex Buyer'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Type a reply'),
      'Yes, harvested today.',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(repository.sentTexts, ['Yes, harvested today.']);
    expect(find.text('Yes, harvested today.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buyer inbox exposes an error state with retry', (tester) async {
    final repository = FakeMarketplaceMessagingRepository()..failLoad = true;
    await _pump(tester, BuyerMessageScreen(repository: repository));

    expect(find.text('Messages are unavailable'), findsOneWidget);
    repository.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Maria Santos'), findsOneWidget);
    expect(repository.loadCalls, 2);
  });

  testWidgets('public launcher resolves a commodity conversation and closes', (
    tester,
  ) async {
    final repository = FakeMarketplaceMessagingRepository();
    await _pump(
      tester,
      Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => unawaited(
              BuyerConversationLauncher.open(
                context,
                sellerName: 'Maria Santos',
                commodityId: '8',
                clientOrderId: 'ORD-100',
                productName: 'Tomatoes',
                repository: repository,
              ),
            ),
            child: const Text('Launch chat'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Launch chat'));
    await tester.pumpAndSettle();
    expect(repository.startCalls.single.commodityId, '8');
    expect(find.text('Hello buyer'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to messages'));
    await tester.pumpAndSettle();
    expect(find.text('Launch chat'), findsOneWidget);
  });

  testWidgets('buyer home badge follows persisted unread and mark-read state', (
    tester,
  ) async {
    final repository = FakeMarketplaceMessagingRepository();
    await _pump(tester, HomeScreen(messagingRepository: repository));

    expect(_messageTab(tester).badgeCount, 1);
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(_messageTab(tester).badgeCount, 1);

    await tester.tap(find.text('Maria Santos'));
    await tester.pumpAndSettle();
    expect(_messageTab(tester).badgeCount, 0);
  });

  testWidgets(
    'farmer home badge follows persisted unread and mark-read state',
    (tester) async {
      final repository = FakeMarketplaceMessagingRepository(
        actorRole: MarketplaceActorRole.farmer,
      );
      await _pump(
        tester,
        FarmerHomeScreen(
          initialNavIndex: FarmerHomeScreen.messageNavIndex,
          messagingRepository: repository,
        ),
      );

      expect(_messageTab(tester).badgeCount, 1);
      await tester.tap(find.text('Alex Buyer'));
      await tester.pumpAndSettle();
      expect(_messageTab(tester).badgeCount, 0);
    },
  );
}

CustomBottomNavTab _messageTab(WidgetTester tester) {
  return tester.widget<CustomBottomNavTab>(
    find.byWidgetPredicate(
      (widget) =>
          widget is CustomBottomNavTab && widget.item.label == 'Messages',
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
