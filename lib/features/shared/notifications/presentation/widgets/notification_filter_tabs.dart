import 'package:agresell_app/features/shared/notifications/presentation/styles/notification_filter_tabs_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';

class NotificationFilterTabs extends StatefulWidget {
  const NotificationFilterTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  State<NotificationFilterTabs> createState() => _NotificationFilterTabsState();
}

class _NotificationFilterTabsState extends State<NotificationFilterTabs> {
  final _tabKeys = {
    for (final filter in NotificationFilter.values) filter: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scrollToSelected();
  }

  @override
  void didUpdateWidget(covariant NotificationFilterTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tabContext = _tabKeys[widget.selected]?.currentContext;
      if (tabContext == null) return;
      // Only move the horizontal strip, leaving the feed's scroll intact.
      Scrollable.of(tabContext).position.ensureVisible(
        tabContext.findRenderObject()!,
        alignment: 0.5,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NotificationFilter.values.map((filter) {
          final isSelected = filter == widget.selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              key: _tabKeys[filter],
              button: true,
              selected: isSelected,
              label: 'Show ${filter.label.toLowerCase()} notifications',
              child: ChoiceChip(
                label: Text(filter.label),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) => widget.onSelected(filter),
                backgroundColor: AgrisellColors.surface,
                selectedColor: AgrisellColors.authGreen,
                side: BorderSide(
                  color: isSelected
                      ? AgrisellColors.authGreen
                      : AgrisellColors.borderLine,
                ),
                labelStyle: NotificationFilterTabsStyles.textStyle(isSelected),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
