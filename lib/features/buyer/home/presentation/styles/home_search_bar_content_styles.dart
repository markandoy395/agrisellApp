import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_search_bar_styles.dart';

abstract final class HomeSearchBarContentStyles {
  static InputDecoration inputDecoration(String placeholder) => InputDecoration(
    hint: AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Text(
        placeholder,
        key: ValueKey(placeholder),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    hintStyle: HomeSearchBarStyles.hintText,
    border: InputBorder.none,
    isDense: true,
    contentPadding: HomeSearchBarStyles.contentPadding,
  );
}
