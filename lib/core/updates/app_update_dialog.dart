import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_release.dart';

class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({required this.release, super.key});

  final AppRelease release;

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
      // Keep the dialog available so the user can retry or dismiss it.
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
    return AlertDialog(
      icon: const Icon(Icons.system_update_alt),
      title: const Text('Update available'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AgriSell ${release.version} is ready to download.'),
            if (release.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(release.notes),
            ],
            const SizedBox(height: 12),
            const Text(
              'Download the APK, open it, then tap Update in Android. '
              'You do not need to uninstall AgriSell.',
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, semanticsLabel: _error),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: _opening ? null : _download,
          child: Text(_opening ? 'Opening download…' : 'Update now'),
        ),
      ],
    );
  }
}
