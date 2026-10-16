import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';
import '../../domain/rider_dashboard_state.dart';
import '../rider_environment_presentation.dart';
import '../styles/rider_home_design_styles.dart';

class RiderEnvironmentRow extends StatelessWidget {
  const RiderEnvironmentRow({
    required this.gps,
    required this.internet,
    super.key,
  });
  final RiderGpsStatus gps;
  final RiderInternetStatus internet;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      children: [
        const Divider(height: 1, color: AgrisellColors.borderLine),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 17,
              color: gps == RiderGpsStatus.ready
                  ? RiderHomeDesignStyles.green
                  : RiderHomeDesignStyles.red,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                gps == RiderGpsStatus.ready ? 'GPS On' : gps.displayLabel,
                style: RiderHomeDesignStyles.body,
              ),
            ),
            Icon(
              Icons.signal_cellular_alt_rounded,
              size: 17,
              color: internet == RiderInternetStatus.online
                  ? RiderHomeDesignStyles.green
                  : RiderHomeDesignStyles.muted,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                internet == RiderInternetStatus.online
                    ? 'Internet Connected'
                    : internet.displayLabel,
                style: RiderHomeDesignStyles.body,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
