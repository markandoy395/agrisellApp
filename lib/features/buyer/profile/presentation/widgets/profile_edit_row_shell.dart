import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class ProfileEditRow extends StatelessWidget {
  const ProfileEditRow({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final labelWidth = MediaQuery.sizeOf(context).width < 380 ? 78.0 : 96.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: ProfileTextStyles.infoLabel(context),
            ),
          ),
          const SizedBox(width: 8),
          Text(':', style: ProfileTextStyles.infoLabel(context)),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ProfileEditPill extends StatelessWidget {
  const ProfileEditPill({
    required this.child,
    this.horizontalPadding = 12,
    super.key,
  });

  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: AgrisellColors.fieldFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
