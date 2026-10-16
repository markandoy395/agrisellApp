import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';
import '../styles/rider_reference_styles.dart';

/// Vector artwork stays crisp at any density and does not add bundled images.
class RiderEmptyScenePainter extends CustomPainter {
  const RiderEmptyScenePainter({required this.delivery});
  final bool delivery;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 240, size.height / 150);
    void oval(Rect rect, Color color) =>
        canvas.drawOval(rect, RiderReferenceStyles.fill(color));
    void box(Rect rect, Color color, [double radius = 3]) => canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      RiderReferenceStyles.fill(color),
    );
    const pale = AgrisellColors.statusBlueBackground;
    oval(const Rect.fromLTWH(14, 48, 210, 93), AgrisellColors.pageBackground);
    oval(
      const Rect.fromLTWH(8, 131, 224, 12),
      AgrisellColors.statusBlueBackground,
    );
    if (!delivery) {
      box(const Rect.fromLTWH(67, 82, 92, 51), AgrisellColors.deliveryGray);
      box(const Rect.fromLTWH(61, 72, 92, 50), AgrisellColors.borderLine);
      for (var y = 80.0; y < 120; y += 13) {
        box(Rect.fromLTWH(65, y, 84, 2), AgrisellColors.deliveryGray);
      }
      for (var x = 74.0; x < 150; x += 62) {
        box(Rect.fromLTWH(x, 75, 3, 45), AgrisellColors.borderLine);
      }
      box(const Rect.fromLTWH(124, 40, 3, 44), AgrisellColors.deliveryGreen);
      oval(const Rect.fromLTWH(125, 26, 22, 40), AgrisellColors.deliveryGreen);
      oval(const Rect.fromLTWH(105, 41, 17, 26), AgrisellColors.forestSoft);
      oval(const Rect.fromLTWH(155, 67, 19, 30), AgrisellColors.deliveryGreen);
    } else {
      for (var x = 30.0; x < 210; x += 29) {
        box(Rect.fromLTWH(x, 59 - x % 27, 22, 74 + x % 27), pale);
      }
      _tree(canvas, 24, 84, AgrisellColors.accentBlue);
      _tree(canvas, 207, 105, AgrisellColors.deliveryGreen);
      for (final x in [91.0, 162.0]) {
        oval(
          Rect.fromCircle(center: Offset(x, 126), radius: 15),
          AgrisellColors.headingGreen,
        );
        oval(
          Rect.fromCircle(center: Offset(x, 126), radius: 8),
          AgrisellColors.deliveryGray,
        );
        oval(
          Rect.fromCircle(center: Offset(x, 126), radius: 3),
          AgrisellColors.mutedText,
        );
      }
      final body = Path()
        ..moveTo(76, 113)
        ..quadraticBezierTo(82, 95, 108, 101)
        ..lineTo(135, 116)
        ..lineTo(152, 96)
        ..lineTo(155, 81)
        ..lineTo(163, 83)
        ..lineTo(173, 116)
        ..lineTo(147, 128)
        ..lineTo(99, 128)
        ..close();
      canvas.drawPath(
        body,
        RiderReferenceStyles.fill(AgrisellColors.forestGreen),
      );
      box(const Rect.fromLTWH(86, 97, 45, 6), AgrisellColors.headingGreen);
      box(const Rect.fromLTWH(69, 86, 22, 23), AgrisellColors.deliveryGray);
      box(const Rect.fromLTWH(118, 97, 9, 21), AgrisellColors.headingGreen);
      box(const Rect.fromLTWH(121, 112, 22, 6), AgrisellColors.headingGreen);
      box(const Rect.fromLTWH(110, 72, 20, 27), AgrisellColors.limeGreen, 6);
      oval(const Rect.fromLTWH(120, 58, 13, 17), AgrisellColors.accentOrange);
      box(const Rect.fromLTWH(117, 57, 16, 6), AgrisellColors.authGreen);
      box(const Rect.fromLTWH(128, 83, 21, 5), AgrisellColors.limeGreen);
      box(const Rect.fromLTWH(148, 81, 14, 3), AgrisellColors.headingGreen);
      final pin = Path()
        ..moveTo(110, 14)
        ..cubicTo(88, 14, 91, 35, 110, 53)
        ..cubicTo(129, 35, 132, 14, 110, 14)
        ..close();
      canvas.drawPath(
        pin,
        RiderReferenceStyles.fill(AgrisellColors.accentOrange),
      );
      oval(const Rect.fromLTWH(104, 21, 12, 12), AgrisellColors.surface);
    }
    canvas.restore();
  }

  void _tree(Canvas canvas, double x, double y, Color color) {
    canvas.drawRect(
      Rect.fromLTWH(x, y, 2, 48),
      RiderReferenceStyles.fill(AgrisellColors.deliveryGreen),
    );
    canvas.drawOval(
      Rect.fromLTWH(x - 10, y - 19, 23, 42),
      RiderReferenceStyles.fill(color),
    );
  }

  @override
  bool shouldRepaint(RiderEmptyScenePainter oldDelegate) =>
      oldDelegate.delivery != delivery;
}
