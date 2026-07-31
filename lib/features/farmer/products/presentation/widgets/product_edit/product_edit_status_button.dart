import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

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
        style: OutlinedButton.styleFrom(
          backgroundColor: isSold ? red : AgrisellColors.surface,
          foregroundColor: isSold ? AgrisellColors.surface : red,
          side: BorderSide(color: red, width: 1.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          isSold ? 'Sold' : 'Unsold',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
