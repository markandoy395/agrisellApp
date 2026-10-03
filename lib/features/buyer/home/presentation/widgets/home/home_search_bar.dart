import 'package:agresell_app/features/buyer/home/presentation/styles/home_search_bar_content_styles.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_search_bar_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_search_filter_button.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.activeFilterCount = 0,
    this.suggestions = const [],
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final int activeFilterCount;
  final List<String> suggestions;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  static const _defaultHint = 'Search in AgriSell';
  static const _rotationDelay = Duration(seconds: 3);
  static const _fallbackHints = <String>[
    'Search fresh vegetables',
    'Search fruits near you',
    'Search local farm products',
    'Search today\'s harvest',
  ];

  final Random _random = Random();
  Timer? _rotationTimer;
  String _currentHint = _defaultHint;

  @override
  void initState() {
    super.initState();
    _scheduleRotation();
  }

  @override
  void didUpdateWidget(covariant HomeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        !listEquals(oldWidget.suggestions, widget.suggestions)) {
      _scheduleRotation();
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _scheduleRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer(_rotationDelay, _rotateHint);
  }

  void _rotateHint() {
    if (!mounted) return;

    if (widget.controller.text.isEmpty) {
      final hints = _availableHints;
      final alternatives = hints
          .where((hint) => hint != _currentHint)
          .toList(growable: false);
      if (alternatives.isNotEmpty) {
        setState(() {
          _currentHint = alternatives[_random.nextInt(alternatives.length)];
        });
      }
    }

    _scheduleRotation();
  }

  List<String> get _availableHints {
    final productHints = widget.suggestions
        .map((suggestion) => suggestion.trim())
        .where((suggestion) => suggestion.isNotEmpty)
        .map((suggestion) => 'Search for $suggestion')
        .toSet()
        .take(8);
    return <String>{...productHints, ..._fallbackHints}.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HomeSearchBarStyles.searchBarHeight,
      decoration: HomeSearchBarStyles.searchBarDecoration,
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: AgrisellColors.authGreen,
            size: HomeSearchBarStyles.searchIconSize,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('home-product-search'),
              controller: widget.controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: HomeSearchBarStyles.searchText,
              decoration: HomeSearchBarContentStyles.inputDecoration(
                _currentHint,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
                tooltip: 'Clear product search',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  size: HomeSearchBarStyles.clearIconSize,
                ),
              );
            },
          ),
          HomeSearchFilterButton(
            onTap: widget.onFilterTap,
            activeFilterCount: widget.activeFilterCount,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
