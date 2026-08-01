import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/widgets/badges/animated_count_badge.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

class BasketCountButton extends StatefulWidget {
  const BasketCountButton({
    required this.count,
    required this.pulse,
    required this.onTap,
    super.key,
  });

  final int count;
  final int pulse;
  final VoidCallback onTap;

  @override
  State<BasketCountButton> createState() => _BasketCountButtonState();
}

class _BasketCountButtonState extends State<BasketCountButton>
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
  void didUpdateWidget(covariant BasketCountButton oldWidget) {
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
          dimension: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Center(
                  child: SizedBox.square(
                    dimension: 40,
                    child: Material(
                      color: AgrisellColors.forestSoft,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onTap,
                        child: const Center(
                          child: HomeAssetIcon(
                            asset: AgrisellAssets.iconBasket,
                            size: 22,
                            color: AgrisellColors.authGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1,
                right: 0,
                child: AnimatedCountBadge(count: widget.count),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
