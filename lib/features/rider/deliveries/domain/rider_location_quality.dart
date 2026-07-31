import 'rider_location.dart';

enum RiderLocationQuality {
  accurate,
  acceptable,
  poor,
  unusable,
  stale,
  mocked,
}

abstract final class RiderLocationQualityRules {
  static const accurateMeters = 15.0;
  static const acceptableMeters = 50.0;
  static const poorMeters = 100.0;
  static const maxAge = Duration(seconds: 45);
  static const futureTolerance = Duration(seconds: 10);
}

extension RiderLocationQualityDetails on RiderLocation {
  RiderLocationQuality get quality {
    if (isMocked) return RiderLocationQuality.mocked;
    if (!hasValidCoordinates ||
        !accuracyMeters.isFinite ||
        accuracyMeters < 0) {
      return RiderLocationQuality.unusable;
    }
    if (!isFresh) {
      return RiderLocationQuality.stale;
    }
    if (isApproximate) return RiderLocationQuality.poor;
    if (accuracyMeters <= RiderLocationQualityRules.accurateMeters) {
      return RiderLocationQuality.accurate;
    }
    if (accuracyMeters <= RiderLocationQualityRules.acceptableMeters) {
      return RiderLocationQuality.acceptable;
    }
    return accuracyMeters <= RiderLocationQualityRules.poorMeters
        ? RiderLocationQuality.poor
        : RiderLocationQuality.unusable;
  }

  bool get hasValidCoordinates =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  bool get isFresh {
    final age = DateTime.now().difference(timestamp);
    return age <= RiderLocationQualityRules.maxAge &&
        age >= -RiderLocationQualityRules.futureTolerance;
  }

  bool isUsableForArrival({double maxAccuracyMeters = 50}) =>
      !isMocked &&
      !isApproximate &&
      isFresh &&
      accuracyMeters >= 0 &&
      accuracyMeters <= maxAccuracyMeters;
}
