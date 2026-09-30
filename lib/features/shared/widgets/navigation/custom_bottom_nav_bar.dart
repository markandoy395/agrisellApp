import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/models/home_bottom_nav_item.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_tab.dart';

export 'package:agresell_app/core/models/home_bottom_nav_item.dart';
export 'package:agresell_app/features/shared/widgets/navigation/notch_nav_button.dart';

class CustomBottomNavBar extends StatelessWidget {
  static const defaultHeight = 68.0;
  static const verticalMargin = 8.0;

  static double clearanceFor(BuildContext context) {
    return defaultHeight +
        (verticalMargin * 2) +
        MediaQuery.paddingOf(context).bottom;
  }

  const CustomBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.background,
    required this.activeBackground,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.inactiveLabelColor,
    required this.shadowColor,
    this.badgeCounts = const {},
    this.height = defaultHeight,
    this.activeButtonSize = 40,
    this.activeVerticalOffset = 0,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
    this.inactiveIconSize = 24,
    this.labelFontSize = 12,
    super.key,
  }) : assert(items.length > 0),
       assert(selectedIndex >= 0),
       assert(selectedIndex < items.length);

  final List<HomeBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color background;
  final Color activeBackground;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color inactiveLabelColor;
  final Color shadowColor;
  final Map<int, int> badgeCounts;
  final double height;
  final double activeButtonSize;
  final double activeVerticalOffset;
  final Duration duration;
  final Curve curve;
  final double inactiveIconSize;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final systemBarColor = AgrisellColors.systemNavigationBar(brightness);
    final horizontalMargin = MediaQuery.sizeOf(context).width < 360
        ? 8.0
        : 12.0;

    return ColoredBox(
      color: systemBarColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalMargin,
          verticalMargin,
          horizontalMargin,
          bottomInset + verticalMargin,
        ),
        child: Material(
          color: background,
          elevation: 0,
          shadowColor: shadowColor,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++)
                  Expanded(
                    child: CustomBottomNavTab(
                      item: items[index],
                      isSelected: index == selectedIndex,
                      activeBackground: activeBackground,
                      activeIconColor: activeIconColor,
                      iconColor: inactiveIconColor,
                      labelColor: inactiveLabelColor,
                      iconSize: inactiveIconSize,
                      activeIconSize: activeButtonSize,
                      labelFontSize: labelFontSize,
                      badgeCount: badgeCounts[index] ?? 0,
                      duration: duration,
                      curve: curve,
                      onTap: () => onItemSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
