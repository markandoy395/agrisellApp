enum RiderMapViewType { defaultView, satellite, terrain }

class RiderMapVisibility {
  const RiderMapVisibility({
    this.pickups = true,
    this.active = true,
    this.dropOffs = true,
    this.farms = true,
    this.pointsOfInterest = true,
    this.trafficConditions = true,
    this.mapViewType = RiderMapViewType.defaultView,
  });
  final bool pickups;
  final bool active;
  final bool dropOffs;
  final bool farms;
  final bool pointsOfInterest;
  final bool trafficConditions;
  final RiderMapViewType mapViewType;

  RiderMapVisibility copyWith({
    bool? pickups,
    bool? active,
    bool? dropOffs,
    bool? farms,
    bool? pointsOfInterest,
    bool? trafficConditions,
    RiderMapViewType? mapViewType,
  }) => RiderMapVisibility(
    pickups: pickups ?? this.pickups,
    active: active ?? this.active,
    dropOffs: dropOffs ?? this.dropOffs,
    farms: farms ?? this.farms,
    pointsOfInterest: pointsOfInterest ?? this.pointsOfInterest,
    trafficConditions: trafficConditions ?? this.trafficConditions,
    mapViewType: mapViewType ?? this.mapViewType,
  );
}

