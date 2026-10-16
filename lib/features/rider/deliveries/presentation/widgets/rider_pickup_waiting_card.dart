import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_pickup_design_styles.dart';

class RiderPickupWaitingCard extends StatefulWidget {
  const RiderPickupWaitingCard({required this.startedAt, super.key});
  final DateTime startedAt;
  @override
  State<RiderPickupWaitingCard> createState() => _RiderPickupWaitingCardState();
}

class _RiderPickupWaitingCardState extends State<RiderPickupWaitingCard> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startedAt);
    final seconds = elapsed.isNegative ? 0 : elapsed.inSeconds;
    final label =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: RiderPickupDesignStyles.tint(AgrisellColors.statusRedText),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: AgrisellColors.statusRedText,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup waiting time',
                  style: RiderPickupDesignStyles.title,
                ),
                Text(label, style: RiderPickupDesignStyles.timer),
                Text(
                  'This will be recorded as your waiting time.',
                  style: RiderPickupDesignStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
