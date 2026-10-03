import 'package:agresell_app/features/farmer/chat/presentation/styles/message_bottom_border_styles.dart';
import 'package:flutter/material.dart';

class MessageBottomBorder extends StatelessWidget {
  const MessageBottomBorder({
    required this.color,
    this.borderWidth = 4,
    this.radius = 8,
    super.key,
  });

  final Color color;
  final double borderWidth;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: borderWidth,
      child: DecoratedBox(
        decoration: MessageBottomBorderStyles.decoratedBoxDecoration(
          color,
          radius,
        ),
      ),
    );
  }
}
