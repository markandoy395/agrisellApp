import 'package:flutter/material.dart';

import '../styles/rider_profile_edit_styles.dart';
import 'rider_profile_edit_header.dart';

/// Keep the form stable while keyboard insets resize the sheet.
class RiderProfileEditLayout extends StatelessWidget {
  const RiderProfileEditLayout({
    required this.form,
    required this.actions,
    super.key,
  });

  final Widget form;
  final Widget actions;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height,
    child: SafeArea(
      child: Padding(
        padding: RiderProfileEditStyles.sheetPadding(context),
        child: Column(
          children: [
            const RiderProfileEditHeader(),
            RiderProfileEditStyles.spacingLarge,
            Expanded(child: SingleChildScrollView(child: form)),
            RiderProfileEditStyles.spacingLarge,
            actions,
          ],
        ),
      ),
    ),
  );
}
