import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/profile/presentation/styles/profile_screen_styles.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

/// Reusable section title for buyer profile screen categories.
class BuyerSectionHeader extends StatelessWidget {
  const BuyerSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: ProfileScreenStyles.sectionHeaderPadding,
    child: Text(title, style: BuyerProfileStyle.sectionLabel),
  );
}

/// Interactive navigation row item with icon container, titles, and chevron.
class BuyerAccountTile extends StatelessWidget {
  const BuyerAccountTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: ProfileScreenStyles.tileRadius,
      child: Padding(
        padding: ProfileScreenStyles.tilePadding,
        child: Row(
          children: [
            Container(
              width: ProfileScreenStyles.iconBoxSize,
              height: ProfileScreenStyles.iconBoxSize,
              decoration: ProfileScreenStyles.iconBoxDecoration(
                destructive: destructive,
              ),
              child: Icon(
                icon,
                color: ProfileScreenStyles.tileIconColor(
                  destructive: destructive,
                ),
                size: ProfileScreenStyles.iconSize,
              ),
            ),
            const SizedBox(width: ProfileScreenStyles.iconTextGap),
            Expanded(
              child: hasSubtitle
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: ProfileScreenStyles.tileTitleStyle(
                            destructive: destructive,
                          ),
                        ),
                        const SizedBox(
                          height: ProfileScreenStyles.titleSubtitleGap,
                        ),
                        Text(subtitle!, style: BuyerProfileStyle.tileSubtitle),
                      ],
                    )
                  : Text(
                      title,
                      style: ProfileScreenStyles.tileTitleStyle(
                        destructive: destructive,
                      ),
                    ),
            ),
            const SizedBox(width: ProfileScreenStyles.chevronGap),
            Icon(
              Icons.chevron_right_rounded,
              color: ProfileScreenStyles.chevronColor(
                destructive: destructive,
              ),
              size: ProfileScreenStyles.chevronSize,
            ),
          ],
        ),
      ),
    );
  }
}
