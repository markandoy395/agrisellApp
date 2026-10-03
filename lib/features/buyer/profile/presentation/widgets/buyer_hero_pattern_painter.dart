import 'package:flutter/material.dart';

class BuyerHeroPatternPainter extends CustomPainter {
  const BuyerHeroPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);

    // Large blurred circle — top-right
    canvas.drawCircle(
      Offset(size.width + 10, -20),
      110,
      paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // Leaf shape — bottom-left
    final leaf = Paint()..color = Colors.white.withValues(alpha: 0.055);
    final path1 = Path()
      ..moveTo(-20, size.height + 10)
      ..quadraticBezierTo(30, size.height - 60, 90, size.height - 20)
      ..quadraticBezierTo(50, size.height + 30, -20, size.height + 10)
      ..close();
    canvas.drawPath(path1, leaf);

    // Leaf shape — bottom-right
    final path2 = Path()
      ..moveTo(size.width - 60, size.height + 8)
      ..quadraticBezierTo(
        size.width - 20,
        size.height - 50,
        size.width + 20,
        size.height - 30,
      )
      ..quadraticBezierTo(
        size.width + 10,
        size.height + 20,
        size.width - 60,
        size.height + 8,
      )
      ..close();
    canvas.drawPath(path2, leaf);
  }

  @override
  bool shouldRepaint(covariant BuyerHeroPatternPainter oldDelegate) => false;
}
