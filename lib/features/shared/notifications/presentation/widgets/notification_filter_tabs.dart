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
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant NotificationFilterTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    final index = NotificationFilter.values.indexOf(widget.selected);
    if (index == -1 || !_scrollController.hasClients) return;
    const approximateChipWidth = 80.0;
    final targetOffset = (index * approximateChipWidth) - 80.0;
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: NotificationFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = NotificationFilter.values[index];
          final isSelected = filter == widget.selected;
          return Semantics(
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
              labelStyle: TextStyle(
                color: isSelected
                    ? AgrisellColors.surface
                    : AgrisellColors.headingGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
