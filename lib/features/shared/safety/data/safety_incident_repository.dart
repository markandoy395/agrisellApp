import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';

abstract interface class SafetyIncidentRepository {
  Future<SafetyIncident> submitIncident({
    required String reportId,
    required SafetyIncidentCategory category,
    required String description,
    required String reporterRole,
    String? reporterName,
    String? reporterContact,
    String? reporterEmail,
    int? orderId,
    int? deliveryId,
    String? stage,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    List<String> attachments = const [],
    List<String> requestedActions = const [],
    String reportType = 'safety_report',
  });

  Future<List<SafetyIncident>> getMyIncidents({String? status});
}

class InMemorySafetyIncidentRepository implements SafetyIncidentRepository {
  InMemorySafetyIncidentRepository({List<SafetyIncident>? seed})
      : _incidents = [...?seed];

  final List<SafetyIncident> _incidents;

  @override
  Future<SafetyIncident> submitIncident({
    required String reportId,
    required SafetyIncidentCategory category,
    required String description,
    required String reporterRole,
    String? reporterName,
    String? reporterContact,
    String? reporterEmail,
    int? orderId,
    int? deliveryId,
    String? stage,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    List<String> attachments = const [],
    List<String> requestedActions = const [],
    String reportType = 'safety_report',
  }) async {
    final incident = SafetyIncident(
      reportId: reportId,
      category: category,
      description: description,
      status: SafetyIncidentStatus.submitted,
      reportedAt: DateTime.now(),
      reportType: reportType,
      reporterRole: reporterRole,
      reporterName: reporterName,
      reporterContact: reporterContact,
      reporterEmail: reporterEmail,
      orderId: orderId,
      deliveryId: deliveryId,
      stage: stage,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      attachments: attachments,
      requestedActions: requestedActions,
    );
    _incidents.removeWhere((item) => item.reportId == reportId);
    _incidents.insert(0, incident);
    return incident;
  }

  @override
  Future<List<SafetyIncident>> getMyIncidents({String? status}) async {
    if (status == null || status.isEmpty || status == 'all') {
      return List.unmodifiable(_incidents);
    }
    if (status == 'open') {
      return _incidents.where((item) => item.status.isOpen).toList();
    }
    if (status == 'resolved') {
      return _incidents.where((item) => item.status.isTerminal).toList();
    }
    return _incidents
        .where((item) => item.status.name.toLowerCase() == status.toLowerCase())
        .toList();
  }
}
