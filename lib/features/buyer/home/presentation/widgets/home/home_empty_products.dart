import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_empty_products_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class HomeEmptyProducts extends StatelessWidget {
  const HomeEmptyProducts({
    required this.onReset,
    required this.title,
    required this.message,
    this.actionLabel = 'Reset search and filters',
    super.key,
  });

  final VoidCallback onReset;
  final String title;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: SharedPresentationStyles.forestCircle,
            child: const Icon(
              Icons.search_off_rounded,
              color: AgrisellColors.authGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: HomeEmptyProductsStyles.titleText),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: HomeEmptyProductsStyles.messageText,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: onReset,
              style: HomeEmptyProductsStyles.outlinedButtonStyle,
              child: Text(
                actionLabel,
                style: SharedPresentationStyles.captionBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
