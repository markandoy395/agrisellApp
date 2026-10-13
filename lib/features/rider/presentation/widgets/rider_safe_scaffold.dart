import 'package:flutter/material.dart';

/// Protects standalone rider content from system navigation in every mode.
class RiderSafeScaffold extends StatelessWidget {
  const RiderSafeScaffold({
    required this.body,
    this.appBar,
    this.backgroundColor,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    backgroundColor: backgroundColor,
    body: SafeArea(top: false, child: body),
  );
}
