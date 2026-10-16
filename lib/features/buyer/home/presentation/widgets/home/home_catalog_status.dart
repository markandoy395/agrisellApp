import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/home/presentation/styles/home_product_scroll_view_styles.dart';

class HomeCatalogStatus extends StatelessWidget {
  const HomeCatalogStatus({required this.failed, super.key});

  final bool failed;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: HomeProductScrollViewStyles.footerPadding,
      child: Semantics(
        liveRegion: true,
        child: Text(
          failed
              ? 'Could not refresh products. Pull down to retry.'
              : 'Updating prices and availability…',
          style: HomeProductScrollViewStyles.footerLoadingTextStyle,
        ),
      ),
    ),
  );
}

class HomeCatalogBottomSpacer extends StatelessWidget {
  const HomeCatalogBottomSpacer({super.key});

  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
    child: SizedBox(height: HomeProductScrollViewStyles.bottomSpacerHeight),
  );
}
