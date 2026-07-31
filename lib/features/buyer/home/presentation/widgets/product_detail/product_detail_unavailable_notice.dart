import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class ProductDetailUnavailableNotice extends StatelessWidget {
  const ProductDetailUnavailableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AgrisellColors.statusRedBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AgrisellColors.statusRedText.withValues(alpha: 0.22),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AgrisellColors.statusRedText,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This product is not accepting orders right now.',
              style: TextStyle(
                color: AgrisellColors.statusRedText,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
