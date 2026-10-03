import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_unavailable_notice_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ProductDetailUnavailableNotice extends StatelessWidget {
  const ProductDetailUnavailableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ProductDetailUnavailableNoticeStyles.containerDecoration,
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
              style: ProductDetailUnavailableNoticeStyles
                  .thisProductIsNotAcceptingText,
            ),
          ),
        ],
      ),
    );
  }
}
