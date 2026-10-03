import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

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
        Text(value, style: SharedPresentationStyles.headingBodyExtraBold),
        Text(label, style: SharedPresentationStyles.mutedCaptionSemibold),
      ],
    ),
  );
}
