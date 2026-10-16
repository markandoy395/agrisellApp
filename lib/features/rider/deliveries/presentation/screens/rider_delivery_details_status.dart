part of 'rider_delivery_details_screen.dart';

extension _RiderDeliveryDetailsStatus on _RiderDeliveryDetailsScreenState {
  Future<void> _openDeliveryConfirmation() async {
    final completed = await Navigator.of(context).push<bool>(
      agrisellMaterialPageRoute(
        builder: (_) => RiderDeliveryConfirmationScreen(
          request: _request,
          riderId: widget.riderId,
          controller: widget.controller,
        ),
      ),
    );
    if (completed != true || !mounted) return;
    final updated = widget.controller.requests.where(
      (item) => item.id == _request.id,
    );
    if (updated.isNotEmpty) _replaceActiveRequest(updated.first);
    _showMessage('Delivery completed. Buyer and farmer were notified.');
  }

  Future<void> _openPickupConfirmation() async {
    final completed = await Navigator.of(context).push<bool>(
      agrisellMaterialPageRoute(
        builder: (_) => RiderPickupConfirmationScreen(
          request: _request,
          riderId: widget.riderId,
          controller: widget.controller,
          locationController: widget.locationController,
        ),
      ),
    );
    if (completed == true && mounted) {
      final updated = widget.controller.requests.where(
        (item) => item.id == _request.id,
      );
      if (updated.isNotEmpty) _replaceActiveRequest(updated.first);
      _showMessage('Pickup confirmed. The buyer was notified.');
    }
  }

  Future<void> _advanceStatus(DeliveryStatus nextStatus) async {
    final needsLocation =
        nextStatus == DeliveryStatus.arrivedAtPickup ||
        nextStatus == DeliveryStatus.arrivedAtDelivery;
    final location = widget.controller.currentRiderLocation;
    if (needsLocation && location == null) {
      _showMessage('Current rider location is required to record arrival.');
      return;
    }
    _setUpdating(true);
    var result = await widget.controller.updateStatus(
      deliveryId: _request.id,
      riderId: widget.riderId,
      newStatus: nextStatus,
      location: location,
      note: nextStatus == DeliveryStatus.arrivedAtPickup
          ? 'Seller notified; pickup waiting timer started.'
          : nextStatus == DeliveryStatus.arrivedAtDelivery
          ? 'Buyer notified; delivery waiting timer started.'
          : null,
    );
    if (!result.isSuccess && needsLocation && mounted && location != null) {
      final override = await showRiderManualArrivalDialog(
        context,
        location: location,
      );
      if (override != null && mounted) {
        result = await widget.controller.updateStatus(
          deliveryId: _request.id,
          riderId: widget.riderId,
          newStatus: nextStatus,
          location: location,
          manualArrivalOverride: true,
          manualOverrideReason: override.reasonCode,
          manualOverrideNotes: override.notes,
          note:
              'Manual arrival: ${override.reasonLabel}. '
              '${override.notes}',
        );
      }
    }
    if (!mounted) return;
    _setUpdating(false);
    if (result.isSuccess) {
      _replaceActiveRequest(result.request!);
    }
    _showMessage(
      result.isSuccess
          ? '${nextStatus.displayLabel} recorded.'
          : result.message ?? 'Delivery could not be updated.',
    );
  }

  Future<void> _reportDestinationProblem() async {
    final controller = TextEditingController();
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Destination cannot be found'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: RiderDeliveryDetailsStatusStyles.inputDecoration,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Send report'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (notes == null || notes.trim().isEmpty || !mounted) return;
    final result = await widget.controller.reportDestinationProblem(
      deliveryId: _request.id,
      riderId: widget.riderId,
      notes: notes,
    );
    if (mounted) {
      _showMessage(
        result.isSuccess
            ? 'Location problem sent to support.'
            : result.message ?? 'The problem could not be sent.',
      );
    }
  }
}
