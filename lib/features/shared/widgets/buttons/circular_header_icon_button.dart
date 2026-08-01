import 'package:flutter/material.dart';

class CircularHeaderIconButtonStyle {
  const CircularHeaderIconButtonStyle.inkWell({
    required this.dimension,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconSize,
  }) : _feedback = _CircularHeaderButtonFeedback.inkWell,
       splashRadius = 0;

  const CircularHeaderIconButtonStyle.inkResponse({
    required this.dimension,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconSize,
    required this.splashRadius,
  }) : _feedback = _CircularHeaderButtonFeedback.inkResponse;

  final double dimension;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final double splashRadius;
  final _CircularHeaderButtonFeedback _feedback;
}

class CircularHeaderIconButton extends StatelessWidget {
  const CircularHeaderIconButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
    required this.style,
    super.key,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;
  final CircularHeaderIconButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final button = switch (style._feedback) {
      _CircularHeaderButtonFeedback.inkWell => SizedBox.square(
        dimension: style.dimension,
        child: Material(
          color: style.backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, color: style.iconColor, size: style.iconSize),
          ),
        ),
      ),
      _CircularHeaderButtonFeedback.inkResponse => InkResponse(
        onTap: onTap,
        radius: style.splashRadius,
        child: Container(
          width: style.dimension,
          height: style.dimension,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: style.iconColor, size: style.iconSize),
        ),
      ),
    };

    return Semantics(button: true, label: semanticLabel, child: button);
  }
}

enum _CircularHeaderButtonFeedback { inkWell, inkResponse }
