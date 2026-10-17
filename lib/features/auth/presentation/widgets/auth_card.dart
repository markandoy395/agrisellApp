import 'package:agresell_app/features/auth/presentation/styles/auth_card_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/widgets/keyboard_adaptive_scroll_view.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.title,
    required this.child,
    this.largeTitle = false,
    this.scrollable = true,
    this.fillRemaining = true,
    this.fitContent = false,
    super.key,
  });

  final String title;
  final Widget child;
  final bool largeTitle;
  final bool scrollable;
  final bool fillRemaining;
  final bool fitContent;

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
      decoration: AuthCardStyles.containerDecoration,
      child: Column(
        mainAxisSize: fitContent ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AuthCardStyles.titleText(largeTitle, scale)),
          SizedBox(height: lerpDouble(18, 22, scale) - keyboardCompaction),
          Flexible(
            fit: fitContent ? FlexFit.loose : FlexFit.tight,
            child: scrollable
                ? KeyboardAdaptiveScrollView(
                    fillRemaining: fillRemaining,
                    fitContent: fitContent,
                    child: child,
                  )
                : child,
          ),
        ],
      ),
    );
  }
}
