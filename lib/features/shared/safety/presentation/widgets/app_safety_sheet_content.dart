import 'package:flutter/material.dart';

import '../styles/app_safety_sheet_styles.dart';

enum SafetySheetAction {
  sos,
  reportIncident,
  viewHistory,
  contactSupport,
}

class AppSafetySheetContent extends StatelessWidget {
  const AppSafetySheetContent({
    required this.onSelectAction,
    super.key,
  });

  final ValueChanged<SafetySheetAction> onSelectAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSafetySheetStyles.sheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.shield_rounded,
                  color: AppSafetySheetStyles.headerIconColor,
                  size: AppSafetySheetStyles.headerIconSize,
                ),
                AppSafetySheetStyles.spacingTitleIcon,
                Text(
                  'Safety & Emergency Support',
                  style: AppSafetySheetStyles.headerTitleStyle,
                ),
              ],
            ),
            AppSafetySheetStyles.spacingTitleSubtitle,
            const Text(
              'Get immediate assistance, report an incident, or track resolution status.',
              style: AppSafetySheetStyles.headerSubtitleStyle,
            ),
            AppSafetySheetStyles.spacingHeaderBottom,

            // Emergency SOS Button
            Container(
              decoration: AppSafetySheetStyles.sosContainerDecoration,
              child: Material(
                color: Colors.transparent,
                borderRadius: AppSafetySheetStyles.sosBorderRadius,
                child: ListTile(
                  leading: Container(
                    padding: AppSafetySheetStyles.sosIconPadding,
                    decoration: AppSafetySheetStyles.sosIconDecoration,
                    child: const Icon(
                      Icons.sos_rounded,
                      color: AppSafetySheetStyles.sosIconColor,
                      size: AppSafetySheetStyles.sosIconSize,
                    ),
                  ),
                  title: const Text(
                    'Emergency SOS',
                    style: AppSafetySheetStyles.sosTitleStyle,
                  ),
                  subtitle: const Text(
                    'Trigger immediate high-priority safety alert to dispatch & admins',
                    style: AppSafetySheetStyles.sosSubtitleStyle,
                  ),
                  onTap: () => onSelectAction(SafetySheetAction.sos),
                ),
              ),
            ),
            AppSafetySheetStyles.spacingSosBottom,

            // Report Incident
            ListTile(
              shape: AppSafetySheetStyles.tileShape,
              tileColor: AppSafetySheetStyles.tileBackground,
              leading: const Icon(
                Icons.report_problem_outlined,
                color: AppSafetySheetStyles.reportIconColor,
              ),
              title: const Text(
                'Report a Safety Issue / Incident',
                style: AppSafetySheetStyles.tileTitleStyle,
              ),
              subtitle: const Text(
                'Accidents, harassment, suspicious activity, or property risk',
              ),
              onTap: () => onSelectAction(SafetySheetAction.reportIncident),
            ),
            AppSafetySheetStyles.spacingTiles,

            // View Incident History & Status
            ListTile(
              shape: AppSafetySheetStyles.tileShape,
              tileColor: AppSafetySheetStyles.tileBackground,
              leading: const Icon(
                Icons.track_changes_rounded,
                color: AppSafetySheetStyles.historyIconColor,
              ),
              title: const Text(
                'Incident History & Resolution Status',
                style: AppSafetySheetStyles.tileTitleStyle,
              ),
              subtitle: const Text(
                'Track progress and view admin investigation notes',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onSelectAction(SafetySheetAction.viewHistory),
            ),
            AppSafetySheetStyles.spacingTiles,

            // Contact Support
            ListTile(
              shape: AppSafetySheetStyles.tileShape,
              tileColor: AppSafetySheetStyles.tileBackground,
              leading: const Icon(
                Icons.support_agent_rounded,
                color: AppSafetySheetStyles.supportIconColor,
              ),
              title: const Text(
                'Contact Customer Support',
                style: AppSafetySheetStyles.tileTitleStyle,
              ),
              subtitle: const Text(
                'Direct chat or helpline for non-emergency inquiries',
              ),
              onTap: () => onSelectAction(SafetySheetAction.contactSupport),
            ),
          ],
        ),
      ),
    );
  }
}
