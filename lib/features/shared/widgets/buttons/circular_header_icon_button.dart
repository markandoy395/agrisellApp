export 'package:agresell_app/features/shared/widgets/buttons/circular_header_icon_button_styles.dart';
import 'package:agresell_app/features/shared/widgets/buttons/circular_header_icon_button_styles.dart';
import 'package:flutter/material.dart';

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
    final button = switch (style.usesInkResponse) {
      false => SizedBox.square(
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
      true => InkResponse(
        onTap: onTap,
        radius: style.splashRadius,
        child: Container(
          width: style.dimension,
          height: style.dimension,
          decoration: CircularHeaderIconButtonStyles.containerDecoration(style),
          child: Icon(icon, color: style.iconColor, size: style.iconSize),
        ),
      ),
    };

    return Semantics(button: true, label: semanticLabel, child: button);
  }
}
