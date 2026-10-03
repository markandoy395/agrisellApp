import 'package:agresell_app/features/farmer/products/presentation/styles/product_edit_status_button_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ProductEditStatusButton extends StatelessWidget {
  const ProductEditStatusButton({
    required this.isSold,
    required this.onTap,
    super.key,
  });

  final bool isSold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final red = AgrisellColors.unavailableRed;

    return SizedBox(
      width: 154,
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: ProductEditStatusButtonStyles.outlinedButtonStyle(isSold, red),
        child: Text(
          isSold ? 'Sold' : 'Unsold',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ProductEditStatusButtonStyles.textStyle,
        ),
      ),
    );
  }
}
