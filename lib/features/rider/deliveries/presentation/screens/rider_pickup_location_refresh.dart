part of 'rider_pickup_confirmation_screen.dart';

extension _RiderPickupLocationRefresh on _RiderPickupConfirmationScreenState {
  Future<void> _refreshPickupLocation({required bool requestPermission}) async {
    final locationController = widget.locationController;
    if (locationController == null || _refreshingLocation) return;
    _setRefreshingLocation(true);
    await locationController.refresh(requestPermission: requestPermission);
    _locationChanged();
    _setRefreshingLocation(false);
  }
}
