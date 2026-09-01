import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

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
      height: 48,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AgrisellColors.authGreen.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: AgrisellColors.authGreen,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('home-product-search'),
              controller: widget.controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hint: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    _currentHint,
                    key: ValueKey(_currentHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                hintStyle: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                icon: const Icon(Icons.close_rounded, size: 19),
              );
            },
          ),
          Semantics(
            button: true,
            label: widget.activeFilterCount == 0
                ? 'Open product filters'
                : 'Open product filters, ${widget.activeFilterCount} active',
            child: InkWell(
              key: const ValueKey('home-product-filter-button'),
              onTap: widget.onFilterTap,
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AgrisellColors.authGreen,
                      size: 22,
                    ),
                    if (widget.activeFilterCount > 0)
                      Positioned(
                        right: 2,
                        top: 1,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: AgrisellColors.authGreen,
                          child: Text(
                            '${widget.activeFilterCount}',
                            style: const TextStyle(
                              color: AgrisellColors.surface,
                              fontSize: 12,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
