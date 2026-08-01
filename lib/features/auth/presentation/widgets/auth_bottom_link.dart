import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

class AuthBottomLink extends StatelessWidget {
  const AuthBottomLink({
    required this.label,
    required this.action,
    required this.onTap,
    super.key,
  });

  final String label;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 32,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: lerpDouble(12, 14, scale),
              fontWeight: FontWeight.w400,
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AgrisellColors.authGreen,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: TextStyle(
                fontSize: lerpDouble(13, 15, scale),
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
