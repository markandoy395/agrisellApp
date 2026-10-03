import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_product_scroll_view_styles.dart';

class HomeCatalogFooter extends StatelessWidget {
  const HomeCatalogFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.productCount,
    super.key,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: HomeProductScrollViewStyles.footerPadding,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: HomeProductScrollViewStyles.footerLoadingIndicatorSize,
                  height:
                      HomeProductScrollViewStyles.footerLoadingIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth:
                        HomeProductScrollViewStyles.footerLoadingStrokeWidth,
                    color: AgrisellColors.authGreen,
                  ),
                ),
                HomeProductScrollViewStyles.footerGap,
                Text(
                  'Loading more products...',
                  style: HomeProductScrollViewStyles.footerLoadingTextStyle,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (!hasMore && productCount >= 10) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: HomeProductScrollViewStyles.footerPadding,
          child: Center(
            child: Text(
              'You’ve reached the end of the catalog',
              style: HomeProductScrollViewStyles.footerEndTextStyle,
            ),
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
