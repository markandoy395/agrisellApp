import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/core/models/home_bottom_nav_item.dart';

class CustomBottomNavTab extends StatelessWidget {
  const CustomBottomNavTab({
    required this.item,
    required this.isSelected,
    required this.activeBackground,
    required this.activeIconColor,
    required this.iconColor,
    required this.labelColor,
    required this.iconSize,
    required this.activeIconSize,
    required this.labelFontSize,
    required this.badgeCount,
    required this.duration,
    required this.curve,
    required this.onTap,
    super.key,
  });

  final HomeBottomNavItem item;
  final bool isSelected;
  final Color activeBackground;
  final Color activeIconColor;
  final Color iconColor;
  final Color labelColor;
  final double iconSize;
  final double activeIconSize;
  final double labelFontSize;
  final int badgeCount;
  final Duration duration;
  final Curve curve;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = badgeCount > 0
        ? '${item.label}, $badgeCount updates'
        : item.label;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavIcon(
                item: item,
                isSelected: isSelected,
                activeBackground: activeBackground,
                activeIconColor: activeIconColor,
                iconColor: iconColor,
                iconSize: iconSize,
                activeIconSize: activeIconSize,
                badgeCount: badgeCount,
                duration: duration,
                curve: curve,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: curve,
                style: TextStyle(
                  color: isSelected ? activeBackground : labelColor,
                  fontSize: labelFontSize,
                  height: 1,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.item,
    required this.isSelected,
    required this.activeBackground,
    required this.activeIconColor,
    required this.iconColor,
    required this.iconSize,
    required this.activeIconSize,
    required this.badgeCount,
    required this.duration,
    required this.curve,
  });

  final HomeBottomNavItem item;
  final bool isSelected;
  final Color activeBackground;
  final Color activeIconColor;
  final Color iconColor;
  final double iconSize;
  final double activeIconSize;
  final int badgeCount;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final size = activeIconSize.clamp(36.0, 42.0);
    final color = isSelected ? activeIconColor : iconColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: duration,
          curve: curve,
          width: size,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? activeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: _icon(color)),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -4,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AgrisellColors.authGreen,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AgrisellColors.surface, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: AgrisellColors.surface,
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _icon(Color color) {
    final iconData = isSelected ? item.activeIconData : item.iconData;
    if (iconData != null) {
      return Icon(iconData, size: iconSize, color: color);
    }

    return ResponsiveAssetImage(
      asset: isSelected ? item.activeIcon! : item.icon!,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
