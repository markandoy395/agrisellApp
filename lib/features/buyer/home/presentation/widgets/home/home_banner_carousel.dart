import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/home/data/home_banner_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';

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

class _HomeBannerCarouselState extends State<HomeBannerCarousel>
    with WidgetsBindingObserver {
  static const _loopPage = 10000;
  static const _autoScrollDelay = Duration(seconds: 4);
  static const _interactionResumeDelay = Duration(seconds: 5);
  static const _scrollDuration = Duration(milliseconds: 650);
  static const _databaseRefreshDelay = Duration(seconds: 15);

  Timer? _expiryTimer;
  Timer? _autoScrollTimer;
  Timer? _databaseRefreshTimer;
  List<HomeBanner> _loadedBanners = const [];
  int _currentBannerIndex = 0;
  bool _isUserInteracting = false;
  bool _isLoadingBanners = false;
  bool _appIsActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadBanners());
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.banners != widget.banners) {
      if (widget.banners == null) {
        unawaited(_loadBanners());
      } else {
        _databaseRefreshTimer?.cancel();
        _scheduleExpiryCheck();
        _prepareCarousel();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsActive = state == AppLifecycleState.resumed;
    if (_appIsActive) {
      unawaited(_loadBanners());
    } else {
      _databaseRefreshTimer?.cancel();
      _autoScrollTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expiryTimer?.cancel();
    _autoScrollTimer?.cancel();
    _databaseRefreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleExpiryCheck() {
    _expiryTimer?.cancel();
    final now = DateTime.now();
    final nextExpiry = _banners
        .map((banner) => banner.expiresAt)
        .whereType<DateTime>()
        .where((expiry) => expiry.isAfter(now))
        .fold<DateTime?>(
          null,
          (earliest, expiry) =>
              earliest == null || expiry.isBefore(earliest) ? expiry : earliest,
        );
    if (nextExpiry == null) return;
    _expiryTimer = Timer(nextExpiry.difference(now), () {
      if (!mounted) return;
      setState(() {
        _currentBannerIndex = 0;
        _scheduleExpiryCheck();
      });
      _prepareCarousel();
    });
  }

  List<HomeBanner> get _banners => widget.banners ?? _loadedBanners;

  List<HomeBanner> get _activeBanners => _banners
      .where((banner) => !banner.isExpiredAt(DateTime.now()))
      .toList(growable: false);

  Future<void> _loadBanners() async {
    if (widget.banners != null) {
      _scheduleExpiryCheck();
      _prepareCarousel();
      return;
    }
    if (_isLoadingBanners) return;
    _isLoadingBanners = true;
    final previousBannerCount = _activeBanners.length;
    try {
      final banners = await const HomeBannerRepository().loadActiveBanners();
      if (!mounted) return;
      setState(() => _loadedBanners = banners);
    } on Object catch (error) {
      // A promotion must never block the marketplace catalog. Keeping the
      // error in debug output makes an unapplied Admin-banner migration clear.
      debugPrint('Unable to load Admin promotion banners: $error');
    } finally {
      _isLoadingBanners = false;
    }
    if (mounted) {
      _scheduleExpiryCheck();
      if (previousBannerCount != _activeBanners.length) {
        _prepareCarousel();
      } else {
        _scheduleAutoScroll();
      }
      _scheduleDatabaseRefresh();
    }
  }

  void _scheduleDatabaseRefresh() {
    _databaseRefreshTimer?.cancel();
    if (!mounted || !_appIsActive || widget.banners != null) return;
    _databaseRefreshTimer = Timer(
      _databaseRefreshDelay,
      () => unawaited(_loadBanners()),
    );
  }

  void _prepareCarousel() {
    _autoScrollTimer?.cancel();
    _currentBannerIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final count = _activeBanners.length;
      if (count > 1 && widget.controller.hasClients) {
        final startPage = _loopPage - (_loopPage % count);
        widget.controller.jumpToPage(startPage);
      }
      _scheduleAutoScroll();
    });
  }

  void _scheduleAutoScroll({Duration delay = _autoScrollDelay}) {
    _autoScrollTimer?.cancel();
    if (!mounted ||
        !_appIsActive ||
        _isUserInteracting ||
        _activeBanners.length < 2) {
      return;
    }
    _autoScrollTimer = Timer(delay, _advanceBanner);
  }

  Future<void> _advanceBanner() async {
    if (!mounted ||
        _isUserInteracting ||
        _activeBanners.length < 2 ||
        !widget.controller.hasClients) {
      _scheduleAutoScroll();
      return;
    }

    final currentPage =
        widget.controller.page?.round() ?? widget.controller.initialPage;
    try {
      await widget.controller.animateToPage(
        currentPage + 1,
        duration: _scrollDuration,
        curve: Curves.easeInOutCubic,
      );
    } on Object {
      // The page can detach when the buyer changes tabs during an animation.
    }
    if (mounted) _scheduleAutoScroll();
  }

  void _handlePageChanged(int page, int bannerCount) {
    final bannerIndex = page % bannerCount;
    if (_currentBannerIndex != bannerIndex) {
      setState(() => _currentBannerIndex = bannerIndex);
    }
    widget.onPageChanged?.call(bannerIndex);
  }

  void _handleInteractionStart(PointerDownEvent _) {
    _isUserInteracting = true;
    _autoScrollTimer?.cancel();
  }

  void _handleInteractionEnd(PointerEvent _) {
    _isUserInteracting = false;
    _scheduleAutoScroll(delay: _interactionResumeDelay);
  }

  @override
  Widget build(BuildContext context) {
    final activeBanners = _activeBanners;
    if (activeBanners.isEmpty) return const SizedBox.shrink();
    if (activeBanners.length == 1) {
      return SizedBox(
        height: widget.height,
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
                    child: _PromoBanner(
                      banner: activeBanners.first,
                      onTap:
                          activeBanners.first.opensSaleCampaign &&
                              widget.onBannerTap != null
                          ? () => widget.onBannerTap!(activeBanners.first)
                          : null,
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: _BannerPageIndicator(count: 1, currentIndex: 0),
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
        height: widget.height,
        child: Listener(
          onPointerDown: _handleInteractionStart,
          onPointerUp: _handleInteractionEnd,
          onPointerCancel: _handleInteractionEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PageView.builder(
                controller: widget.controller,
                reverse: true,
                clipBehavior: Clip.none,
                onPageChanged: (page) =>
                    _handlePageChanged(page, activeBanners.length),
                itemBuilder: (context, page) => Padding(
                  key: ValueKey('home-banner-page-$page'),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: _PromoBanner(
                    banner: activeBanners[page % activeBanners.length],
                    onTap:
                        activeBanners[page % activeBanners.length]
                                .opensSaleCampaign &&
                            widget.onBannerTap != null
                        ? () => widget.onBannerTap!(
                            activeBanners[page % activeBanners.length],
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: _BannerPageIndicator(
                  count: activeBanners.length,
                  currentIndex: _currentBannerIndex % activeBanners.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerPageIndicator extends StatelessWidget {
  const _BannerPageIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      excludeSemantics: true,
      label: 'Banner ${currentIndex + 1} of $count',
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (index) {
              final selected = index == currentIndex;
              return AnimatedContainer(
                key: ValueKey('home-banner-indicator-$index'),
                duration: const Duration(milliseconds: 220),
                width: selected ? 16 : 6,
                height: 6,
                margin: EdgeInsets.only(right: index == count - 1 ? 0 : 4),
                decoration: BoxDecoration(
                  color: selected
                      ? AgrisellColors.surface
                      : AgrisellColors.surface.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
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
  const _PromoBanner({required this.banner, this.onTap});
  final HomeBanner banner;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
                  left: constraints.maxWidth * 0.34,
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
                        if (banner.source == HomeBannerSource.campaign) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AgrisellColors.authGreen,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${banner.title.replaceAll('\n', ' ')}  •  ON SALE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AgrisellColors.surface,
                                fontFamily: 'Poppins',
                                fontSize: compact ? 7 : 8,
                                height: 1,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ] else
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
                        const SizedBox(height: 10),
                        Semantics(
                          label: 'Valid until ${banner.expiryLabel}',
                          excludeSemantics: true,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 7 : 8,
                              vertical: compact ? 5 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: AgrisellColors.authGreen.withValues(
                                alpha: 0.10,
                              ),
                              border: Border.all(
                                color: AgrisellColors.authGreen.withValues(
                                  alpha: 0.22,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: compact ? 17 : 19,
                                  height: compact ? 17 : 19,
                                  decoration: const BoxDecoration(
                                    color: AgrisellColors.authGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: AgrisellColors.surface,
                                    size: compact ? 11 : 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VALID UNTIL',
                                      style: TextStyle(
                                        color: AgrisellColors.authGreen,
                                        fontFamily: 'Poppins',
                                        fontSize: compact ? 7 : 8,
                                        height: 1,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.45,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      banner.expiryLabel,
                                      style: TextStyle(
                                        color: AgrisellColors.brandBlack,
                                        fontFamily: 'Poppins',
                                        fontSize: compact ? 9 : 10,
                                        height: 1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onTap != null)
                  Positioned(
                    right: compact ? 14 : 18,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AgrisellColors.authGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SHOP SALE',
                            style: TextStyle(
                              color: AgrisellColors.surface,
                              fontFamily: 'Poppins',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: AgrisellColors.surface,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: 'Open ${banner.subtitle} sale products',
      child: content,
    );
  }
}
