import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/widgets/keyboard_adaptive_scroll_view.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.title,
    required this.child,
    this.largeTitle = false,
    this.scrollable = true,
    this.fillRemaining = true,
    super.key,
  });

  final String title;
  final Widget child;
  final bool largeTitle;
  final bool scrollable;
  final bool fillRemaining;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final keyboardPadding = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardVisible = keyboardPadding > 0;
    final keyboardGap = isKeyboardVisible ? 12.0 : 0.0;
    final keyboardCompaction = isKeyboardVisible ? 8.0 : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        lerpDouble(24, 42, scale),
        lerpDouble(28, 36, scale) - keyboardCompaction,
        lerpDouble(24, 42, scale),
        lerpDouble(22, 28, scale) +
            bottomPadding +
            keyboardPadding +
            keyboardGap,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AgrisellColors.authGreen,
              fontSize: largeTitle ? 15 : lerpDouble(14, 15, scale),
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          SizedBox(height: lerpDouble(18, 22, scale) - keyboardCompaction),
          Expanded(
            child: scrollable
                ? KeyboardAdaptiveScrollView(
                    fillRemaining: fillRemaining,
                    child: child,
                  )
                : child,
          ),
        ],
      ),
    );
  }
}
