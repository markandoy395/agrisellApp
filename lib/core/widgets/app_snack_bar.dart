import 'package:flutter/material.dart';
import 'app_snack_bar_panel.dart';

const _appSnackBarDuration = Duration(seconds: 2);

extension AppSnackBarMessenger on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAppSnackBar(
    SnackBar snackBar, {
    Duration duration = _appSnackBarDuration,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
  }) {
    clearSnackBars();
    return showSnackBar(
      SnackBar(
        key: snackBar.key,
        content: AppSnackBarPanel(
          backgroundColor: snackBar.backgroundColor,
          closeIconColor: snackBar.closeIconColor,
          showCloseIcon: snackBar.showCloseIcon ?? true,
          action: snackBar.action,
          onClose: () => hideCurrentSnackBar(),
          child: snackBar.content,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        // The inset card stays within Scaffold's safe snackbar slot, even
        // when a tall FAB would push a floating snackbar off screen.
        behavior: behavior,
        margin: behavior == SnackBarBehavior.floating ? snackBar.margin : null,
        width: behavior == SnackBarBehavior.floating ? snackBar.width : null,
        actionOverflowThreshold: snackBar.actionOverflowThreshold,
        showCloseIcon: false,
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
