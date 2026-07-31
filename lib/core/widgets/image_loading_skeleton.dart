import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class ImageLoadingSkeleton extends StatefulWidget {
  const ImageLoadingSkeleton({super.key});

  @override
  State<ImageLoadingSkeleton> createState() => _ImageLoadingSkeletonState();
}

class _ImageLoadingSkeletonState extends State<ImageLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _controller.value * 4 - 2;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(offset, 0),
              end: Alignment(offset + 1, 0),
              colors: const [
                AgrisellColors.searchBackground,
                AgrisellColors.borderLine,
                AgrisellColors.searchBackground,
              ],
            ),
          ),
        );
      },
    );
  }
}
