abstract final class RiderCargoCapacityPolicy {
  static double? maximum(String vehicleType, {double? serverMaximum}) {
    final ceiling = switch (vehicleType.trim().toLowerCase().replaceAll(
      '-',
      '',
    )) {
      'bicycle' || 'ebike' => 25.0,
      'motorcycle' => 30.0,
      'tricycle' || 'car' => 200.0,
      'van' => 1000.0,
      'truck' => 1500.0,
      _ => null,
    };
    if (ceiling == null) return null;
    if (serverMaximum == null) return ceiling;
    if (!serverMaximum.isFinite || serverMaximum <= 0) return null;
    return serverMaximum < ceiling ? serverMaximum : ceiling;
  }

  static String? error(
    String input,
    String vehicleType, {
    double? serverMaximum,
  }) {
    final ceiling = maximum(vehicleType, serverMaximum: serverMaximum);
    if (ceiling == null)
      return 'Capacity is unavailable for this vehicle type.';
    final value = double.tryParse(input.trim());
    if (value == null || !value.isFinite || value <= 0) {
      return 'Enter a valid cargo weight greater than 0 kg.';
    }
    if (value > ceiling) {
      return 'This vehicle allows at most ${ceiling.toStringAsFixed(0)} kg.';
    }
    return null;
  }
}
