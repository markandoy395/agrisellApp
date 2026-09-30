import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';

enum RiderRoutePreference { fastest, shortest, alternative }

extension RiderRoutePreferenceDetails on RiderRoutePreference {
  String get label => switch (this) {
    RiderRoutePreference.fastest => 'Fastest',
    RiderRoutePreference.shortest => 'Shortest',
    RiderRoutePreference.alternative => 'Alternative',
  };
}

class RiderRouteInstruction {
  const RiderRouteInstruction({
    required this.text,
    required this.distanceMeters,
    required this.durationSeconds,
    this.maneuverPoint,
    this.maneuverType = 'continue',
    this.maneuverModifier = '',
  });

  final String text;
  final double distanceMeters;
  final double durationSeconds;
  final DeliveryRoutePoint? maneuverPoint;
  final String maneuverType;
  final String maneuverModifier;
}

class RiderRoutePlan {
  RiderRoutePlan({
    required this.id,
    required this.requestId,
    required this.destinationKey,
    required this.preference,
    required this.distanceKm,
    required this.estimatedTravelMinutes,
    required this.snappedOrigin,
    required this.snappedDestination,
    required this.originRoadName,
    required this.destinationRoadName,
    required this.calculatedAt,
    Iterable<DeliveryRoutePoint> points = const [],
    Iterable<RiderRouteInstruction> instructions = const [],
  }) : points = List.unmodifiable(points),
       instructions = List.unmodifiable(instructions);

  final String id;
  final String requestId;
  final String destinationKey;
  final RiderRoutePreference preference;
  final double distanceKm;
  final int estimatedTravelMinutes;
  final DeliveryRoutePoint snappedOrigin;
  final DeliveryRoutePoint snappedDestination;
  final String originRoadName;
  final String destinationRoadName;
  final DateTime calculatedAt;
  final List<DeliveryRoutePoint> points;
  final List<RiderRouteInstruction> instructions;

  bool get hasGeometry => points.length > 1;
}
