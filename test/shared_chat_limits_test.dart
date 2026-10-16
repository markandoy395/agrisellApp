import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/chat/domain/chat_limits.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_field.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  test('length matches database Unicode code point counts', () {
    expect(ChatLimits.valid('😀' * 500), isTrue);
    expect(ChatLimits.valid('😀' * 501), isFalse);
    expect(ChatLimits.valid(' ' * 500), isFalse);
    expect(ChatLimits.length('a\u0301'), 2);
  });
  for (final role in [
    MarketplaceActorRole.buyer,
    MarketplaceActorRole.farmer,
  ]) {
    test(
      '$role blocks long programmatic and retry sends before persistence',
      () async {
        final controller = MarketplaceMessagingController(
          repository: FakeMarketplaceMessagingRepository(),
          actorRole: role,
        );
        addTearDown(controller.dispose);
        await controller.load();
        expect(await controller.sendMessage('12', 'x' * 501), isFalse);
        expect(controller.messageErrorFor('12'), ChatLimits.lengthError);
        expect(await controller.sendMessage('12', '😀' * 500), isTrue);
      },
    );
  }
  testWidgets(
    'shared field enforces the limit, shows counter, and gates keyboard send',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var sends = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: ChatMessageField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Message'),
              onSend: () => sends++,
            ),
          ),
        ),
      );
      expect(find.text('0/500'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'x' * 500);
      await tester.pump();
      expect(find.text('500/500'), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      expect(sends, 1);
      await tester.enterText(find.byType(TextField), 'x' * 501);
      expect(controller.text.length, 500);
      controller.text = 'x' * 501; // Also guard programmatic/controller edits.
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.send);
      expect(sends, 1);
    },
  );
}
