import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

abstract final class AgrisellSystemUi {
  static Future<void> applyAppSystemUi({Brightness? platformBrightness}) async {
    final brightness =
        platformBrightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final navigationBarColor = AgrisellColors.systemNavigationBar(brightness);
    final navigationBarIconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: navigationBarIconBrightness,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
    );

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}
