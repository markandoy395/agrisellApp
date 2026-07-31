import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class MessageLabelPill extends StatelessWidget {
  const MessageLabelPill({
    required this.text,
    this.background = AgrisellColors.limeSoft,
    this.foreground = AgrisellColors.headingGreen,
    super.key,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
