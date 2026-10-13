import 'package:flutter/material.dart';

/// Keep vehicle actions clear of gesture and three-button system navigation.
class RiderVehicleContent extends StatelessWidget {
  const RiderVehicleContent({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(14),
      children: children,
    ),
  );
}
