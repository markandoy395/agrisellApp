import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/waybills/presentation/styles/delivery_waybill_styles.dart';

/// Renders a labeled information box with an icon and multi-line content.
class WaybillInfoBox extends StatelessWidget {
  const WaybillInfoBox({
    required this.title,
    required this.icon,
    required this.lines,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: DeliveryWaybillStyles.infoBoxPadding,
    decoration: DeliveryWaybillStyles.infoBoxDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AgrisellColors.authGreen),
            const SizedBox(width: 4),
            Text(
              title.toUpperCase(),
              style: DeliveryWaybillStyles.infoBoxTitle,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...lines.map((line) => Text(
          line,
          style: DeliveryWaybillStyles.infoBoxLine,
        )),
      ],
    ),
  );
}
