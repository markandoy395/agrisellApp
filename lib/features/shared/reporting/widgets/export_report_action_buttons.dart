import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/export_report_sheet_styles.dart';

class ExportReportActionButtons extends StatelessWidget {
  const ExportReportActionButtons({
    required this.isCopied,
    required this.isSaving,
    required this.onCopy,
    required this.onSave,
    super.key,
  });

  final bool isCopied;
  final bool isSaving;
  final VoidCallback onCopy;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ExportReportSheetStyles.footerPadding,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCopy,
              icon: Icon(
                isCopied ? Icons.check_rounded : Icons.copy_rounded,
                size: ExportReportSheetStyles.actionButtonIconSize,
              ),
              label: Text(isCopied ? 'Copied' : 'Copy CSV'),
              style: ExportReportSheetStyles.copyButtonStyle,
            ),
          ),
          const SizedBox(width: ExportReportSheetStyles.buttonGap),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: ExportReportSheetStyles.loadingIndicatorSize,
                      height: ExportReportSheetStyles.loadingIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth:
                            ExportReportSheetStyles.loadingIndicatorStroke,
                        color: AgrisellColors.surface,
                      ),
                    )
                  : const Icon(
                      Icons.download_rounded,
                      size: ExportReportSheetStyles.actionButtonIconSize,
                    ),
              label: Text(isSaving ? 'Saving...' : 'Save CSV to Device'),
              style: ExportReportSheetStyles.saveButtonStyle,
            ),
          ),
        ],
      ),
    );
  }
}
