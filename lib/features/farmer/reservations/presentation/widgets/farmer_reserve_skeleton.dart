import 'package:flutter/material.dart';

import '../styles/farmer_reserve_skeleton_styles.dart';
import '../styles/farmer_reserve_styles.dart';

class FarmerReserveSkeleton extends StatefulWidget {
  const FarmerReserveSkeleton({super.key});

  @override
  State<FarmerReserveSkeleton> createState() => _FarmerReserveSkeletonState();
}

class _FarmerReserveSkeletonState extends State<FarmerReserveSkeleton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    lowerBound: 0.55,
    upperBound: 1,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context)) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = FarmerReserveStyles.horizontalPadding(width);
    return Semantics(
      label: 'Loading reservations',
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _controller,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              14,
              horizontal,
              FarmerReserveStyles.navClearance(context),
            ),
            itemCount: 4,
            separatorBuilder: (_, _) => FarmerReserveStyles.orderItemSpacing,
            itemBuilder: (_, _) => _OrderSkeletonCard(compact: width < 380),
          ),
        ),
      ),
    );
  }
}

class _OrderSkeletonCard extends StatelessWidget {
  const _OrderSkeletonCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const ValueKey('reservation-skeleton-card'),
    decoration: FarmerReserveSkeletonStyles.card,
    child: Padding(
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SkeletonLine(width: 0.5, height: 12)),
              SizedBox(width: 12),
              SizedBox(width: 88, child: _SkeletonLine(width: 1, height: 22)),
            ],
          ),
          SizedBox(height: 12),
          _SkeletonLine(width: 0.65, height: 18),
          SizedBox(height: 8),
          _SkeletonLine(width: 0.45, height: 14),
        ],
      ),
    ),
  );
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: width,
    alignment: Alignment.centerLeft,
    child: SizedBox(
      height: height,
      child: DecoratedBox(decoration: FarmerReserveSkeletonStyles.block),
    ),
  );
}
