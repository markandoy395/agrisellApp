import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';

/// Loading placeholder that preserves the final product grid's layout.
class HomeProductGridSkeleton extends StatefulWidget {
  const HomeProductGridSkeleton({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  State<HomeProductGridSkeleton> createState() =>
      _HomeProductGridSkeletonState();
}

class _HomeProductGridSkeletonState extends State<HomeProductGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return SliverGrid.builder(
      itemCount: widget.itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: width < 380 ? 10 : 12,
        mainAxisSpacing: width < 380 ? 12 : 14,
        mainAxisExtent: HomeProductCard.heightForWidth(width),
      ),
      itemBuilder: (_, index) => Semantics(
        label: 'Loading product',
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) => _SkeletonCard(
              animationValue: MediaQuery.disableAnimationsOf(context)
                  ? 0.5
                  : _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.animationValue});

  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final detailsHeight =
        HomeProductCard.heightForWidth(width) - HomeProductCard.imageHeight;
    final baseColor = Color.lerp(
      AgrisellColors.borderLine,
      AgrisellColors.searchBackground,
      animationValue,
    )!;

    return DecoratedBox(
      key: const ValueKey('home-product-skeleton-card'),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: HomeProductCard.imageHeight, color: baseColor),
            SizedBox(
              height: detailsHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonLine(widthFactor: 0.72, color: baseColor),
                    const SizedBox(height: 9),
                    _SkeletonLine(widthFactor: 0.48, color: baseColor),
                    const SizedBox(height: 8),
                    _SkeletonLine(widthFactor: 0.62, color: baseColor),
                    const SizedBox(height: 9),
                    _SkeletonLine(widthFactor: 0.4, color: baseColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor, required this.color});

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 11,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
