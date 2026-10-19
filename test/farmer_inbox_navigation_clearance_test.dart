import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_home_screen.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_conversation_tile.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_inbox_body.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  for (final bottomInset in [0.0, 24.0]) {
    testWidgets('last farmer chat clears navigation with inset $bottomInset', (
      tester,
    ) async {
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
              conversations: [
                for (var index = 0; index < 30; index++)
                  marketplaceConversationFixture(id: '$index').copyWith(
                    lastMessage: 'Latest reply in conversation $index',
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final list = find.descendant(
        of: find.byType(ChatInboxBody),
        matching: find.byType(ListView),
      );
      final navigation = tester.getRect(find.byType(CustomBottomNavBar));
      expect(tester.getRect(list).bottom, lessThanOrEqualTo(navigation.top));

      final scrollable = find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      final lastTile = find.byWidgetPredicate(
        (widget) =>
            widget is ChatConversationTile &&
            widget.data.previewText == 'Latest reply in conversation 29',
      );
      expect(lastTile, findsOneWidget);
      final bounds = tester.getRect(lastTile);
      expect(bounds.top, greaterThanOrEqualTo(tester.getRect(list).top));
      expect(bounds.bottom, lessThanOrEqualTo(navigation.top));
      expect(lastTile.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
