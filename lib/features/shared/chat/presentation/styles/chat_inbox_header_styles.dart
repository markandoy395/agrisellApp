import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ChatInboxHeaderStyles {
  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
  );

  static InputDecoration inputDecoration(
    String searchHint,
    TextEditingController controller,
    void Function(String) onQueryChanged,
  ) => InputDecoration(
    hintText: searchHint,
    hintStyle: const TextStyle(color: AgrisellColors.mutedText, fontSize: 13),
    prefixIcon: const Icon(Icons.search_rounded, size: 21),
    suffixIcon: ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return IconButton(
          onPressed: () {
            controller.clear();
            onQueryChanged('');
          },
          tooltip: 'Clear search',
          icon: const Icon(Icons.close_rounded, size: 20),
        );
      },
    ),
    filled: true,
    fillColor: AgrisellColors.fieldFill,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
  );
}
