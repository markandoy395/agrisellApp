import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_detail_header.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_profile_intro.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  for (final role in [
    MarketplaceActorRole.buyer,
    MarketplaceActorRole.farmer,
  ]) {
    testWidgets(
      '${role.name} switches from profile introduction to active header',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 740));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repository = FakeMarketplaceMessagingRepository(
          actorRole: role,
          conversations: [
            marketplaceConversationFixture(
              location: 'Purok 4, San Jose, La Trinidad, Benguet',
            ),
          ],
          messages: {'12': []},
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: role == MarketplaceActorRole.buyer
                  ? BuyerMessageScreen(
                      repository: repository,
                      autoRefreshInterval: Duration.zero,
                      chatBottomPadding: 12,
                    )
                  : FarmerMessageScreen(
                      repository: repository,
                      autoRefreshInterval: Duration.zero,
                    ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final name = role == MarketplaceActorRole.buyer
            ? 'Maria Santos'
            : 'Alex Buyer';
        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Open chat with $name',
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ChatProfileIntro), findsOneWidget);
        if (role == MarketplaceActorRole.buyer) {
          expect(
            tester
                .widget<ChatProfileIntro>(find.byType(ChatProfileIntro))
                .subtitle,
            'Purok 4, San Jose, La Trinidad, Benguet',
          );
        }
        expect(
          tester
              .widget<ChatDetailHeader>(find.byType(ChatDetailHeader))
              .isEmpty,
          isTrue,
        );
        await tester.tap(find.text('Hello!'));
        await tester.pumpAndSettle();
        expect(repository.sentTexts, ['Hello!']);
        expect(find.byType(ChatProfileIntro), findsNothing);
        if (role == MarketplaceActorRole.buyer) {
          expect(
            tester
                .widget<ChatDetailHeader>(find.byType(ChatDetailHeader))
                .subtitle,
            'Purok 4, San Jose, La Trinidad, Benguet',
          );
        }
        expect(
          tester
              .widget<ChatDetailHeader>(find.byType(ChatDetailHeader))
              .isEmpty,
          isFalse,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
