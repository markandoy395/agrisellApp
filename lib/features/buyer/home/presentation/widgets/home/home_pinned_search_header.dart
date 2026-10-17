import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_search_bar.dart';

class HomePinnedSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  HomePinnedSearchHeaderDelegate({
    required this.horizontalPadding,
    required this.bottomGap,
    required this.searchController,
    required this.activeFilterCount,
    required this.searchSuggestions,
    required this.onQueryChanged,
    required this.onFilterTap,
  }) : _child = ColoredBox(
         color: AgrisellColors.homeBackground,
         child: Padding(
           padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
           child: Align(
             alignment: Alignment.topCenter,
             child: HomeSearchBar(
               controller: searchController,
               activeFilterCount: activeFilterCount,
               suggestions: searchSuggestions,
               onChanged: onQueryChanged,
               onFilterTap: onFilterTap,
             ),
           ),
         ),
       );

  static const searchHeight = 48.0;

  final double horizontalPadding;
  final double bottomGap;
  final TextEditingController searchController;
  final int activeFilterCount;
  final List<String> searchSuggestions;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onFilterTap;
  final Widget _child;

  @override
  double get minExtent => searchHeight + bottomGap;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => _child;

  @override
  bool shouldRebuild(covariant HomePinnedSearchHeaderDelegate oldDelegate) {
    return oldDelegate.horizontalPadding != horizontalPadding ||
        oldDelegate.bottomGap != bottomGap ||
        oldDelegate.searchController != searchController ||
        oldDelegate.activeFilterCount != activeFilterCount ||
        !listEquals(oldDelegate.searchSuggestions, searchSuggestions) ||
        oldDelegate.onQueryChanged != onQueryChanged ||
        oldDelegate.onFilterTap != onFilterTap;
  }
}
