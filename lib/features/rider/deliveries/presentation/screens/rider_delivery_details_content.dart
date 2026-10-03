part of 'rider_delivery_details_screen.dart';

extension _RiderDeliveryDetailsContent on _RiderDeliveryDetailsScreenState {
  Widget _buildDetails(BuildContext context) {
    final isRequest = _request.stage == DeliveryStage.readyForPickup;
    final currentStatus = widget.controller.statusFor(_request);
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      body: Column(
        children: [
          RiderPageHeader(
            title: 'Delivery details',
            subtitle: 'Order ${_request.orderNumber}',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const Key('rider-print-waybill-button'),
                  tooltip: 'Print Delivery Waybill',
                  onPressed: _openWaybill,
                  icon: const Icon(
                    Icons.print_outlined,
                    color: AgrisellColors.surface,
                  ),
                ),
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AgrisellColors.surface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: RiderDeliveryDetailsStyles.listPadding,
              children: isRequest
                  ? _requestContent()
                  : _activeContent(context, currentStatus),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _requestContent() => [
    RiderRequestDetailSections(request: _request),
    const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
    SizedBox(
      width: double.infinity,
      height: RiderDeliveryDetailsStyles.waybillButtonHeight,
      child: OutlinedButton.icon(
        key: const Key('rider-request-waybill-button'),
        onPressed: _openWaybill,
        icon: const Icon(
          Icons.receipt_long_rounded,
          size: RiderDeliveryDetailsStyles.waybillButtonIconSize,
        ),
        label: const Text(
          'Print / Download Waybill',
          style: RiderDeliveryDetailsStyles.waybillButtonText,
        ),
        style: RiderDeliveryDetailsStyles.waybillButtonStyle,
      ),
    ),
    const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
    RiderDeliveryActionPanel(
      request: _request,
      canAccept: widget.controller.canAcceptRequest(_request.id),
      isUpdating: _isUpdating || _acceptanceOpen,
      onAccept: _accept,
      onDecline: _decline,
      onAdvance: _advance,
      onCancel: _cancel,
    ),
  ];

  List<Widget> _activeContent(
    BuildContext context,
    DeliveryStatus currentStatus,
  ) {
    final evidence = _request.proofs
        .where((proof) => proof.type == DeliveryProofType.deliveryPhoto)
        .firstOrNull;
    return [
      RiderDeliveryRequestOverview(request: _request),
      const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
      RiderDeliveryStatusSummary(
        status: currentStatus,
        accuracyMeters: widget.controller.currentRiderLocation?.accuracyMeters,
      ),
      if (widget.controller.deliveryWaitingStartedAt case final startedAt?) ...[
        const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
        RiderDeliveryWaitingSummary(
          startedAt: startedAt,
          instructions: _request.deliveryInstructions,
        ),
      ],
      const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
      RiderDeliveryProgressTimeline(
        currentStatus: currentStatus,
        events: widget.controller.statusEventsFor(_request.id),
      ),
      if (evidence != null) ...[
        const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
        RiderDeliveryEvidenceView(proof: evidence),
      ],
      if (widget.controller.problemReportFor(_request.id)
          case final report?) ...[
        const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
        RiderReportStatusCard(report: report),
      ],
      const SizedBox(height: RiderDeliveryDetailsStyles.spacing12),
      RiderSurfaceCard(
        child: RiderDeliveryQuickActions(
          onRoute: () => unawaited(_openGoogleMapsRoute()),
          onMessage: widget.onOpenConversation == null
              ? null
              : () => unawaited(_openConversation()),
          onProblem: _openProblemReport,
          onSafety: () => _openSafetyReport(currentStatus),
          onWaybill: _openWaybill,
        ),
      ),
      const SizedBox(height: RiderDeliveryDetailsStyles.spacing14),
      RiderDeliveryActionPanel(
        request: _request,
        canAccept: false,
        isUpdating: _isUpdating,
        onAccept: () {},
        onDecline: _decline,
        onAdvance: _advance,
        onCancel: _cancel,
        currentStatus: currentStatus,
        onStatusAdvance: _advanceStatus,
        onPickupConfirmation: _openPickupConfirmation,
        onDeliveryConfirmation: _openDeliveryConfirmation,
        onDestinationProblem:
            currentStatus.index >= DeliveryStatus.goingToBuyer.index
            ? _reportDestinationProblem
            : null,
      ),
    ];
  }

  Future<void> _openConversation() async {
    final opened = await widget.onOpenConversation?.call(_request.id) ?? false;
    if (!opened && mounted) {
      _showMessage('No delivery conversation is available yet.');
    }
  }

  void _openWaybill() {
    final waybill = _request.toWaybill();
    showDeliveryWaybillSheet(context, waybill);
  }
}
