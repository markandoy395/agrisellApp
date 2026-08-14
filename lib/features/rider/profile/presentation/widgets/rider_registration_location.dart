import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';

class RiderRegistrationLocation {
  const RiderRegistrationLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
    this.address,
    this.notes,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
  final String? address;
  final String? notes;

  String get label =>
      WrittenAddress.valueOrNull(address) ??
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  factory RiderRegistrationLocation.fromConfirmed(ConfirmedLocation value) =>
      RiderRegistrationLocation(
        latitude: value.latitude,
        longitude: value.longitude,
        accuracyMeters: value.accuracyMeters,
        capturedAt: value.capturedAt,
        address: value.address,
        notes: value.notes,
      );
}
