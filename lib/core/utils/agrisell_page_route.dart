import 'package:flutter/material.dart';
import 'package:agresell_app/features/auth/presentation/auth_page_gate.dart';

Route<T> agrisellMaterialPageRoute<T>({required WidgetBuilder builder}) =>
    MaterialPageRoute<T>(
      builder: (context) => AuthPageGate(child: builder(context)),
    );

Route<T> agrisellPageRoute<T>({
  required WidgetBuilder builder,
  Offset beginOffset = const Offset(0.04, 0),
  Duration duration = const Duration(milliseconds: 260),
  Duration reverseDuration = const Duration(milliseconds: 200),
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, _, _) => AuthPageGate(child: builder(context)),
    transitionsBuilder: (context, animation, _, child) {
      return _AgrisellRouteTransition(
        animation: animation,
        beginOffset: beginOffset,
        child: child,
      );
    },
  );
}

class _AgrisellRouteTransition extends StatefulWidget {
  const _AgrisellRouteTransition({
    required this.animation,
    required this.beginOffset,
    required this.child,
  });

  final Animation<double> animation;
  final Offset beginOffset;
  final Widget child;

  @override
  State<_AgrisellRouteTransition> createState() =>
      _AgrisellRouteTransitionState();
}

class _AgrisellRouteTransitionState extends State<_AgrisellRouteTransition> {
  late CurvedAnimation _curvedAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _createAnimations();
  }

  @override
  void didUpdateWidget(covariant _AgrisellRouteTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation == widget.animation &&
        oldWidget.beginOffset == widget.beginOffset) {
      return;
    }

    _curvedAnimation.dispose();
    _createAnimations();
  }

  void _createAnimations() {
    _curvedAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(_curvedAnimation);
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _curvedAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
