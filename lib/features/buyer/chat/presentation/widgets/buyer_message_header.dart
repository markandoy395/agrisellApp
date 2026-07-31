import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class BuyerMessageHeader extends StatelessWidget {
  const BuyerMessageHeader({
    required this.controller,
    required this.onQueryChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 14.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topInset + 14,
        horizontalPadding,
        14,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chats',
            style: TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Search farmers or products',
              hintStyle: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 13,
              ),
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
            ),
          ),
        ],
      ),
    );
  }
}
