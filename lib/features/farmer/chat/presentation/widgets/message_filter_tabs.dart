import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

enum FarmerMessageFilter { all, unread, orders, reserve }

extension FarmerMessageFilterText on FarmerMessageFilter {
  String get label {
    return switch (this) {
      FarmerMessageFilter.all => 'All',
      FarmerMessageFilter.unread => 'Unread',
      FarmerMessageFilter.orders => 'Orders',
      FarmerMessageFilter.reserve => 'Reserve',
    };
  }
}

class MessageFilterTabs extends StatelessWidget {
  const MessageFilterTabs({
    required this.activeFilter,
    required this.onChanged,
    super.key,
  });

  final FarmerMessageFilter activeFilter;
  final ValueChanged<FarmerMessageFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: FarmerMessageFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = FarmerMessageFilter.values[index];
          return _MessageFilterChip(
            filter: filter,
            isActive: filter == activeFilter,
            onTap: () => onChanged(filter),
          );
        },
      ),
    );
  }
}

class _MessageFilterChip extends StatelessWidget {
  const _MessageFilterChip({
    required this.filter,
    required this.isActive,
    required this.onTap,
  });

  final FarmerMessageFilter filter;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? AgrisellColors.authGreen
        : AgrisellColors.surface;
    final foreground = isActive
        ? AgrisellColors.surface
        : AgrisellColors.authGreen;

    return Semantics(
      button: true,
      selected: isActive,
      label: '${filter.label} messages',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AgrisellColors.authGreen),
          ),
          child: Text(
            filter.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
