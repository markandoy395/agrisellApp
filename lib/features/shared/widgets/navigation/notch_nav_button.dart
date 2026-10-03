import 'package:agresell_app/features/shared/widgets/navigation/notch_nav_button_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/responsive_asset_image.dart';

class NotchNavButton extends StatefulWidget {
  const NotchNavButton({
    required this.index,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.icon,
    this.iconData,
    this.label,
    this.enabled = true,
    this.size = 56,
    this.width,
    this.height,
    this.borderRadius,
    this.verticalOffset = -10,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
    super.key,
  }) : assert(icon != null || iconData != null || label != null);

  final String? icon;
  final IconData? iconData;
  final String? label;
  final int index;
  final bool enabled;
  final double size;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double verticalOffset;
  final Duration duration;
  final Curve curve;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  State<NotchNavButton> createState() => _NotchNavButtonState();
}

class _NotchNavButtonState extends State<NotchNavButton> {
  var _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = widget.width ?? widget.size;
    final buttonHeight = widget.height ?? widget.size;
    final borderRadius = widget.borderRadius;

    return Transform.translate(
      offset: Offset(0, widget.verticalOffset),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapCancel: widget.enabled ? () => _setPressed(false) : null,
        onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: DecoratedBox(
              decoration: NotchNavButtonStyles.decoratedBoxDecoration(
                widget.background,
                borderRadius,
              ),
              child: _ButtonClip(
                borderRadius: borderRadius,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 120),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _NotchNavButtonContent(
                      key: ValueKey(
                        '${widget.index}-${widget.icon}-${widget.iconData?.codePoint}-${widget.label}',
                      ),
                      icon: widget.icon,
                      iconData: widget.iconData,
                      label: widget.label,
                      size: widget.size,
                      color: widget.iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonClip extends StatelessWidget {
  const _ButtonClip({required this.borderRadius, required this.child});

  final BorderRadius? borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius;
    if (borderRadius == null) {
      return ClipOval(child: child);
    }

    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}

class _NotchNavButtonContent extends StatelessWidget {
  const _NotchNavButtonContent({
    required this.icon,
    required this.iconData,
    required this.label,
    required this.size,
    required this.color,
    super.key,
  });

  final String? icon;
  final IconData? iconData;
  final String? label;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: size * 0.12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: NotchNavButtonStyles.labelText(color),
          ),
        ),
      );
    }

    final iconData = this.iconData;
    if (iconData != null) {
      return Icon(iconData, size: size * 0.5, color: color);
    }

    return ResponsiveAssetImage(
      asset: icon!,
      width: size * 0.5,
      height: size * 0.5,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
