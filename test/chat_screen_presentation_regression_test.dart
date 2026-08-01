import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  testWidgets('buyer inbox and conversation retain presentation contract', (
    tester,
  ) async {
    final repository = FakeMarketplaceMessagingRepository();
    await _pump(
      tester,
      BuyerMessageScreen(
        repository: repository,
        autoRefreshInterval: Duration.zero,
        chatBottomPadding: 10,
      ),
    );

    expect(find.byKey(const ValueKey('buyer-message-inbox')), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Search farmers or products'),
      findsOneWidget,
    );
    final conversation = _semanticsLabel('Open chat with Maria Santos');
    expect(conversation, findsOneWidget);

    await tester.tap(conversation);
    await tester.pumpAndSettle();
    expect(find.text('Green Farm'), findsOneWidget);
    expect(find.byTooltip('Back to messages'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Write a message'), findsOneWidget);
  });

  testWidgets('farmer inbox and conversation retain presentation contract', (
    tester,
  ) async {
    final repository = FakeMarketplaceMessagingRepository(
      actorRole: MarketplaceActorRole.farmer,
    );
    await _pump(
      tester,
      FarmerMessageScreen(
        repository: repository,
        autoRefreshInterval: Duration.zero,
      ),
    );

    expect(find.byKey(const ValueKey('message-inbox')), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Search buyers or products'),
      findsOneWidget,
    );
    expect(_semanticsLabel('All messages'), findsOneWidget);
    final conversation = _semanticsLabel('Open chat with Alex Buyer');
    expect(conversation, findsOneWidget);

    await tester.tap(conversation);
    await tester.pumpAndSettle();
    expect(find.text('Alex Buyer'), findsOneWidget);
    expect(find.byTooltip('Back to messages'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Type a reply'), findsOneWidget);
  });
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

Finder _semanticsLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);
