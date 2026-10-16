import 'package:flutter/material.dart';
import '../../data/rider_bottom_nav_items.dart';
import '../styles/rider_home_design_styles.dart';
import '../styles/rider_reference_styles.dart';

class RiderHomeBottomNav extends StatelessWidget {
  const RiderHomeBottomNav({
    required this.selectedIndex,
    required this.onSelected,
    this.messageCount = 0,
    super.key,
  });
  final int selectedIndex, messageCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: RiderReferenceStyles.nav,
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            for (var i = 0; i < riderBottomNavItems.length; i++)
              Expanded(
                child: _RiderNavTab(
                  index: i,
                  selected: selectedIndex == i,
                  count: i == 3 ? messageCount : 0,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _RiderNavTab extends StatelessWidget {
  const _RiderNavTab({
    required this.index,
    required this.selected,
    required this.count,
    required this.onTap,
  });
  final int index, count;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final item = riderBottomNavItems[index];
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 28,
              height: 2,
              decoration: RiderReferenceStyles.indicator(selected),
            ),
            const SizedBox(height: 7),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? item.activeIconData : item.iconData,
                  size: 23,
                  color: selected
                      ? RiderReferenceStyles.green
                      : RiderReferenceStyles.muted,
                ),
                if (count > 0)
                  Positioned(
                    top: -5,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: RiderHomeDesignStyles.badge,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: RiderHomeDesignStyles.badgeText,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RiderReferenceStyles.navLabel(selected),
            ),
          ],
        ),
      ),
    );
  }
}
