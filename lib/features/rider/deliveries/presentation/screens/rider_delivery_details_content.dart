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
    SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton.icon(
        key: const Key('rider-request-waybill-button'),
        onPressed: _openWaybill,
        icon: const Icon(Icons.receipt_long_rounded, size: 16),
        label: const Text(
          'Print / Download Waybill',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AgrisellColors.authGreen,
          backgroundColor: AgrisellColors.surface,
          side: const BorderSide(color: AgrisellColors.borderLine),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
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
  ) {
    final evidence = _request.proofs
        .where((proof) => proof.type == DeliveryProofType.deliveryPhoto)
        .firstOrNull;
    return [
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
      if (evidence != null) ...[
        const SizedBox(height: 12),
        RiderDeliveryEvidenceView(proof: evidence),
      ],
      if (widget.controller.problemReportFor(_request.id)
          case final report?) ...[
        const SizedBox(height: 12),
        RiderReportStatusCard(report: report),
      ],
      const SizedBox(height: 12),
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

  Future<void> _openConversation() async {
    final opened = await widget.onOpenConversation?.call(_request.id) ?? false;
    if (!opened && mounted) {
      _showMessage('No delivery conversation is available yet.');
    }
  }

  Future<void> _openGoogleMapsRoute() async {
    final destination = _request.deliveryLocation;
    if (!GoogleMapsRoute.hasValidDestination(destination)) {
      _showMessage(
        "The buyer's saved delivery coordinates are unavailable. "
        'Update the delivery location before opening the route.',
      );
      return;
    }

    final locationController = widget.locationController;
    if (locationController == null) {
      _showMessage(
        'Current rider GPS location is unavailable. Enable location services '
        'and Precise Location, then try again.',
      );
      return;
    }
    final previousLocation = locationController.location;
    await locationController.refresh(requestPermission: true);
    if (!mounted) return;
    final origin = locationController.location;
    if (identical(origin, previousLocation) ||
        locationController.state != RiderLocationState.ready) {
      _showMessage(_googleMapsLocationError(locationController));
      return;
    }
    widget.controller.updateCurrentRiderLocation(origin);
    final route = GoogleMapsRoute.directionsUri(
      origin: widget.controller.currentRiderLocation,
      destination: destination,
    );
    if (route == null) {
      _showMessage(_googleMapsLocationError(locationController));
      return;
    }
    try {
      if (!await _launchRoute(route) && mounted) {
        _showMessage('Google Maps could not be opened. Please try again.');
      }
    } on Exception {
      if (mounted) {
        _showMessage('Google Maps could not be opened. Please try again.');
      }
    }
  }

  String _googleMapsLocationError(RiderLocationController controller) {
    if (controller.errorMessage case final message?) return message;
    return switch (controller.state) {
      RiderLocationState.serviceDisabled =>
        'Location services are off. Turn on GPS, then try again.',
      RiderLocationState.permissionDenied =>
        'Location permission is required to open the route.',
      RiderLocationState.permissionDeniedForever =>
        'Location permission is blocked. Allow it in app settings, then try again.',
      RiderLocationState.approximateLocation =>
        'Precise Location is required to use your current position as the route start.',
      _ =>
        'Current rider GPS location is unavailable. Enable location services '
            'and Precise Location, then try again.',
    };
  }

  void _openWaybill() {
    final waybill = _request.toWaybill();
    showDeliveryWaybillSheet(context, waybill);
  }
}
