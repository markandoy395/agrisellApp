import 'package:flutter/material.dart';

const _appSnackBarDuration = Duration(seconds: 2);

extension AppSnackBarMessenger on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAppSnackBar(
    SnackBar snackBar, {
    Duration duration = _appSnackBarDuration,
  }) {
    clearSnackBars();
    return showSnackBar(
      SnackBar(
        key: snackBar.key,
        content: snackBar.content,
        backgroundColor: snackBar.backgroundColor,
        elevation: snackBar.elevation,
        padding: snackBar.padding,
        shape: snackBar.shape,
        // Floating placement can move off screen above a FAB or keyboard.
        // Fixed placement lets Scaffold reserve space for the message.
        behavior: SnackBarBehavior.fixed,
        action: snackBar.action,
        actionOverflowThreshold: snackBar.actionOverflowThreshold,
        showCloseIcon: snackBar.showCloseIcon,
        closeIconColor: snackBar.closeIconColor,
        duration: duration,
        persist: snackBar.persist,
        animation: snackBar.animation,
        onVisible: snackBar.onVisible,
        dismissDirection: snackBar.dismissDirection,
        clipBehavior: snackBar.clipBehavior,
      ),
    );
  }
}
