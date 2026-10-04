import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_home_screen.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
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
    expect(find.text('Benguet'), findsOneWidget);
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

  testWidgets('buyer composer stays above the main navigation safe area', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: HomeScreen(
          initialNavIndex: HomeScreen.messageNavIndex,
          messagingRepository: FakeMarketplaceMessagingRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_semanticsLabel('Open chat with Maria Santos'));
    await tester.pumpAndSettle();

    final composer = tester.getRect(
      find.widgetWithText(TextField, 'Write a message'),
    );
    final navigation = tester.getRect(find.byType(CustomBottomNavBar));
    expect(composer.bottom, lessThanOrEqualTo(navigation.top));
    expect(navigation.top - composer.bottom, lessThanOrEqualTo(32));
    expect(tester.takeException(), isNull);
  });

  for (final bottomInset in [0.0, 24.0]) {
    testWidgets(
      'farmer reply has space above navigation (inset $bottomInset)',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 696);
        tester.view.padding = FakeViewPadding(bottom: bottomInset);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
          tester.view.resetPadding();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: FarmerHomeScreen(
              initialNavIndex: FarmerHomeScreen.messageNavIndex,
              messagingRepository: FakeMarketplaceMessagingRepository(
                actorRole: MarketplaceActorRole.farmer,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(_semanticsLabel('Open chat with Alex Buyer'));
        await tester.pumpAndSettle();

        final replyField = tester.getRect(
          find.widgetWithText(TextField, 'Type a reply'),
        );
        final navigation = tester.getRect(find.byType(CustomBottomNavBar));
        final sendButton = tester.getRect(find.byTooltip('Send message'));
        expect(navigation.top - replyField.bottom, greaterThanOrEqualTo(24));
        expect(sendButton.bottom, lessThanOrEqualTo(navigation.top - 24));
        expect(tester.takeException(), isNull);
      },
    );
  }
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
