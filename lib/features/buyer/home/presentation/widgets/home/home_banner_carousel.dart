import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/buyer/home/data/home_banners.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';

class HomeBannerCarousel extends StatelessWidget {
  const HomeBannerCarousel({
    required this.controller,
    required this.height,
    this.onPageChanged,
    super.key,
  });
  final PageController controller;
  final double height;
  final ValueChanged<int>? onPageChanged;
  @override
  Widget build(BuildContext context) {
    if (homeBanners.isEmpty) return const SizedBox.shrink();
    if (homeBanners.length == 1) {
      return SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;
            final centerInset = compact ? 52.0 : 58.0;
            final sideWidth = compact ? 86.0 : 96.0;
            final peekGap = compact ? 10.0 : 12.0;
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
                  padding: EdgeInsets.symmetric(horizontal: centerInset),
                  child: SizedBox.expand(
                    child: _PromoBanner(banner: homeBanners.first),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        height: height,
        child: PageView.builder(
          controller: controller,
          clipBehavior: Clip.none,
          itemCount: homeBanners.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) =>
              _PromoBanner(banner: homeBanners[index]),
        ),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLeft
              ? const [Color(0xFF348F5B), Color(0xFFAADB5B)]
              : const [Color(0xFF202322), Color(0xFF0F6039)],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.banner});
  final HomeBanner banner;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 300;
          final bodyFontSize = compact ? 14.0 : 15.0;
          final saleFontSize = compact ? 20.0 : 22.0;
          final productFontSize = compact ? 19.0 : 21.0;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: constraints.maxWidth * 0.19,
                right: -constraints.maxWidth * 0.1,
                bottom: -constraints.maxHeight * 0.08,
                height: constraints.maxHeight * 0.88,
                child: ResponsiveAssetImage(
                  asset: banner.image,
                  alignment: Alignment.bottomRight,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  semanticLabel: '${banner.title} promotion',
                ),
              ),
              Positioned(
                left: compact ? 20 : 22,
                top: compact ? 20 : 24,
                width: constraints.maxWidth * 0.48,
                child: FittedBox(
                  alignment: Alignment.topLeft,
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        maxLines: 1,
                        text: TextSpan(
                          text: banner.prefix,
                          style: TextStyle(
                            color: AgrisellColors.brandBlack,
                            fontFamily: 'Poppins',
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: banner.highlight,
                              style: TextStyle(
                                color: AgrisellColors.authGreen,
                                fontFamily: 'Poppins',
                                fontSize: saleFontSize,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                          color: AgrisellColors.brandBlack,
                          fontFamily: 'Poppins',
                          fontSize: bodyFontSize,
                          height: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        banner.title,
                        style: TextStyle(
                          color: AgrisellColors.authGreen,
                          fontFamily: 'Poppins',
                          fontSize: productFontSize,
                          height: 0.92,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
