import 'package:flutter/material.dart';

class NotchedBarPainter extends CustomPainter {
  const NotchedBarPainter({
    required this.activeIndex,
    required this.itemCount,
    required this.background,
    required this.shadowColor,
    required this.activeButtonSize,
    required this.activeVerticalOffset,
    this.activeButtonWidth,
    this.activeButtonHeight,
    this.notchMargin = 8,
    this.notchInsets,
  });

  final double activeIndex;
  final int itemCount;
  final Color background;
  final Color shadowColor;
  final double activeButtonSize;
  final double activeVerticalOffset;
  final double? activeButtonWidth;
  final double? activeButtonHeight;
  final double notchMargin;
  final EdgeInsets? notchInsets;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerRadius = (size.height * 0.16).clamp(12.0, 16.0);
    final itemWidth = size.width / itemCount;
    final activeCenterX = itemWidth * (activeIndex + 0.5);
    final buttonWidth = activeButtonWidth ?? activeButtonSize;
    final buttonHeight = activeButtonHeight ?? activeButtonSize;
    final baseButton = Rect.fromCenter(
      center: Offset(activeCenterX, activeVerticalOffset + buttonHeight / 2),
      width: buttonWidth,
      height: buttonHeight,
    );
    final insets = notchInsets ?? EdgeInsets.all(notchMargin);
    final host = Rect.fromLTWH(0, 0, size.width, size.height);
    final button = Rect.fromLTRB(
      baseButton.left - insets.left,
      baseButton.top - insets.top,
      baseButton.right + insets.right,
      baseButton.bottom + insets.bottom,
    );

    final notchedPath = const CircularNotchedRectangle().getOuterPath(
      host,
      button,
    );
    final roundedBarPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          host,
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
        ),
      );
    final path = Path.combine(
      PathOperation.intersect,
      notchedPath,
      roundedBarPath,
    );

    canvas.drawShadow(path, shadowColor, 12, true);
    canvas.drawPath(path, Paint()..color = background);
  }

  @override
  bool shouldRepaint(covariant NotchedBarPainter oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.background != background ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.activeButtonSize != activeButtonSize ||
        oldDelegate.activeVerticalOffset != activeVerticalOffset ||
        oldDelegate.activeButtonWidth != activeButtonWidth ||
        oldDelegate.activeButtonHeight != activeButtonHeight ||
        oldDelegate.notchMargin != notchMargin ||
        oldDelegate.notchInsets != notchInsets;
  }
}
