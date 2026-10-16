import 'package:flutter/material.dart';
import 'rider_empty_scene_painter.dart';

class RiderEmptyIllustration extends StatelessWidget {
  const RiderEmptyIllustration({this.delivery = false, super.key});
  final bool delivery;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 240,
          height: delivery ? 150 : 140,
          child: CustomPaint(
            painter: RiderEmptyScenePainter(delivery: delivery),
          ),
        ),
      ),
    ),
  );
}
