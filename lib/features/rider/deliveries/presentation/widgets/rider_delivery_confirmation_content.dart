import 'package:flutter/material.dart';

import '../styles/rider_delivery_confirmation_styles.dart';

/// Keeps the form and its final action above system navigation and the keyboard.
class RiderDeliveryConfirmationContent extends StatelessWidget {
  const RiderDeliveryConfirmationContent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ListView(
        padding: RiderDeliveryConfirmationStyles.listPadding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [child],
      ),
    ),
  );
}
