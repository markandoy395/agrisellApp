import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class SummaryMetric extends StatelessWidget {
  const SummaryMetric({
    required this.label,
    required this.value,
    this.width = 90,
    super.key,
  });

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
