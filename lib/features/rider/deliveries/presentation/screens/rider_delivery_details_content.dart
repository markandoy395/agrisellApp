part of 'rider_delivery_details_screen.dart';

extension _RiderDeliveryDetailsContent on _RiderDeliveryDetailsScreenState {
  Widget _buildDetails(BuildContext context) {
    final isRequest = _request.stage == DeliveryStage.readyForPickup;
    final currentStatus = widget.controller.statusFor(_request);
    return Scaffold(
      backgroundColor: RiderDeliveryReferenceStyles.background,
      body: Column(
        children: [
          RiderDeliveryDetailsHeader(
            orderNumber: _request.orderNumber.toLowerCase().startsWith('order ')
                ? _request.orderNumber
                : 'Order ${_request.orderNumber}',
            requestReview: isRequest,
            onWaybill: _openWaybill,
          ),
          Expanded(
            child: ListView(
              key: PageStorageKey('rider-delivery-details-${_request.id}'),
              padding: RiderDeliveryDetailsStyles.listPadding,
              children: isRequest
                  ? _requestContent()
                  : _activeContent(context, currentStatus),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: RiderDeliveryDetailsStyles.actionPadding,
          child: _deliveryActions(currentStatus, isRequest: isRequest),
        ),
      ),
    );
  }

  List<Widget> _requestContent() => [
    RiderDeliveryDetailsStatusBanner(
      status: DeliveryStatus.available,
      requestReview: true,
    ),
    const SizedBox(height: 12),
    RiderDetailProductCard(request: _request),
    const SizedBox(height: 12),
    RiderDetailLocationCard(request: _request),
    const SizedBox(height: 12),
    RiderDetailLocationCard(request: _request, delivery: true),
    const SizedBox(height: 12),
    RiderDetailRoutePreview(
      request: _request,
      onOpenMap: () =>
          unawaited(_openGoogleMapsRoute(destination: _request.pickupLocation)),
    ),
    const SizedBox(height: 12),
    RiderDetailEarningsCard(request: _request),
    const SizedBox(height: 12),
    RiderDetailRequirementsCard(request: _request),
    const SizedBox(height: 12),
    RiderDetailOtherInformation(request: _request),
    const SizedBox(height: 12),
    OutlinedButton.icon(
      key: const Key('rider-request-waybill-button'),
      onPressed: _openWaybill,
      icon: const Icon(Icons.print_outlined, size: 18),
      label: const Text('Print / Download Waybill'),
      style: RiderDeliveryDetailsStyles.waybillButtonStyle,
    ),
  ];

  List<Widget> _activeContent(
    BuildContext context,
    DeliveryStatus currentStatus,
  ) {
    final evidence = _request.proofs
        .where(
          (proof) =>
              proof.type == DeliveryProofType.deliveryPhoto ||
              proof.type == DeliveryProofType.productPhoto,
        )
        .toList();
    return [
      RiderDeliveryDetailsStatusBanner(status: currentStatus),
      const SizedBox(height: 12),
      RiderDetailProductCard(request: _request),
      const SizedBox(height: 12),
      RiderDetailProgress(
        status: currentStatus,
        events: widget.controller.statusEventsFor(_request.id),
        nextAction: RiderDeliveryStatusSummary(
          status: currentStatus,
          accuracyMeters:
              widget.controller.currentRiderLocation?.accuracyMeters,
        ),
      ),
      const SizedBox(height: 12),
      RiderDetailRoutePreview(
        request: _request,
        onOpenMap: () => unawaited(_openGoogleMapsRoute()),
      ),
      const SizedBox(height: 12),
      RiderDeliveryNavigationAddresses(
        request: _request,
        onPickup: () => unawaited(
          _openGoogleMapsRoute(destination: _request.pickupLocation),
        ),
        onDelivery: () => unawaited(_openGoogleMapsRoute()),
      ),
      const SizedBox(height: 12),
      RiderDeliveryQuickActions(
        onRoute: () => unawaited(_openGoogleMapsRoute()),
        onMessage: widget.onOpenConversation == null
            ? null
            : () => unawaited(_openConversation()),
        onProblem: _openProblemReport,
        onSafety: () => _openSafetyReport(currentStatus),
        onWaybill: _openWaybill,
      ),
      const SizedBox(height: 12),
      RiderDetailEarningsCard(request: _request, active: true),
      const SizedBox(height: 12),
      RiderDetailDeliveryInformation(request: _request),
      if (widget.controller.deliveryWaitingStartedAt case final startedAt?) ...[
        const SizedBox(height: 12),
        RiderDeliveryWaitingSummary(
          startedAt: startedAt,
          instructions: _request.deliveryInstructions,
        ),
      ],
      const SizedBox(height: 12),
      if (evidence.isEmpty)
        const RiderDetailSection(
          title: 'Delivery evidence',
          icon: Icons.camera_alt_outlined,
          children: [Text('No pickup or delivery photo recorded yet.')],
        )
      else
        for (final proof in evidence) ...[
          RiderDeliveryEvidenceView(proof: proof),
          const SizedBox(height: 8),
        ],
      const SizedBox(height: 12),
      if (widget.controller.problemReportFor(_request.id) case final report?)
        RiderReportStatusCard(report: report)
      else
        RiderDetailSection(
          title: 'Problem report',
          icon: Icons.report_problem_rounded,
          color: AgrisellColors.statusRedText,
          children: [
            TextButton(
              onPressed: _openProblemReport,
              child: const Text('No problem reported · Report a problem'),
            ),
          ],
        ),
    ];
  }

  Widget _deliveryActions(
    DeliveryStatus currentStatus, {
    required bool isRequest,
  }) => RiderDeliveryActionPanel(
    request: _request,
    canAccept: isRequest && widget.controller.canAcceptRequest(_request.id),
    isUpdating: _isUpdating || _acceptanceOpen,
    onAccept: _accept,
    onDecline: _decline,
    onAdvance: _advance,
    onCancel: _cancel,
    currentStatus: isRequest ? null : currentStatus,
    onStatusAdvance: _advanceStatus,
    onPickupConfirmation: _openPickupConfirmation,
    onDeliveryConfirmation: _openDeliveryConfirmation,
    onDestinationProblem:
        currentStatus.index >= DeliveryStatus.goingToBuyer.index
        ? _reportDestinationProblem
        : null,
  );

  Future<void> _openConversation() async {
    final opened = await widget.onOpenConversation?.call(_request.id) ?? false;
    if (!opened && mounted)
      _showMessage('No delivery conversation is available yet.');
  }

  void _openWaybill() =>
      showDeliveryWaybillSheet(context, _request.toWaybill());
}
