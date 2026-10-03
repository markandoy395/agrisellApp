import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import '../../styles/home_banner_styles.dart';
import 'home_promo_banner.dart';
import 'home_banner_page_indicator.dart';

class HomeSingleBanner extends StatelessWidget {
  const HomeSingleBanner({
    required this.banner,
    required this.height,
    this.onTap,
    super.key,
  });
  final HomeBanner banner;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;
          final centerInset = HomeBannerStyles.singleCenterInset(compact);
          final sideWidth = HomeBannerStyles.singleSideWidth(compact);
          final peekGap = HomeBannerStyles.singlePeekGap(compact);
          final sideOffset = centerInset - sideWidth - peekGap;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: sideOffset,
                top: 0,
                bottom: 0,
                width: sideWidth,
                child: const _SideBannerPeek(isLeft: true),
              ),
              Positioned(
                right: sideOffset,
                top: 0,
                bottom: 0,
                width: sideWidth,
                child: const _SideBannerPeek(isLeft: false),
              ),
              Padding(
                padding: HomeBannerStyles.singleBannerPadding(centerInset),
                child: SizedBox.expand(
                  child: HomePromoBanner(banner: banner, onTap: onTap),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: HomeBannerPageIndicator(count: 1, currentIndex: 0),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SideBannerPeek extends StatelessWidget {
  const _SideBannerPeek({required this.isLeft});
  final bool isLeft;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: HomeBannerStyles.sidePeekDecoration(isLeft),
    );
  }
}
