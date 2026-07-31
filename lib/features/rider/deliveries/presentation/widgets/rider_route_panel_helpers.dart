part of 'rider_route_panel.dart';

Color _qualityColor(RiderLocationQuality quality) => switch (quality) {
  RiderLocationQuality.accurate ||
  RiderLocationQuality.acceptable => AgrisellColors.authGreen,
  RiderLocationQuality.poor ||
  RiderLocationQuality.stale => AgrisellColors.statusOrangeText,
  RiderLocationQuality.unusable ||
  RiderLocationQuality.mocked => AgrisellColors.statusRedText,
};

String _routeDestination(
  DeliveryRequest? request,
  String destinationKey,
  String fallback,
) {
  if (request == null) return fallback;
  return destinationKey.endsWith(':delivery')
      ? request.deliveryLocation.address
      : request.pickupLocation.address;
}

String _routeLabel(List<RiderRoutePlan> routes, int index) {
  final route = routes[index];
  if (route.preference != RiderRoutePreference.alternative) {
    return route.preference.label;
  }
  final alternativeIndex = routes
      .take(index + 1)
      .where((item) => item.preference == RiderRoutePreference.alternative)
      .length;
  return 'Alternative $alternativeIndex';
}

String _time(DateTime? value) {
  if (value == null) return '--:--';
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
}

DeliveryRequest? _selectedRequest(
  List<DeliveryRequest> requests,
  String? requestId,
) {
  for (final request in requests) {
    if (request.id == requestId) return request;
  }
  return requests.firstOrNull;
}
