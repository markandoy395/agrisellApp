import 'dart:async';
import 'package:agresell_app/core/utils/async_request_scope.dart';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/safety/data/safety_incident_repository.dart';
import 'package:agresell_app/features/shared/safety/data/supabase_safety_incident_repository.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';

class SafetyIncidentController extends ChangeNotifier {
  SafetyIncidentController({SafetyIncidentRepository? repository})
    : _repository = repository ?? _defaultRepository();

  final SafetyIncidentRepository _repository;
  final _scope = AsyncRequestScope();

  List<SafetyIncident> _incidents = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _filter = 'all';

  List<SafetyIncident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;

  List<SafetyIncident> get filteredIncidents => switch (_filter) {
    'open' => _incidents.where((i) => i.status.isOpen).toList(),
    'resolved' => _incidents.where((i) => i.status.isTerminal).toList(),
    _ => _incidents,
  };

  void setFilter(String filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  Future<void> loadIncidents() async {
    if (_isLoading) return;
    final ticket = _scope.begin('load');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final values = await _repository.getMyIncidents(status: 'all');
      if (ticket.isCurrent) _incidents = values;
    } catch (error) {
      if (!ticket.isCurrent) return;
      _errorMessage = 'Could not load safety incidents: $error';
    } finally {
      _isLoading = false;
      if (ticket.isActive) notifyListeners();
    }
  }

  Future<SafetyIncident?> submitSOS({
    required String reporterRole,
    String? reporterName,
    String? reporterContact,
    String? reporterEmail,
    int? orderId,
    int? deliveryId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? note,
  }) async {
    return submitIncident(
      category: SafetyIncidentCategory.emergencySos,
      description: note?.trim().isNotEmpty == true
          ? note!.trim()
          : 'EMERGENCY SOS: User triggered immediate distress signal.',
      reporterRole: reporterRole,
      reporterName: reporterName,
      reporterContact: reporterContact,
      reporterEmail: reporterEmail,
      orderId: orderId,
      deliveryId: deliveryId,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      reportType: 'safety_action',
      requestedActions: const ['emergency_sos', 'contact_support'],
    );
  }

  static int _idCounter = 0;

  Future<SafetyIncident?> submitIncident({
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
    if (_isSubmitting) return null;
    final ticket = _scope.begin('submit');
    if (description.trim().isEmpty) {
      _errorMessage = 'A description is required for this incident report.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reportId =
          'INC-${DateTime.now().microsecondsSinceEpoch}-${++_idCounter}';
      final incident = await _repository.submitIncident(
        reportId: reportId,
        category: category,
        description: description.trim(),
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
        reportType: reportType,
      );

      if (!ticket.isCurrent) return null;
      _scope.invalidate('load');
      _incidents = [
        incident,
        ..._incidents.where((i) => i.reportId != incident.reportId),
      ];
      return incident;
    } catch (error) {
      if (!ticket.isCurrent) return null;
      _errorMessage = 'Safety report could not be submitted: $error';
      return null;
    } finally {
      _isSubmitting = false;
      if (ticket.isCurrent) notifyListeners();
    }
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  static SafetyIncidentRepository _defaultRepository() {
    if (AgrisellSupabase.isInitialized &&
        AgrisellSupabase.client.auth.currentUser != null) {
      return SupabaseSafetyIncidentRepository();
    }
    return InMemorySafetyIncidentRepository();
  }
}
