import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class FarmerAccountButton extends StatelessWidget {
  const FarmerAccountButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 268,
        height: 38,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AgrisellColors.authGreen,
            foregroundColor: AgrisellColors.surface,
            elevation: 0,
            shape: const StadiumBorder(),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AgrisellColors.surface,
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
