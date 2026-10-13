import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/system_ui_styles.dart';

abstract final class AgrisellSystemUi {
  static Future<void> applyAppSystemUi({Brightness? platformBrightness}) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiStyles.light);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}
