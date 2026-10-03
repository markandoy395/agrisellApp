import 'package:agresell_app/features/buyer/home/presentation/styles/sold_overlay_styles.dart';
import 'package:flutter/material.dart';

class SoldOverlay extends StatelessWidget {
  const SoldOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: SoldOverlayStyles.decoratedBoxDecoration,
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
                            style: SoldOverlayStyles.soldText(
                              fontSize,
                              strokeWidth,
                            ),
                          ),
                          Text(
                            'SOLD',
                            style: SoldOverlayStyles.soldText2(fontSize),
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
