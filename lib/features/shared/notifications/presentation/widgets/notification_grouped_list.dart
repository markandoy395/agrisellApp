import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/core/utils/notification_date_group.dart';

/// Builds only visible cards while preserving date group and source ordering.
class NotificationGroupedList<T> extends StatelessWidget {
  const NotificationGroupedList({
    required this.items,
    required this.dateOf,
    required this.itemBuilder,
    required this.padding,
    super.key,
  });

  final Iterable<T> items;
  final DateTime? Function(T) dateOf;
  final Widget Function(BuildContext, T) itemBuilder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final groups = <NotificationDateGroup, List<T>>{};
    for (final item in items) {
      final group = NotificationDateGroup.from(dateOf(item) ?? now, now: now);
      groups.putIfAbsent(group, () => []).add(item);
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverMainAxisGroup(
            slivers: [
              for (final group in NotificationDateGroup.values)
                if (groups[group] case final entries?) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                      child: Text(
                        group.label,
                        style: SharedPresentationStyles.headingBodyExtraBold,
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: itemBuilder(context, entries[index]),
                    ),
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
