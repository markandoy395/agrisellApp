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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          Text(
            'Pickup: ${widget.request.pickupLocation.address}',
            style: const TextStyle(fontSize: 12),
          ),
          _locationStatus(),
          if (widget.controller.pickupWaitingStartedAt case final startedAt?)
            Text(
              'Pickup waiting time: ${_waitingLabel(_now.difference(startedAt))}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          Text(
            widget.request.pickupInstructions.isEmpty
                ? 'No pickup instructions.'
                : widget.request.pickupInstructions,
            style: const TextStyle(fontSize: 12),
          ),
          if (widget.request.handlingRequirements.isNotEmpty)
            Text(
              widget.request.handlingRequirements
                  .map((item) => item.type.label)
                  .join(' • '),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
            style: TextStyle(
              fontSize: 12,
              color: usable
                  ? AgrisellColors.authGreen
                  : AgrisellColors.statusRedText,
              fontWeight: FontWeight.w700,
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

  Widget _methods(PickupConfiguration config) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required confirmation',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          if (config.requiredMethods.contains(
            PickupConfirmationMethod.confirmationCode,
          ))
            TextField(
              controller: _code,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pickup confirmation code',
              ),
            ),
          if (config.requiredMethods.contains(PickupConfirmationMethod.qrCode))
            TextField(
              controller: _qr,
              decoration: const InputDecoration(labelText: 'QR scan result'),
            ),
          if (config.requiredMethods.contains(
                PickupConfirmationMethod.quantityConfirmation,
              ) ||
              config.requiredMethods.contains(
                PickupConfirmationMethod.weightConfirmation,
              ))
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                ),
              ],
            ),
          for (final method
              in {
                ...config.requiredMethods,
                PickupConfirmationMethod.productPhoto,
              }.where(_requiresProof))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => _capture(method),
                icon: Icon(
                  _proofs.containsKey(method)
                      ? Icons.check_circle
                      : Icons.add_a_photo_outlined,
                  size: 17,
                ),
                label: Text(_methodLabel(method)),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _checklist() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product condition checklist',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          for (final label in _checkLabels)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: const TextStyle(fontSize: 12)),
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
                style: const TextStyle(
                  color: AgrisellColors.statusRedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final issue in _validationIssues)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '• ${issue.message}',
                    style: const TextStyle(
                      color: AgrisellColors.statusRedText,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      SizedBox(
        width: double.infinity,
        height: 38,
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
