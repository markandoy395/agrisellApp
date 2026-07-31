import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authBackground.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authCard.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logoHeader.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.child,
    this.largeTitle = false,
    this.compactCard = false,
    this.scrollable = true,
    super.key,
  });

  final String title;
  final Widget child;
  final bool largeTitle;
  final bool compactCard;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = authScale(size.width);
    final heightScale = ((size.height - 568) / 364).clamp(0, 1).toDouble();
    final layoutScale = widthScale < heightScale ? widthScale : heightScale;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compactCardHeight = lerpDouble(430, 480, layoutScale);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: lerpDouble(36, 64, layoutScale)),
                LogoHeader(
                  style: LogoHeaderStyle.horizontal,
                  widthMin: 180,
                  widthMax: lerpDouble(220, 240, layoutScale),
                ),
                SizedBox(height: lerpDouble(24, 34, layoutScale)),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final card = AuthCard(
                        title: title,
                        largeTitle: largeTitle,
                        scrollable: scrollable,
                        child: child,
                      );

                      if (!compactCard) return card;

                      final cardHeight = keyboardVisible
                          ? constraints.maxHeight
                          : compactCardHeight;

                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: cardHeight
                              .clamp(0, constraints.maxHeight)
                              .toDouble(),
                          child: card,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
