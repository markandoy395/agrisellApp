import 'package:flutter/material.dart';
import 'rider_environment_row.dart';
import '../styles/rider_home_design_styles.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/rider_availability_warning_presentation.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_availability_card_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_availability_switch.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_availability_warning_banner.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_shift_copy.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_shift_icon.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_temporary_data_notice.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderAvailabilityCard extends StatelessWidget {
  const RiderAvailabilityCard({required this.controller, super.key});

  final RiderAvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final availability = controller.displayedAvailability;
    final warning = controller.warning;
    return RiderSurfaceCard(
      decoration: RiderHomeDesignStyles.card,
      padding: RiderAvailabilityCardStyles.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RiderShiftIcon(availability: availability),
              const SizedBox(width: 12),
              Expanded(
                child: RiderShiftCopy(
                  availability: availability,
                  gpsStatus: controller.gpsStatus,
                  internetStatus: controller.internetStatus,
                ),
              ),
              const SizedBox(width: 10),
              RiderAvailabilitySwitch(
                isOnline: availability.isOnline,
                isBusy: controller.isBusy,
                onChanged: (value) => _setAvailability(context, value),
              ),
            ],
          ),
          RiderEnvironmentRow(
            gps: controller.gpsStatus,
            internet: controller.internetStatus,
          ),
          if (controller.usesTemporaryData) ...[
            const SizedBox(height: 10),
            const RiderTemporaryDataNotice(),
          ],
          if (warning != null) ...[
            const SizedBox(height: 12),
            RiderAvailabilityWarningBanner(
              message: warning.displayMessage,
              onDismissed: controller.clearWarning,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setAvailability(BuildContext context, bool value) async {
    final result = await controller.setOnline(value);
    if (!context.mounted || !result.isSuccess) return;
    final label = controller.availability == RiderAvailability.offline
        ? 'You are now offline.'
        : 'Availability updated to ${controller.availability.displayLabel}.';
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(label)));
  }
}
