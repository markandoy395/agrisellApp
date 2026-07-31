import 'dart:async';

import 'package:flutter/material.dart';

class HomeEntranceAnimation extends StatefulWidget {
  const HomeEntranceAnimation({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 360),
    this.offset = const Offset(0, 0.08),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<HomeEntranceAnimation> createState() => _HomeEntranceAnimationState();
}

class _HomeEntranceAnimationState extends State<HomeEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curvedAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _delayTimer;
  var _didStart = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = _curvedAnimation;
    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1,
    ).animate(_curvedAnimation);
    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(_curvedAnimation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didStart) {
      return;
    }

    _didStart = true;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _controller.value = 1;
      return;
    }

    _delayTimer = Timer(widget.delay, () {
      if (!mounted) {
        return;
      }

      _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}
