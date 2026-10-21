import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_update_sheet_styles.dart';
import 'app_release.dart';

class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({required this.release, super.key});

  final AppRelease release;

  static Future<void> show(BuildContext context, AppRelease release) =>
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        isScrollControlled: true,
        showDragHandle: false,
        backgroundColor: AppUpdateSheetStyles.transparent,
        elevation: 0,
        constraints: AppUpdateSheetStyles.constraints,
        builder: (_) => AppUpdateDialog(release: release),
      );

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _opening = false;
  String? _error;

  Future<void> _download() async {
    setState(() {
      _opening = true;
      _error = null;
    });
    var opened = false;
    try {
      opened = await launchUrl(
        widget.release.apkUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Keep the sheet available so the user can retry or dismiss it.
    }
    if (!mounted) return;
    if (opened) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _opening = false;
        _error = 'Could not open the download. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final release = widget.release;
    return SafeArea(
      top: false,
      child: Padding(
        padding: AppUpdateSheetStyles.margin,
        child: Material(
          key: const ValueKey('app-update-card'),
          color: AppUpdateSheetStyles.surface,
          borderRadius: AppUpdateSheetStyles.borderRadius,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: AppUpdateSheetStyles.padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: AppUpdateSheetStyles.handleWidth,
                      height: AppUpdateSheetStyles.handleHeight,
                      decoration: AppUpdateSheetStyles.handleDecoration,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: AppUpdateSheetStyles.iconPadding,
                    decoration: AppUpdateSheetStyles.iconDecoration,
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      color: AppUpdateSheetStyles.iconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Update available',
                    style: AppUpdateSheetStyles.title,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AgriSell ${release.version} is ready to download.',
                    style: AppUpdateSheetStyles.body,
                  ),
                  if (release.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(release.notes, style: AppUpdateSheetStyles.body),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Download the APK, open it, then tap Update in Android. '
                    'You do not need to uninstall AgriSell.',
                    style: AppUpdateSheetStyles.hint,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(_error!, style: AppUpdateSheetStyles.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: AppUpdateSheetStyles.updateButton,
                      onPressed: _opening ? null : _download,
                      child: Text(
                        _opening ? 'Opening download…' : 'Update now',
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: AppUpdateSheetStyles.laterButton,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Later'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
