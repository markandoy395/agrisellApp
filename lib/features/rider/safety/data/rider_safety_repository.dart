import 'package:agresell_app/features/rider/safety/domain/rider_safety_action.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_report.dart';

abstract interface class RiderSafetyRepository {
  Future<void> submit(RiderSafetyAction action);

  Future<RiderSafetyReport> submitReport(RiderSafetyReport report);

  Future<RiderSafetyReport?> updateReportStatus({
    required String riderId,
    required String reportId,
    required RiderSafetyReportStatus status,
  });
}

/// Empty local adapter; production should send these actions to a support API.
class InMemoryRiderSafetyRepository implements RiderSafetyRepository {
  InMemoryRiderSafetyRepository({
    Iterable<RiderSafetyAction> actions = const [],
    Iterable<RiderSafetyReport> reports = const [],
  }) : _actions = [...actions],
       _reports = {for (final report in reports) report.id: report};

  final List<RiderSafetyAction> _actions;
  final Map<String, RiderSafetyReport> _reports;

  @override
  Future<void> submit(RiderSafetyAction action) async {
    _actions.add(action);
  }

  @override
  Future<RiderSafetyReport> submitReport(RiderSafetyReport report) async {
    final existing = _reports[report.id];
    if (existing != null) return existing;
    if (!report.location.isValid ||
        report.attachments.any(
          (value) =>
              !value.startsWith('protected://') &&
              !value.startsWith('local-secure://'),
        )) {
      throw const RiderSafetyRepositoryException(
        'Safety evidence requires a valid location and protected files.',
      );
    }
    _reports[report.id] = report;
    return report;
  }

  @override
  Future<RiderSafetyReport?> updateReportStatus({
    required String riderId,
    required String reportId,
    required RiderSafetyReportStatus status,
  }) async {
    final report = _reports[reportId];
    if (report == null || report.riderId != riderId) return null;
    final updated = report.copyWith(status: status);
    _reports[reportId] = updated;
    return updated;
  }
}

class RiderSafetyRepositoryException implements Exception {
  const RiderSafetyRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
