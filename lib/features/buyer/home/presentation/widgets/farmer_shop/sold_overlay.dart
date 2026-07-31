import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class SoldOverlay extends StatelessWidget {
  const SoldOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.18),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final shortestSide = constraints.biggest.shortestSide;
              final fontSize = (width * 0.28).clamp(36.0, 58.0);
              final strokeWidth = (fontSize * 0.12).clamp(4.8, 7.2);

              return Center(
                child: Transform.rotate(
                  angle: -0.52,
                  child: SizedBox(
                    width: width * 0.9,
                    height: shortestSide * 0.36,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'SOLD',
                            style: TextStyle(
                              fontSize: fontSize,
                              height: 1,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = strokeWidth
                                ..color = AgrisellColors.brandBlack,
                            ),
                          ),
                          Text(
                            'SOLD',
                            style: TextStyle(
                              color: AgrisellColors.surface,
                              fontSize: fontSize,
                              height: 1,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: AgrisellColors.brandBlack.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
