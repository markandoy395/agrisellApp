import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_profile_design_styles.dart';

class RiderProfileCard extends StatelessWidget {
  const RiderProfileCard({required this.child, this.soft = false, super.key});
  final Widget child;
  final bool soft;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: soft
        ? RiderProfileDesignStyles.softCard
        : RiderProfileDesignStyles.card,
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class RiderProfileSection extends StatelessWidget {
  const RiderProfileSection({
    required this.title,
    required this.icon,
    required this.children,
    this.action,
    super.key,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? action;
  @override
  Widget build(BuildContext context) => RiderProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AgrisellColors.authGreen, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: RiderProfileDesignStyles.title)),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

class RiderProfileDetailRow extends StatelessWidget {
  const RiderProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = AgrisellColors.authGreen,
    super.key,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 23, color: iconColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: RiderProfileDesignStyles.body),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: RiderProfileDesignStyles.muted,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class RiderProfileHeader extends StatelessWidget {
  const RiderProfileHeader({this.onSettings, this.onBack, super.key});
  final VoidCallback? onSettings;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderProfileDesignStyles.header,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 12, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (onBack != null)
                  IconButton(
                    tooltip: 'Back to profile',
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AgrisellColors.surface,
                    ),
                  ),
                Expanded(
                  child: Text(
                    'Rider profile',
                    style: RiderProfileDesignStyles.whiteHeading,
                  ),
                ),
                if (onSettings != null)
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: onSettings,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AgrisellColors.surface,
                      size: 27,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Account, vehicle, documents, and safety',
              style: RiderProfileDesignStyles.whiteSubtitle,
            ),
          ],
        ),
      ),
    ),
  );
}
