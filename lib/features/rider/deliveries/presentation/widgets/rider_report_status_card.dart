import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_delivery_problem.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderReportStatusCard extends StatelessWidget {
  const RiderReportStatusCard({required this.report, super.key});

  final RiderDeliveryProblemReport report;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Row(
      children: [
        const Icon(
          Icons.support_agent_rounded,
          color: AgrisellColors.statusOrangeText,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Problem report',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${report.kind.label} - ${report.status.label}',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
