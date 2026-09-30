import 'delivery_route.dart';

abstract interface class DeliveryRouteService {
  Future<DeliveryRouteInfo?> findRoute({
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  });
}
