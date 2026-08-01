import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderDeliveryWaitingSummary extends StatefulWidget {
  const RiderDeliveryWaitingSummary({
    required this.startedAt,
    required this.instructions,
    super.key,
  });

  final DateTime startedAt;
  final String instructions;

  @override
  State<RiderDeliveryWaitingSummary> createState() =>
      _RiderDeliveryWaitingSummaryState();
}

class _RiderDeliveryWaitingSummaryState
    extends State<RiderDeliveryWaitingSummary> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startedAt);
    final minutes = elapsed.isNegative ? 0 : elapsed.inMinutes;
    return RiderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waiting at delivery location • $minutes min',
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.instructions.trim().isEmpty
                ? 'Contact the Buyer if handover is delayed.'
                : widget.instructions,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
