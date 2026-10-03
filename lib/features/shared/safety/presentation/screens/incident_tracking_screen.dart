import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';

import '../styles/incident_tracking_styles.dart';
import '../widgets/incident_tracking_filter_header.dart';
import '../widgets/incident_tracking_content.dart';

class IncidentTrackingScreen extends StatefulWidget {
  const IncidentTrackingScreen({
    required this.role,
    this.controller,
    this.userName,
    this.userContact,
    this.userEmail,
    super.key,
  });

  final String role;
  final SafetyIncidentController? controller;
  final String? userName;
  final String? userContact;
  final String? userEmail;

  @override
  State<IncidentTrackingScreen> createState() => _IncidentTrackingScreenState();
}

class _IncidentTrackingScreenState extends State<IncidentTrackingScreen> {
  late final SafetyIncidentController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? SafetyIncidentController();
    unawaited(_controller.loadIncidents());
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _showSafetySheet() => showAppSafetySheet(
    context: context,
    role: widget.role,
    userName: widget.userName,
    userContact: widget.userContact,
    userEmail: widget.userEmail,
    controller: _controller,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: IncidentTrackingStyles.background,
    appBar: AppBar(
      title: const Text(
        'Incident Tracking',
        style: IncidentTrackingStyles.screenTitle,
      ),
      backgroundColor: IncidentTrackingStyles.surface,
      foregroundColor: IncidentTrackingStyles.heading,
      elevation: 0,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => unawaited(_controller.loadIncidents()),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: IncidentTrackingStyles.green,
      foregroundColor: IncidentTrackingStyles.white,
      icon: const Icon(Icons.add_alert_rounded),
      label: const Text(
        'New Report / SOS',
        style: IncidentTrackingStyles.reportAction,
      ),
      onPressed: _showSafetySheet,
    ),
    body: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        children: [
          IncidentTrackingFilterHeader(controller: _controller),
          Expanded(
            child: RefreshIndicator(
              color: IncidentTrackingStyles.green,
              onRefresh: _controller.loadIncidents,
              child: IncidentTrackingContent(
                controller: _controller,
                onReport: _showSafetySheet,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
