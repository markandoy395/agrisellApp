import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme/app_version_footer_styles.dart';

class AppVersionFooter extends StatefulWidget {
  const AppVersionFooter({super.key});

  @override
  State<AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<AppVersionFooter> {
  late final Future<String> _version = _loadVersion();

  Future<String> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.trim().isEmpty) return 'App version unavailable';
      return 'App version ${info.version}';
    } catch (_) {
      return 'App version unavailable';
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: AppVersionFooterStyles.padding,
    child: Center(
      child: FutureBuilder<String>(
        future: _version,
        builder: (context, snapshot) => Text(
          snapshot.data ?? 'Loading app version…',
          textAlign: TextAlign.center,
          style: AppVersionFooterStyles.label,
        ),
      ),
    ),
  );
}
