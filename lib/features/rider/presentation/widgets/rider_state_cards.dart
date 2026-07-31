import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class RiderEmptyStateCard extends StatelessWidget {
  const RiderEmptyStateCard({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _RiderStateCard(
    title: title,
    message: message,
    icon: icon,
    accentColor: AgrisellColors.forestGreen,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

class RiderLoadingStateCard extends StatelessWidget {
  const RiderLoadingStateCard({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => _RiderStateCard(
    title: title,
    message: message,
    icon: Icons.sync_rounded,
    accentColor: AgrisellColors.forestGreen,
    isLoading: true,
  );
}

class RiderErrorStateCard extends StatelessWidget {
  const RiderErrorStateCard({
    required this.title,
    required this.message,
    this.retryLabel,
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _RiderStateCard(
    title: title,
    message: message,
    icon: Icons.error_outline_rounded,
    accentColor: AgrisellColors.statusRedText,
    actionLabel: retryLabel,
    onAction: onRetry,
  );
}

class _RiderStateCard extends StatelessWidget {
  const _RiderStateCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;

    return Semantics(
      liveRegion: isLoading,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AgrisellColors.borderLine),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StateIcon(icon: icon, color: accentColor, isLoading: isLoading),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasAction) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: Text(actionLabel!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: BorderSide(color: accentColor),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  final IconData icon;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoading
          ? SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(color: color, strokeWidth: 3),
            )
          : Icon(icon, color: color, size: 26),
    );
  }
}
