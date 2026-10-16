part of 'rider_delivery_details_screen.dart';

extension _RiderDeliveryDetailsRoute on _RiderDeliveryDetailsScreenState {
  Future<void> _openGoogleMapsRoute({DeliveryLocation? destination}) async {
    destination ??= _request.deliveryLocation;
    if (!GoogleMapsRoute.hasValidDestination(destination)) {
      _showMessage(
        'The saved destination coordinates are unavailable. '
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
}
