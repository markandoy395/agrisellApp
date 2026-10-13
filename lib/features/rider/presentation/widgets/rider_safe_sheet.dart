import 'package:flutter/material.dart';

/// Keeps sheet content scrollable above device navigation and the keyboard.
class RiderSafeSheet extends StatelessWidget {
  const RiderSafeSheet({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(child: child),
    ),
  );
}
