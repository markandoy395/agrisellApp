import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_suggestions_styles.dart';

class BasketSuggestionStateView extends StatelessWidget {
  const BasketSuggestionStateView({
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    padding: BasketSuggestionsStyles.statePadding,
    decoration: BasketSuggestionsStyles.stateDecoration,
    child: Row(
      children: [
        if (isLoading)
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          const Icon(
            Icons.inventory_2_outlined,
            color: BasketSuggestionsStyles.iconColor,
            size: BasketSuggestionsStyles.stateIconSize,
          ),
        const SizedBox(width: BasketSuggestionsStyles.stateIconToTextGap),
        Expanded(
          child: Text(
            message,
            style: BasketSuggestionsStyles.stateMessage,
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ),
  );
}
