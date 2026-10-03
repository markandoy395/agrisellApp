import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_request_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/utils/farmer_rider_request_formatters.dart';
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
    final presentation = FarmerRiderRequestStyles.presentationFor(status);
    final remainingLabel = status.isPending
        ? FarmerRiderRequestFormatters.remainingLabel(request.expiresAt, _now)
        : null;

    return Semantics(
      container: true,
      label: [
        '${status.label} for ${request.riderName}',
        if (remainingLabel != null) remainingLabel,
      ].join('. '),
      child: DecoratedBox(
        decoration: FarmerRiderRequestStyles.boxDecoration(presentation),
        child: Padding(
          padding: FarmerRiderRequestStyles.padding,
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
                      style: FarmerRiderRequestStyles.statusTextStyle(
                        presentation.color,
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
                  style: FarmerRiderRequestStyles.statusTextStyle(
                    presentation.color,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                FarmerRiderRequestFormatters.message(request, status),
                style: FarmerRiderRequestStyles.messageTextStyle,
              ),
              if (status.isPending || status.allowsAnotherRequest) ...[
                const SizedBox(height: 9),
                SizedBox(
                  height: FarmerRiderRequestStyles.actionButtonHeight,
                  child: status.isPending
                      ? OutlinedButton(
                          onPressed: isCancelling ? null : onCancel,
                          child: Text(
                            isCancelling ? 'Cancelling...' : 'Cancel request',
                          ),
                        )
                      : FilledButton(
                          onPressed: onChooseAnother,
                          style: FarmerRiderRequestStyles.chooseAnotherButtonStyle,
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
}
