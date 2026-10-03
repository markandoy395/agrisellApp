import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_suggestions_styles.dart';

class BasketSuggestionLabel extends StatelessWidget {
  const BasketSuggestionLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: BasketSuggestionsStyles.labelIconContainerSize,
          height: BasketSuggestionsStyles.labelIconContainerSize,
          decoration: BasketSuggestionsStyles.labelIconDecoration,
          child: const Icon(
            Icons.eco_outlined,
            color: BasketSuggestionsStyles.iconColor,
            size: BasketSuggestionsStyles.labelIconSize,
          ),
        ),
        const SizedBox(width: BasketSuggestionsStyles.iconToTextGap),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You may also like',
                style: BasketSuggestionsStyles.headerTitle,
              ),
              SizedBox(height: BasketSuggestionsStyles.titleSubtitleGap),
              Text(
                'More fresh picks from local farmers',
                style: BasketSuggestionsStyles.headerSubtitle,
              ),
            ],
          ),
        ),
        const Padding(
          padding: BasketSuggestionsStyles.swipeIconPadding,
          child: Icon(
            Icons.swipe_left_rounded,
            color: BasketSuggestionsStyles.mutedIconColor,
            size: BasketSuggestionsStyles.swipeIconSize,
          ),
        ),
      ],
    );
  }
}
