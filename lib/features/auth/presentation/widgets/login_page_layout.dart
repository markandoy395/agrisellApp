import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:agresell_app/features/auth/presentation/widgets/keyboard_adaptive_scroll_view.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logo_header.dart';

class LoginPageLayout extends StatelessWidget {
  const LoginPageLayout({
    required this.title,
    required this.child,
    this.subtitle = 'Log in to your AgriSell account',
    this.subtitleWidget,
    this.titleColor = AgrisellColors.headingGreen,
    this.titleStyle,
    this.cardHeight,
    this.cardHeightFactor,
    this.minimumCardHeight = 390,
    this.maximumCardHeight = 500,
    this.cardTopPadding = 30,
    this.scrollable = true,
    this.expandChild = false,
    this.scrollViewKey,
    this.onBack,
    super.key,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Color titleColor;
  final TextStyle? titleStyle;
  final double? cardHeight;
  final double? cardHeightFactor;
  final double minimumCardHeight;
  final double maximumCardHeight;
  final double cardTopPadding;
  final bool scrollable;
  final bool expandChild;
  final Key? scrollViewKey;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final compact = size.height < 720;
          final heightFactor = cardHeightFactor ?? (compact ? .62 : .55);
          final calculatedCardHeight = (size.height * heightFactor)
              .clamp(minimumCardHeight, maximumCardHeight)
              .toDouble();
          final effectiveCardHeight = cardHeight ?? calculatedCardHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              const RepaintBoundary(child: AuthBackground()),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: compact ? 16 : 20),
                    child: LogoHeader(
                      widthMin: size.width * .49,
                      widthMax: size.width * .53,
                    ),
                  ),
                ),
              ),
              if (onBack != null)
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        top: compact ? 12 : 16,
                      ),
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: onBack,
                        style: IconButton.styleFrom(
                          backgroundColor: AgrisellColors.forestSoft,
                          foregroundColor: AgrisellColors.headingGreen,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: effectiveCardHeight.clamp(0, size.height).toDouble(),
                  decoration: BoxDecoration(
                    color: AgrisellColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AgrisellColors.brandBlack.withValues(alpha: .09),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Builder(
                    builder: (context) {
                      final padding = EdgeInsets.fromLTRB(
                        28,
                        keyboardHeight > 0 ? 22 : cardTopPadding,
                        28,
                        26 + bottomPadding,
                      );
                      final content = ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: keyboardHeight > 0
                              ? 0
                              : effectiveCardHeight -
                                    cardTopPadding -
                                    26 -
                                    bottomPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style:
                                  titleStyle ??
                                  TextStyle(
                                    color: titleColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                            ),
                            if (subtitleWidget != null)
                              subtitleWidget!
                            else if (subtitle != null &&
                                subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  color: AgrisellColors.mutedText,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 22),
                            ] else
                              const SizedBox(height: 16),
                            if (expandChild) Expanded(child: child) else child,
                          ],
                        ),
                      );

                      final formBody = scrollable
                          ? KeyboardAdaptiveScrollView(
                              key: scrollViewKey,
                              padding: padding,
                              child: content,
                            )
                          : Padding(padding: padding, child: content);

                      return Padding(
                        padding: EdgeInsets.only(bottom: keyboardHeight),
                        child: formBody,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
