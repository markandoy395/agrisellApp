import 'package:flutter/material.dart';
import '../../styles/home_banner_styles.dart';

class HomeBannerPageIndicator extends StatelessWidget {
  const HomeBannerPageIndicator({
    required this.count,
    required this.currentIndex,
    super.key,
  });

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
          padding: HomeBannerStyles.indicatorPadding,
          decoration: HomeBannerStyles.indicatorDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (index) {
              final selected = index == currentIndex;
              return AnimatedContainer(
                key: ValueKey('home-banner-indicator-$index'),
                duration: const Duration(milliseconds: 220),
                width: selected ? 16 : 6,
                height: 6,
                margin: HomeBannerStyles.indicatorDotMargin(index, count),
                decoration: HomeBannerStyles.indicatorDotDecoration(selected),
              );
            }),
          ),
        ),
      ),
    );
  }
}
