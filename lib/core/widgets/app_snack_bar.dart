import 'package:flutter/material.dart';

const _appSnackBarDuration = Duration(seconds: 2);
const _appSnackBarMargin = EdgeInsets.fromLTRB(16, 0, 16, 16);

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
        margin: snackBar.margin ?? _appSnackBarMargin,
        padding: snackBar.padding,
        width: snackBar.width,
        shape: snackBar.shape,
        behavior: SnackBarBehavior.floating,
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
