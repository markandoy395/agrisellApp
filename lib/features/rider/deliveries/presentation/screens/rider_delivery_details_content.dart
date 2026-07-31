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
            action: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close_rounded,
                color: AgrisellColors.surface,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
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
    const SizedBox(height: 12),
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
  ) => [
    RiderDeliveryRequestOverview(request: _request),
    const SizedBox(height: 12),
    RiderDeliveryStatusSummary(
      status: currentStatus,
      accuracyMeters: widget.controller.currentRiderLocation?.accuracyMeters,
    ),
    if (widget.controller.deliveryWaitingStartedAt case final startedAt?) ...[
      const SizedBox(height: 12),
      RiderDeliveryWaitingSummary(
        startedAt: startedAt,
        instructions: _request.deliveryInstructions,
      ),
    ],
    const SizedBox(height: 12),
    RiderDeliveryProgressTimeline(
      currentStatus: currentStatus,
      events: widget.controller.statusEventsFor(_request.id),
    ),
    if (widget.controller.problemReportFor(_request.id) case final report?) ...[
      const SizedBox(height: 12),
      RiderReportStatusCard(report: report),
    ],
    const SizedBox(height: 12),
    RiderSurfaceCard(
      child: RiderDeliveryQuickActions(
        onRoute: () => _showMessage('Open the map tab for directions.'),
        onMessage: () => _showMessage('Open the rider messages tab to chat.'),
        onProblem: _openProblemReport,
        onSafety: () => _openSafetyReport(currentStatus),
      ),
    ),
    const SizedBox(height: 14),
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
