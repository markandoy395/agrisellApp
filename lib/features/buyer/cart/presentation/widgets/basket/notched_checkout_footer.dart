import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Shared sticky purchase footer used by the basket and checkout screens.
///
/// The historical class name is retained to avoid breaking callers, while the
/// visual treatment is now a compact order-summary surface instead of a notch.
class NotchedCheckoutFooter extends StatelessWidget {
  const NotchedCheckoutFooter({
    required this.leading,
    required this.actionLabel,
    required this.enabled,
    required this.onActionTap,
    super.key,
  });

  static const barHeight = 88.0;

  final Widget leading;
  final String actionLabel;
  final bool enabled;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final brightness = MediaQuery.of(context).platformBrightness;

    return ColoredBox(
      color: AgrisellColors.systemNavigationBar(brightness),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Material(
          color: AgrisellColors.surface,
          elevation: 16,
          shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.18),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: barHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final actionWidth = (constraints.maxWidth * 0.39).clamp(
                  118.0,
                  168.0,
                );
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
                  child: Row(
                    children: [
                      Expanded(child: leading),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: actionWidth,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: enabled ? onActionTap : null,
                          style: ElevatedButton.styleFrom(
                            elevation: enabled ? 2 : 0,
                            shadowColor: AgrisellColors.forestDark.withValues(
                              alpha: 0.24,
                            ),
                            backgroundColor: AgrisellColors.authGreen,
                            disabledBackgroundColor:
                                AgrisellColors.deliveryGray,
                            foregroundColor: AgrisellColors.surface,
                            disabledForegroundColor: AgrisellColors.mutedText,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  actionLabel,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
