import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_chat_product_context.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_product_thumbnail.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';

void main() {
  testWidgets('chat product context does not substitute a mock image', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatProductThumbnail(
            imageUrl: null,
            size: 44,
            semanticLabel: 'Farm product',
          ),
        ),
      ),
    );

    expect(find.byType(ProductThumbnail), findsNothing);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(
      find.bySemanticsLabel('Farm product image unavailable'),
      findsOneWidget,
    );
  });

  testWidgets('chat product context uses the uploaded image URL', (
    tester,
  ) async {
    const imageUrl = 'https://example.com/product.jpg';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatProductThumbnail(
            imageUrl: imageUrl,
            size: 44,
            semanticLabel: 'Tomato product',
          ),
        ),
      ),
    );

    final thumbnail = tester.widget<ProductThumbnail>(
      find.byType(ProductThumbnail),
    );
    expect(thumbnail.imageUrl, imageUrl);
    expect(thumbnail.asset, isNull);
    expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);
  });

  testWidgets('farm-level buyer chat uses the uploaded farmer photo', (
    tester,
  ) async {
    const imageUrl = 'https://example.com/farmer.jpg';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuyerChatProductContext(
            thread: _conversation(farmerImageUrl: imageUrl),
          ),
        ),
      ),
    );

    final avatarImage = tester.widget<ResponsiveAssetImage>(
      find.descendant(
        of: find.byType(ChatAvatar),
        matching: find.byType(ResponsiveAssetImage),
      ),
    );
    expect(avatarImage.imageUrl, imageUrl);
  });

  testWidgets('farm-level buyer chat shows farmer initials without a photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuyerChatProductContext(thread: _conversation()),
        ),
      ),
    );

    expect(
      find.descendant(of: find.byType(ChatAvatar), matching: find.text('BA')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.storefront_outlined), findsNothing);
  });
}

MarketplaceConversation _conversation({String? farmerImageUrl}) =>
    MarketplaceConversation(
      id: 'farm-chat',
      buyerName: 'Buyer',
      farmerName: 'Ben Andoy',
      farmerImageUrl: farmerImageUrl,
      farmName: 'Markfarm',
      location: 'Lianga',
      lastMessage: '',
      updatedAt: DateTime.utc(2026, 9, 9),
      unreadCount: 0,
    );
