import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_suggestions_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_suggestion_card.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';

class BasketSuggestionGrid extends StatelessWidget {
  const BasketSuggestionGrid({
    required this.suggestions,
    required this.catalogController,
    super.key,
  });

  final List<HomeProduct> suggestions;
  final HomeProductCatalogController catalogController;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = BasketSuggestionsStyles.cardWidthForScreenWidth(screenWidth);

    return SizedBox(
      height: BasketSuggestionsStyles.gridHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(
          width: BasketSuggestionsStyles.itemSpacing,
        ),
        itemBuilder: (context, index) => SizedBox(
          width: cardWidth,
          child: BasketSuggestionCard(
            product: suggestions[index],
            catalogController: catalogController,
          ),
        ),
      ),
    );
  }
}
