import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';

abstract final class HomeBannerCarouselTiming {
  static const loopPage = 10000;
  static const autoScrollDelay = Duration(seconds: 4);
  static const interactionResumeDelay = Duration(seconds: 5);
  static const scrollDuration = Duration(milliseconds: 650);
  static const databaseRefreshDelay = Duration(seconds: 15);

  static DateTime? findNextExpiry(List<HomeBanner> banners, DateTime now) =>
      banners
          .map((banner) => banner.expiresAt)
          .whereType<DateTime>()
          .where((expiry) => expiry.isAfter(now))
          .fold<DateTime?>(
            null,
            (earliest, expiry) =>
                earliest == null || expiry.isBefore(earliest)
                    ? expiry
                    : earliest,
          );

  static int calculateStartPage(int count) {
    if (count <= 1) return 0;
    return loopPage - (loopPage % count);
  }

  static int calculateBannerIndex(int page, int bannerCount) =>
      bannerCount <= 0 ? 0 : page % bannerCount;

  static List<HomeBanner> filterActive(
    List<HomeBanner> banners, [
    DateTime? now,
  ]) {
    final current = now ?? DateTime.now();
    return banners
        .where((banner) => !banner.isExpiredAt(current))
        .toList(growable: false);
  }

  static Future<void> animateNextPage(PageController controller) async {
    if (!controller.hasClients) return;
    final currentPage =
        controller.page?.round() ?? controller.initialPage;
    try {
      await controller.animateToPage(
        currentPage + 1,
        duration: scrollDuration,
        curve: Curves.easeInOutCubic,
      );
    } on Object {
      // The page can detach when the buyer changes tabs during an animation.
    }
  }
}
