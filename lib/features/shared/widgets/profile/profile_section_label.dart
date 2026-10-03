import 'package:agresell_app/features/shared/widgets/profile/profile_section_label_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ProfileSectionLabelStyles.decoratedBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(text, style: ProfileTextStyles.sectionLabel(context)),
      ),
    );
  }
}
