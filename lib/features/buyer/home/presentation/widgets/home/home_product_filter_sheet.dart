import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';

class HomeProductFilterSheet extends StatelessWidget {
  const HomeProductFilterSheet({
    required this.controller,
    required this.onReset,
    super.key,
  });

  final HomeProductBrowseController controller;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _SheetHandle()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filter products',
                        style: TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.hasActiveDiscoveryOptions
                          ? onReset
                          : null,
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _FilterSwitch(
                  title: 'Accepting orders',
                  subtitle: 'Show available and pre-order products',
                  value: controller.availableOnly,
                  onChanged: controller.setAvailableOnly,
                ),
                _FilterSwitch(
                  title: 'Saved products only',
                  subtitle: '${controller.savedCount} saved products',
                  value: controller.savedOnly,
                  onChanged: controller.setSavedOnly,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sort by',
                  style: TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in HomeProductSort.values)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: controller.sort == option,
                        onSelected: (_) => controller.setSort(option),
                        labelStyle: TextStyle(
                          color: controller.sort == option
                              ? AgrisellColors.surface
                              : AgrisellColors.brandBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedColor: AgrisellColors.authGreen,
                        backgroundColor: AgrisellColors.fieldFill,
                        side: BorderSide.none,
                        showCheckmark: false,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    width: 280,
                    height: 38,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AgrisellColors.authGreen,
                        foregroundColor: AgrisellColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Show products',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: AgrisellColors.mutedText.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  const _FilterSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: const TextStyle(
          color: AgrisellColors.brandBlack,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
      ),
      value: value,
      activeTrackColor: AgrisellColors.authGreen,
      onChanged: onChanged,
    );
  }
}
