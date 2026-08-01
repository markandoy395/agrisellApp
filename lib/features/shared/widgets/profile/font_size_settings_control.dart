import 'package:flutter/material.dart';

import 'package:agresell_app/core/services/app_font_size_controller.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

/// A shared display setting used by buyer, farmer, and rider accounts.
class FontSizeSettingsControl extends StatelessWidget {
  const FontSizeSettingsControl({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppFontSizeController.instance,
      builder: (context, _) {
        final controller = AppFontSizeController.instance;
        return Semantics(
          label: 'Font size, ${controller.percentageLabel}',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AgrisellColors.authGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox.square(
                    dimension: 34,
                    child: Icon(
                      Icons.format_size_rounded,
                      color: AgrisellColors.authGreen,
                      size: 19,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Font size',
                        style: ProfileTextStyles.infoLabel(context).copyWith(
                          color: AgrisellColors.brandBlack,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${controller.displayLabel} (${controller.percentageLabel})',
                        style: ProfileTextStyles.profileDescription(
                          context,
                        ).copyWith(fontSize: 12, height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _FontSizeButton(
                  tooltip: 'Decrease font size',
                  icon: Icons.remove_rounded,
                  onPressed: controller.canDecrease
                      ? controller.decrease
                      : null,
                ),
                const SizedBox(width: 2),
                _FontSizeButton(
                  tooltip: 'Increase font size',
                  icon: Icons.add_rounded,
                  onPressed: controller.canIncrease
                      ? controller.increase
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      color: AgrisellColors.authGreen,
      disabledColor: AgrisellColors.mutedText.withValues(alpha: 0.45),
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
    );
  }
}
