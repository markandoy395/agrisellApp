import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import '../../controllers/home_banner_carousel_controller.dart';
import '../../styles/home_banner_styles.dart';
import 'home_single_banner.dart';
import 'home_promo_banner.dart';
import 'home_banner_page_indicator.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    required this.controller,
    required this.height,
    this.onPageChanged,
    this.onBannerTap,
    this.banners,
    super.key,
  });
  final PageController controller;
  final double height;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<HomeBanner>? onBannerTap;

  /// Used by previews and tests. Production banners come from Admin sales.
  final List<HomeBanner>? banners;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final HomeBannerCarouselController _carousel;

  @override
  void initState() {
    super.initState();
    _carousel = HomeBannerCarouselController(
      pageController: widget.controller,
      banners: widget.banners,
    );
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _carousel.update(controller: widget.controller, banners: widget.banners);
  }

  @override
  void dispose() {
    _carousel.dispose();
    super.dispose();
  }

  VoidCallback? _tapHandler(HomeBanner banner) =>
      banner.opensSaleCampaign && widget.onBannerTap != null
      ? () => widget.onBannerTap!(banner)
      : null;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _carousel,
    builder: (context, _) => _buildCarousel(context),
  );

  Widget _buildCarousel(BuildContext context) {
    final activeBanners = _carousel.activeBanners;
    if (activeBanners.isEmpty) return const SizedBox.shrink();
    if (activeBanners.length == 1) {
      return HomeSingleBanner(
        banner: activeBanners.first,
        height: widget.height,
        onTap: _tapHandler(activeBanners.first),
      );
    }
    return Padding(
      padding: HomeBannerStyles.carouselPadding,
      child: SizedBox(
        height: widget.height,
        child: Listener(
          onPointerDown: _carousel.handleInteractionStart,
          onPointerUp: _carousel.handleInteractionEnd,
          onPointerCancel: _carousel.handleInteractionEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PageView.builder(
                controller: widget.controller,
                reverse: true,
                clipBehavior: Clip.none,
                onPageChanged: (page) {
                  final index = _carousel.handlePageChanged(
                    page,
                    activeBanners.length,
                  );
                  widget.onPageChanged?.call(index);
                },
                itemBuilder: (context, page) => Padding(
                  key: ValueKey('home-banner-page-$page'),
                  padding: HomeBannerStyles.pagePadding,
                  child: HomePromoBanner(
                    banner: activeBanners[page % activeBanners.length],
                    onTap: _tapHandler(
                      activeBanners[page % activeBanners.length],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: HomeBannerPageIndicator(
                  count: activeBanners.length,
                  currentIndex:
                      _carousel.currentBannerIndex % activeBanners.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
