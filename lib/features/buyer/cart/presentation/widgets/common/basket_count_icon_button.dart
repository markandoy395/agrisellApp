import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/widgets/badges/animated_count_badge.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

class BasketCountIconButton extends StatefulWidget {
  const BasketCountIconButton({
    required this.count,
    required this.pulse,
    required this.onTap,
    this.iconColor = AgrisellColors.brandBlack,
    this.iconSize = 38,
    this.tapSize = 44,
    this.inkRadius = 28,
    this.badgeColor = AgrisellColors.authGreen,
    this.badgeTextColor = AgrisellColors.surface,
    this.badgeBorderColor = AgrisellColors.surface,
    super.key,
  });

  final int count;
  final int pulse;
  final VoidCallback onTap;
  final Color iconColor;
  final double iconSize;
  final double tapSize;
  final double inkRadius;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color badgeBorderColor;

  @override
  State<BasketCountIconButton> createState() => _BasketCountIconButtonState();
}

class _BasketCountIconButtonState extends State<BasketCountIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curvedAnimation;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.14, end: 0.96), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 40),
    ]).animate(_curvedAnimation);
  }

  @override
  void didUpdateWidget(covariant BasketCountIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countLabel = widget.count > 99 ? '99+' : widget.count.toString();

    return Semantics(
      button: true,
      label: 'Open basket, $countLabel items',
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox.square(
          dimension: widget.tapSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Center(
                  child: InkResponse(
                    onTap: widget.onTap,
                    radius: widget.inkRadius,
                    child: HomeAssetIcon(
                      asset: AgrisellAssets.iconBasket,
                      size: widget.iconSize,
                      color: widget.iconColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: AnimatedCountBadge(
                  count: widget.count,
                  backgroundColor: widget.badgeColor,
                  foregroundColor: widget.badgeTextColor,
                  borderColor: widget.badgeBorderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
