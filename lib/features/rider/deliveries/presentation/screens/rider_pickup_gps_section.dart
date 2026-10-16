part of 'rider_pickup_confirmation_screen.dart';

extension _PickupGpsSection on _RiderPickupConfirmationScreenState {
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
      RiderLocationState.loading => 'Finding current GPS location...',
      _ when usable =>
        'GPS ready (±${location!.accuracyMeters.toStringAsFixed(0)} m)',
      _ => 'GPS accuracy: Unavailable',
    };
    final needsLocationSettings = state == RiderLocationState.serviceDisabled;
    final needsAppSettings =
        state == RiderLocationState.permissionDeniedForever ||
        state == RiderLocationState.approximateLocation;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 36,
          color: usable
              ? AgrisellColors.authGreen
              : AgrisellColors.statusRedText,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status, style: RiderPickupDesignStyles.gps(usable)),
              Text(
                'Your location will be saved when you complete pickup.',
                style: RiderPickupDesignStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          style: RiderDeliveryReferenceStyles.navigate,
          onPressed: _busy || _refreshingLocation
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
                ? 'Locating...'
                : needsLocationSettings || needsAppSettings
                ? 'Open settings'
                : 'Retry GPS',
          ),
        ),
      ],
    );
  }
}
