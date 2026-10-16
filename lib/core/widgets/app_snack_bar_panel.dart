import 'package:flutter/material.dart';

import '../theme/app_snack_bar_styles.dart';

/// Inset presentation with Scaffold-managed placement above navigation/footer.
class AppSnackBarPanel extends StatelessWidget {
  const AppSnackBarPanel({
    required this.child,
    required this.onClose,
    this.backgroundColor,
    this.closeIconColor,
    this.action,
    this.showCloseIcon = true,
    super.key,
  });

  final Widget child;
  final VoidCallback onClose;
  final Color? backgroundColor;
  final Color? closeIconColor;
  final SnackBarAction? action;
  final bool showCloseIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final keyboardInset =
        Scaffold.maybeOf(context)?.widget.resizeToAvoidBottomInset == false
        ? media.viewInsets.bottom
        : 0.0;
    return Padding(
      padding: AppSnackBarStyles.margin(keyboardInset),
      child: Material(
        color:
            backgroundColor ??
            theme.snackBarTheme.backgroundColor ??
            theme.colorScheme.inverseSurface,
        borderRadius: AppSnackBarStyles.radius,
        child: Padding(
          padding: AppSnackBarStyles.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: AppSnackBarStyles.maxContentHeight(
                          MediaQuery.of(context),
                        ),
                      ),
                      child: SingleChildScrollView(
                        primary: false,
                        child: DefaultTextStyle.merge(
                          style: AppSnackBarStyles.contentText(theme),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                  if (showCloseIcon)
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: onClose,
                      color:
                          closeIconColor ??
                          theme.snackBarTheme.closeIconColor ??
                          theme.snackBarTheme.contentTextStyle?.color ??
                          theme.colorScheme.onInverseSurface,
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                ],
              ),
              if (action case final button?)
                Align(alignment: Alignment.centerRight, child: button),
            ],
          ),
        ),
      ),
    );
  }
}
