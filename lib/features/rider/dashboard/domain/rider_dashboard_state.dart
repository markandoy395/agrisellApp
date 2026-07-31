import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

enum RiderDashboardLoadState {
  initialLoading,
  refreshing,
  ready,
  partialData,
  serverError,
}

enum RiderInternetStatus {
  unknown,
  checking,
  online,
  offline,
  reconnecting,
  backendUnavailable,
}

enum RiderGpsStatus {
  checking,
  ready,
  disabled,
  permissionDenied,
  permissionDeniedForever,
  approximateLocation,
  poorAccuracy,
  timedOut,
  unavailable,
}

class RiderDashboardMetrics {
  const RiderDashboardMetrics({
    this.todayCompletedDeliveries = 0,
    this.todayEstimatedEarnings = 0,
    this.unreadMessageCount = 0,
    this.unreadNotificationCount = 0,
    this.cancelledOrFailedDeliveries,
    this.pendingEarnings,
    this.averageRating,
    this.completedDeliveryCount,
    this.onTimeDeliveryRate,
    this.cancellationRate,
  });

  final int todayCompletedDeliveries;
  final double todayEstimatedEarnings;
  final int unreadMessageCount;
  final int unreadNotificationCount;
  final int? cancelledOrFailedDeliveries;
  final double? pendingEarnings;
  final double? averageRating;
  final int? completedDeliveryCount;
  final double? onTimeDeliveryRate;
  final double? cancellationRate;

  RiderDashboardMetrics copyWith({int? todayCompletedDeliveries}) =>
      RiderDashboardMetrics(
        todayCompletedDeliveries:
            todayCompletedDeliveries ?? this.todayCompletedDeliveries,
        todayEstimatedEarnings: todayEstimatedEarnings,
        unreadMessageCount: unreadMessageCount,
        unreadNotificationCount: unreadNotificationCount,
        cancelledOrFailedDeliveries: cancelledOrFailedDeliveries,
        pendingEarnings: pendingEarnings,
        averageRating: averageRating,
        completedDeliveryCount: completedDeliveryCount,
        onTimeDeliveryRate: onTimeDeliveryRate,
        cancellationRate: cancellationRate,
      );
}

class RiderDashboardData {
  const RiderDashboardData({
    required this.metrics,
    required this.fetchedAt,
    required this.dataOrigin,
    this.unavailableSections = const <String>[],
  });

  final RiderDashboardMetrics metrics;
  final DateTime fetchedAt;
  final RiderDataOrigin dataOrigin;
  final List<String> unavailableSections;

  bool get isPartial => unavailableSections.isNotEmpty;
  bool get usesTemporaryData => dataOrigin == RiderDataOrigin.temporaryLocal;
}
