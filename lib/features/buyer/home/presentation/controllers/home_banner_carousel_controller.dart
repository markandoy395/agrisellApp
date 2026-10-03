import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/home/data/home_banner_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_banner_carousel_timing.dart';

/// Owns banner refresh, expiry, looping, and interaction-aware auto-scrolling.
/// The caller retains ownership of the supplied PageController.
class HomeBannerCarouselController extends ChangeNotifier
    with WidgetsBindingObserver {
  HomeBannerCarouselController({
    required this.pageController,
    List<HomeBanner>? banners,
  }) : _providedBanners = banners {
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadBanners());
  }

  PageController pageController;
  List<HomeBanner>? _providedBanners;
  bool _disposed = false;
  int get currentBannerIndex => _currentBannerIndex;

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }

  Timer? _expiryTimer;
  Timer? _autoScrollTimer;
  Timer? _databaseRefreshTimer;
  List<HomeBanner> _loadedBanners = const [];
  int _currentBannerIndex = 0;
  bool _isUserInteracting = false;
  bool _isLoadingBanners = false;
  bool _appIsActive = true;

  void update({required PageController controller, List<HomeBanner>? banners}) {
    final changed = pageController != controller || _providedBanners != banners;
    pageController = controller;
    _providedBanners = banners;
    if (!changed) return;
    if (banners == null) {
      unawaited(_loadBanners());
    } else {
      _databaseRefreshTimer?.cancel();
      _scheduleExpiryCheck();
      _prepareCarousel();
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
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _expiryTimer?.cancel();
    _autoScrollTimer?.cancel();
    _databaseRefreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleExpiryCheck() {
    _expiryTimer?.cancel();
    final now = DateTime.now();
    final nextExpiry = HomeBannerCarouselTiming.findNextExpiry(_banners, now);
    if (nextExpiry == null) return;
    _expiryTimer = Timer(nextExpiry.difference(now), () {
      if (_disposed) return;
      _update(() {
        _currentBannerIndex = 0;
        _scheduleExpiryCheck();
      });
      _prepareCarousel();
    });
  }

  List<HomeBanner> get _banners => _providedBanners ?? _loadedBanners;

  List<HomeBanner> get activeBanners =>
      HomeBannerCarouselTiming.filterActive(_banners);

  Future<void> _loadBanners() async {
    if (_providedBanners != null) {
      _scheduleExpiryCheck();
      _prepareCarousel();
      return;
    }
    if (_isLoadingBanners) return;
    _isLoadingBanners = true;
    final previousBannerCount = activeBanners.length;
    try {
      final banners = await const HomeBannerRepository().loadActiveBanners();
      if (_disposed) return;
      _update(() => _loadedBanners = banners);
    } on Object catch (error) {
      debugPrint('Unable to load Admin promotion banners: $error');
    } finally {
      _isLoadingBanners = false;
    }
    if (!_disposed) {
      _scheduleExpiryCheck();
      if (previousBannerCount != activeBanners.length) {
        _prepareCarousel();
      } else {
        _scheduleAutoScroll();
      }
      _scheduleDatabaseRefresh();
    }
  }

  void _scheduleDatabaseRefresh() {
    _databaseRefreshTimer?.cancel();
    if (_disposed || !_appIsActive || _providedBanners != null) return;
    _databaseRefreshTimer = Timer(
      HomeBannerCarouselTiming.databaseRefreshDelay,
      () => unawaited(_loadBanners()),
    );
  }

  void _prepareCarousel() {
    _autoScrollTimer?.cancel();
    _currentBannerIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      final count = activeBanners.length;
      if (count > 1 && pageController.hasClients) {
        pageController.jumpToPage(
          HomeBannerCarouselTiming.calculateStartPage(count),
        );
      }
      _scheduleAutoScroll();
    });
  }

  void _scheduleAutoScroll({
    Duration delay = HomeBannerCarouselTiming.autoScrollDelay,
  }) {
    _autoScrollTimer?.cancel();
    if (_disposed ||
        !_appIsActive ||
        _isUserInteracting ||
        activeBanners.length < 2) {
      return;
    }
    _autoScrollTimer = Timer(delay, _advanceBanner);
  }

  Future<void> _advanceBanner() async {
    if (_disposed ||
        _isUserInteracting ||
        activeBanners.length < 2 ||
        !pageController.hasClients) {
      _scheduleAutoScroll();
      return;
    }
    await HomeBannerCarouselTiming.animateNextPage(pageController);
    if (!_disposed) _scheduleAutoScroll();
  }

  int handlePageChanged(int page, int bannerCount) {
    final bannerIndex = HomeBannerCarouselTiming.calculateBannerIndex(
      page,
      bannerCount,
    );
    if (_currentBannerIndex != bannerIndex) {
      _update(() => _currentBannerIndex = bannerIndex);
    }
    return bannerIndex;
  }

  void handleInteractionStart(PointerDownEvent _) {
    _isUserInteracting = true;
    _autoScrollTimer?.cancel();
  }

  void handleInteractionEnd(PointerEvent _) {
    _isUserInteracting = false;
    _scheduleAutoScroll(
      delay: HomeBannerCarouselTiming.interactionResumeDelay,
    );
  }
}
