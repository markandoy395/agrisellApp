import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

abstract interface class RiderDashboardCache {
  Future<RiderDashboardData?> load(String riderId);

  Future<void> save(String riderId, RiderDashboardData data);
}

class SharedPreferencesRiderDashboardCache implements RiderDashboardCache {
  SharedPreferencesRiderDashboardCache({this.preferences});

  static const _keyPrefix = 'rider_dashboard_cache_v1_';
  final SharedPreferences? preferences;

  @override
  Future<RiderDashboardData?> load(String riderId) async {
    try {
      final encoded = (await _instance).getString('$_keyPrefix$riderId');
      if (encoded == null) return null;
      final json = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      final metrics = Map<String, Object?>.from(json['metrics']! as Map);
      return RiderDashboardData(
        metrics: RiderDashboardMetrics(
          todayCompletedDeliveries: metrics['todayCompleted'] as int? ?? 0,
          todayEstimatedEarnings:
              (metrics['todayEarnings'] as num?)?.toDouble() ?? 0,
          unreadMessageCount: metrics['unreadMessages'] as int? ?? 0,
          unreadNotificationCount: metrics['unreadNotifications'] as int? ?? 0,
          cancelledOrFailedDeliveries: metrics['cancelledOrFailed'] as int?,
          pendingEarnings: (metrics['pendingEarnings'] as num?)?.toDouble(),
          averageRating: (metrics['averageRating'] as num?)?.toDouble(),
          completedDeliveryCount: metrics['completedCount'] as int?,
          onTimeDeliveryRate: (metrics['onTimeRate'] as num?)?.toDouble(),
          cancellationRate: (metrics['cancellationRate'] as num?)?.toDouble(),
        ),
        fetchedAt: DateTime.parse(json['fetchedAt']! as String),
        dataOrigin: RiderDataOrigin.values.byName(
          json['dataOrigin']! as String,
        ),
        unavailableSections:
            (json['unavailableSections'] as List?)?.cast<String>() ?? const [],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String riderId, RiderDashboardData data) async {
    final metrics = data.metrics;
    final json = <String, Object?>{
      'fetchedAt': data.fetchedAt.toIso8601String(),
      'dataOrigin': data.dataOrigin.name,
      'unavailableSections': data.unavailableSections,
      'metrics': <String, Object?>{
        'todayCompleted': metrics.todayCompletedDeliveries,
        'todayEarnings': metrics.todayEstimatedEarnings,
        'unreadMessages': metrics.unreadMessageCount,
        'unreadNotifications': metrics.unreadNotificationCount,
        'cancelledOrFailed': metrics.cancelledOrFailedDeliveries,
        'pendingEarnings': metrics.pendingEarnings,
        'averageRating': metrics.averageRating,
        'completedCount': metrics.completedDeliveryCount,
        'onTimeRate': metrics.onTimeDeliveryRate,
        'cancellationRate': metrics.cancellationRate,
      },
    };
    await (await _instance).setString('$_keyPrefix$riderId', jsonEncode(json));
  }

  Future<SharedPreferences> get _instance async =>
      preferences ?? await SharedPreferences.getInstance();
}
