import 'dart:math' as math;

import 'package:flutter/material.dart';

class NotificationScrollAnimation extends StatefulWidget {
  const NotificationScrollAnimation({
    required this.controller,
    required this.child,
    super.key,
  });

  final ScrollController controller;
  final Widget child;

  @override
  State<NotificationScrollAnimation> createState() {
    return _NotificationScrollAnimationState();
  }
}

class _NotificationScrollAnimationState
    extends State<NotificationScrollAnimation> {
  final _itemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant NotificationScrollAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller.removeListener(_handleScroll);
    widget.controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (disableAnimations) {
      return KeyedSubtree(key: _itemKey, child: widget.child);
    }

    final progress = _scrollProgress(context);
    final easedProgress = Curves.easeOutCubic.transform(progress);
    final verticalOffset = (1 - easedProgress) * 18;
    final opacity = 0.66 + (easedProgress * 0.34);
    final scale = 0.985 + (easedProgress * 0.015);

    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: KeyedSubtree(key: _itemKey, child: widget.child),
        ),
      ),
    );
  }

  double _scrollProgress(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context);
    final viewport = scrollable?.context.findRenderObject();
    final item = _itemKey.currentContext?.findRenderObject();

    if (viewport is! RenderBox || item is! RenderBox) return 1;
    if (!viewport.hasSize || !item.hasSize) return 1;

    final itemTop = item.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final itemBottom = itemTop + item.size.height;
    final viewportHeight = viewport.size.height;
    final topProgress = (itemBottom / 96).clamp(0.0, 1.0);
    final bottomProgress = ((viewportHeight - itemTop) / 150).clamp(0.0, 1.0);

    return math.min(topProgress, bottomProgress).toDouble();
  }
}
