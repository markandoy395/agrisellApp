import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

class FarmerRiderRequestPanel extends StatefulWidget {
  const FarmerRiderRequestPanel({
    required this.request,
    this.onChooseAnother,
    this.onCancel,
    this.isCancelling = false,
    this.now,
    super.key,
  });

  final FarmerRiderRequest request;
  final VoidCallback? onChooseAnother;
  final VoidCallback? onCancel;
  final bool isCancelling;
  final DateTime Function()? now;

  @override
  State<FarmerRiderRequestPanel> createState() =>
      _FarmerRiderRequestPanelState();
}

class _FarmerRiderRequestPanelState extends State<FarmerRiderRequestPanel> {
  Timer? _countdownTimer;

  FarmerRiderRequest get request => widget.request;
  VoidCallback? get onChooseAnother => widget.onChooseAnother;
  VoidCallback? get onCancel => widget.onCancel;
  bool get isCancelling => widget.isCancelling;
  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncCountdown();
  }

  @override
  void didUpdateWidget(covariant FarmerRiderRequestPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.id != widget.request.id ||
        oldWidget.request.status != widget.request.status ||
        oldWidget.request.expiresAt != widget.request.expiresAt) {
      _syncCountdown();
    }
  }

  void _syncCountdown() {
    _countdownTimer?.cancel();
    if (!request.status.isPending) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {});
      if (!_now.isBefore(request.expiresAt)) _countdownTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = request.status.isPending && !_now.isBefore(request.expiresAt)
        ? RiderAssignmentRequestStatus.expired
        : request.status;
    final presentation = _presentation(status);
    final remainingLabel = status.isPending ? _remainingLabel() : null;
    return Semantics(
      container: true,
      label: [
        '${status.label} for ${request.riderName}',
        if (remainingLabel != null) remainingLabel,
      ].join('. '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: presentation.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: presentation.color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(presentation.icon, size: 18, color: presentation.color),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: presentation.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (remainingLabel != null) ...[
                const SizedBox(height: 5),
                Text(
                  remainingLabel,
                  key: const ValueKey('rider-booking-remaining-time'),
                  style: TextStyle(
                    color: presentation.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                _message(status),
                style: const TextStyle(
                  color: AgrisellColors.brandBlack,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (status.isPending || status.allowsAnotherRequest) ...[
                const SizedBox(height: 9),
                SizedBox(
                  height: 36,
                  child: status.isPending
                      ? OutlinedButton(
                          onPressed: isCancelling ? null : onCancel,
                          child: Text(
                            isCancelling ? 'Cancelling...' : 'Cancel request',
                          ),
                        )
                      : FilledButton(
                          onPressed: onChooseAnother,
                          style: FilledButton.styleFrom(
                            backgroundColor: AgrisellColors.authGreen,
                          ),
                          child: const Text('Choose another rider'),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _message(RiderAssignmentRequestStatus status) => switch (status) {
    RiderAssignmentRequestStatus.pending =>
      '${request.riderName} has until ${_time(request.expiresAt)} to respond.',
    RiderAssignmentRequestStatus.accepted =>
      '${request.riderName} is assigned and can begin the delivery workflow.',
    RiderAssignmentRequestStatus.declined =>
      '${request.riderName} declined. Select another eligible rider.',
    RiderAssignmentRequestStatus.expired =>
      '${request.riderName} did not respond before the request expired.',
    RiderAssignmentRequestStatus.cancelled =>
      'This request was cancelled. You may choose another rider.',
    RiderAssignmentRequestStatus.failed =>
      request.failureReason ?? 'The rider became unavailable or ineligible.',
  };

  String _time(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _remainingLabel() {
    final remaining = request.expiresAt.difference(_now);
    if (remaining <= Duration.zero) return 'Booking expired';
    final minutes = (remaining.inSeconds / 60).ceil();
    return 'Expires in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
  }
}

_RequestPresentation _presentation(RiderAssignmentRequestStatus status) =>
    switch (status) {
      RiderAssignmentRequestStatus.pending => const _RequestPresentation(
        Icons.schedule_rounded,
        AgrisellColors.statusOrangeText,
        AgrisellColors.statusOrangeBackground,
      ),
      RiderAssignmentRequestStatus.accepted => const _RequestPresentation(
        Icons.check_circle_outline_rounded,
        AgrisellColors.statusGreenText,
        AgrisellColors.statusGreenBackground,
      ),
      RiderAssignmentRequestStatus.declined ||
      RiderAssignmentRequestStatus.failed => const _RequestPresentation(
        Icons.error_outline_rounded,
        AgrisellColors.statusRedText,
        AgrisellColors.statusRedBackground,
      ),
      RiderAssignmentRequestStatus.expired ||
      RiderAssignmentRequestStatus.cancelled => const _RequestPresentation(
        Icons.timer_off_outlined,
        AgrisellColors.statusPurpleText,
        AgrisellColors.statusPurpleBackground,
      ),
    };

class _RequestPresentation {
  const _RequestPresentation(this.icon, this.color, this.background);
  final IconData icon;
  final Color color;
  final Color background;
}
