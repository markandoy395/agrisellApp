import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/rider_availability_warning_presentation.dart';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShiftIcon(availability: availability),
              const SizedBox(width: 12),
              Expanded(
                child: _ShiftCopy(
                  availability: availability,
                  gpsStatus: controller.gpsStatus,
                  internetStatus: controller.internetStatus,
                ),
              ),
              const SizedBox(width: 10),
              _AvailabilitySwitch(
                isOnline: availability.isOnline,
                isBusy: controller.isBusy,
                onChanged: (value) => _setAvailability(context, value),
              ),
            ],
          ),
          if (controller.usesTemporaryData) ...[
            const SizedBox(height: 10),
            const _TemporaryDataNotice(),
          ],
          if (warning != null) ...[
            const SizedBox(height: 12),
            _AvailabilityWarning(
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

class _ShiftIcon extends StatelessWidget {
  const _ShiftIcon({required this.availability});

  final RiderAvailability availability;

  @override
  Widget build(BuildContext context) {
    final color = availability.canReceiveRequests
        ? AgrisellColors.statusGreenText
        : availability.isHandlingDelivery
        ? AgrisellColors.statusBlueText
        : AgrisellColors.mutedText;
    final background = availability.canReceiveRequests
        ? AgrisellColors.statusGreenBackground
        : availability.isHandlingDelivery
        ? AgrisellColors.statusBlueBackground
        : AgrisellColors.deliveryGray.withValues(alpha: 0.75);
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(availability.icon, color: color, size: 25),
    );
  }
}

class _ShiftCopy extends StatelessWidget {
  const _ShiftCopy({
    required this.availability,
    required this.gpsStatus,
    required this.internetStatus,
  });

  final RiderAvailability availability;
  final RiderGpsStatus gpsStatus;
  final RiderInternetStatus internetStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work status',
          style: TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 15,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${_availabilityLabel(availability)} - '
          '${_gpsLabel(gpsStatus)} - '
          '${_internetLabel(internetStatus)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AvailabilitySwitch extends StatelessWidget {
  const _AvailabilitySwitch({
    required this.isOnline,
    required this.isBusy,
    required this.onChanged,
  });

  final bool isOnline;
  final bool isBusy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isOnline ? 'Go offline' : 'Go online',
      button: true,
      child: Switch.adaptive(
        value: isOnline,
        activeThumbColor: AgrisellColors.authGreen,
        activeTrackColor: AgrisellColors.forestSoft,
        onChanged: isBusy ? null : onChanged,
      ),
    );
  }
}

class _TemporaryDataNotice extends StatelessWidget {
  const _TemporaryDataNotice();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.statusOrangeBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AgrisellColors.statusOrangeText,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Availability is using local fallback data.',
                style: TextStyle(
                  color: AgrisellColors.statusOrangeText,
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityWarning extends StatelessWidget {
  const _AvailabilityWarning({
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgrisellColors.statusOrangeBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AgrisellColors.statusOrangeText,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AgrisellColors.statusOrangeText,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Dismiss warning',
            onPressed: onDismissed,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    ),
  );
}

String _availabilityLabel(RiderAvailability availability) =>
    switch (availability) {
      RiderAvailability.onlineAvailable => 'Online',
      RiderAvailability.reviewingDeliveryRequest => 'Reviewing',
      RiderAvailability.deliveryReserved => 'Reserved',
      RiderAvailability.goingToPickup => 'To pickup',
      RiderAvailability.waitingAtPickup => 'At pickup',
      RiderAvailability.productPickedUp => 'Picked up',
      RiderAvailability.goingToBuyer => 'To buyer',
      RiderAvailability.waitingAtDeliveryLocation => 'At drop-off',
      RiderAvailability.temporarilyUnavailable => 'Unavailable',
      _ => availability.displayLabel,
    };

String _gpsLabel(RiderGpsStatus status) => switch (status) {
  RiderGpsStatus.checking => 'GPS checking',
  RiderGpsStatus.ready => 'GPS ready',
  RiderGpsStatus.disabled => 'GPS off',
  RiderGpsStatus.permissionDenied => 'GPS denied',
  RiderGpsStatus.permissionDeniedForever => 'GPS blocked',
  RiderGpsStatus.approximateLocation => 'Approximate GPS',
  RiderGpsStatus.poorAccuracy => 'Weak GPS',
  RiderGpsStatus.timedOut => 'GPS timeout',
  RiderGpsStatus.unavailable => 'GPS unavailable',
};

String _internetLabel(RiderInternetStatus status) => switch (status) {
  RiderInternetStatus.unknown => 'Checking',
  RiderInternetStatus.checking => 'Checking',
  RiderInternetStatus.online => 'Connected',
  RiderInternetStatus.offline => 'Offline',
  RiderInternetStatus.reconnecting => 'Reconnecting',
  RiderInternetStatus.backendUnavailable => 'Backend down',
};
