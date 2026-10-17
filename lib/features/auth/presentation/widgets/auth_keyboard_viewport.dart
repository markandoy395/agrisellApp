import 'package:flutter/material.dart';

import 'keyboard_adaptive_scroll_view.dart';

/// Keeps keyboard metrics out of the background, header and form builders.
class AuthKeyboardViewport extends StatelessWidget {
  const AuthKeyboardViewport({
    required this.child,
    required this.topPadding,
    required this.scrollable,
    this.scrollViewKey,
    super.key,
  });

  final Widget child;
  final double topPadding;
  final bool scrollable;
  final Key? scrollViewKey;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    // Unlike padding, viewPadding stays stable when the keyboard opens.
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(28, topPadding, 28, 26 + bottomPadding);

    // Follow the platform's inset frames directly; an additional implicit
    // animation would lag behind the keyboard and keep moving after it stops.
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: scrollable
          ? KeyboardAdaptiveScrollView(
              key: scrollViewKey,
              padding: padding,
              child: child,
            )
          : Padding(padding: padding, child: child),
    );
  }
}
