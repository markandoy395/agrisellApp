import 'package:agresell_app/features/shared/notifications/presentation/styles/notification_state_view_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class NotificationStateView extends StatelessWidget {
  const NotificationStateView({
    required this.icon,
    required this.title,
    this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          liveRegion: isLoading,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(22),
            decoration: NotificationStateViewStyles.containerDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: NotificationStateViewStyles.containerDecoration2,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AgrisellColors.authGreen,
                          ),
                        )
                      : Icon(icon, color: AgrisellColors.authGreen, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: SharedPresentationStyles.headingTitleExtraBold,
                ),
                if (message case final text? when text.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: NotificationStateViewStyles.textText,
                  ),
                ],
                if (hasAction) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
