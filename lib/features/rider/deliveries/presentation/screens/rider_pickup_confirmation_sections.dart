part of 'rider_pickup_confirmation_screen.dart';

extension _PickupConfirmationSections on _RiderPickupConfirmationScreenState {
  Widget _summary() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.request.productName,
            style: RiderPickupConfirmationStyles.summaryTitleStyle,
          ),
          Text(
            'Pickup: ${widget.request.pickupLocation.address}',
            style: RiderPickupConfirmationStyles.smallTextStyle,
          ),
          _locationStatus(),
          if (widget.controller.pickupWaitingStartedAt case final startedAt?)
            Text(
              'Pickup waiting time: ${_waitingLabel(_now.difference(startedAt))}',
              style: RiderPickupConfirmationStyles.smallBoldStyle,
            ),
          Text(
            widget.request.pickupInstructions.isEmpty
                ? 'No pickup instructions.'
                : widget.request.pickupInstructions,
            style: RiderPickupConfirmationStyles.smallTextStyle,
          ),
          if (widget.request.handlingRequirements.isNotEmpty)
            Text(
              widget.request.handlingRequirements
                  .map((item) => item.type.label)
                  .join(' • '),
              style: RiderPickupConfirmationStyles.smallBoldStyle,
            ),
        ],
      ),
    ),
  );

  Widget _locationStatus() {
    final location = widget.controller.currentRiderLocation;
    final usable = location?.isUsableForPickup() ?? false;
    final state = widget.locationController?.state;
    final status = switch (state) {
      RiderLocationState.serviceDisabled => 'Location services are disabled.',
      RiderLocationState.permissionDenied => 'Location permission is required.',
      RiderLocationState.permissionDeniedForever =>
        'Location permission is disabled in app settings.',
      RiderLocationState.approximateLocation => 'Precise Location is disabled.',
      RiderLocationState.timedOut => 'GPS fix timed out. Please retry.',
      RiderLocationState.loading => 'Finding current GPS location…',
      _ when usable =>
        'GPS ready (±${location!.accuracyMeters.toStringAsFixed(0)} m)',
      _ => 'GPS accuracy: Unavailable',
    };
    final needsLocationSettings = state == RiderLocationState.serviceDisabled;
    final needsAppSettings =
        state == RiderLocationState.permissionDeniedForever ||
        state == RiderLocationState.approximateLocation;
    return Row(
      children: [
        Expanded(
          child: Text(
            status,
            style: RiderPickupConfirmationStyles.locationStatusStyle(
              usable: usable,
            ),
          ),
        ),
        TextButton(
          onPressed: _refreshingLocation || _submitting
              ? null
              : () {
                  if (needsLocationSettings) {
                    unawaited(
                      widget.locationController?.openLocationSettings(),
                    );
                  } else if (needsAppSettings) {
                    unawaited(widget.locationController?.openAppSettings());
                  } else {
                    unawaited(_refreshPickupLocation(requestPermission: true));
                  }
                },
          child: Text(
            _refreshingLocation
                ? 'Locating…'
                : needsLocationSettings || needsAppSettings
                ? 'Open settings'
                : 'Retry GPS',
          ),
        ),
      ],
    );
  }

  Widget _checklist() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product condition checklist',
            style: RiderPickupConfirmationStyles.sectionHeaderStyle,
          ),
          for (final label in _checkLabels)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: RiderPickupConfirmationStyles.smallTextStyle,
              ),
              value: _checks[label] ?? false,
              onChanged: (value) => _setCheck(label, value ?? false),
            ),
        ],
      ),
    ),
  );

  Widget _action(PickupConfiguration config) => Column(
    children: [
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _error!,
                style: RiderPickupConfirmationStyles.errorTextStyle,
              ),
              for (final issue in _validationIssues)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '• ${issue.message}',
                    style: RiderPickupConfirmationStyles.errorItemStyle,
                  ),
                ),
            ],
          ),
        ),
      SizedBox.fromSize(
        size: RiderPickupConfirmationStyles.completeButtonBox,
        child: FilledButton(
          onPressed: _submitting ? null : () => _submit(config),
          child: Text(_submitting ? 'Confirming...' : 'Complete pickup'),
        ),
      ),
      TextButton(
        onPressed: _submitting ? null : _reportProblem,
        child: const Text('Report pickup problem'),
      ),
    ],
  );
}

String _waitingLabel(Duration value) {
  final minutes = value.inMinutes.toString().padLeft(2, '0');
  final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
