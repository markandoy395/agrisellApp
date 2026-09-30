import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        title: const Text(
          'Incident Tracking',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        backgroundColor: AgrisellColors.surface,
        foregroundColor: AgrisellColors.headingGreen,
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
        backgroundColor: AgrisellColors.forestGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('New Report / SOS', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => showAppSafetySheet(
          context: context,
          role: widget.role,
          userName: widget.userName,
          userContact: widget.userContact,
          userEmail: widget.userEmail,
          controller: _controller,
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              _buildFilterHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: AgrisellColors.forestGreen,
                  onRefresh: _controller.loadIncidents,
                  child: _buildContent(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      color: AgrisellColors.surface,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            _filterChip('all', 'All Reports'),
            const SizedBox(width: 8),
            _filterChip('open', 'In Progress'),
            const SizedBox(width: 8),
            _filterChip('resolved', 'Resolved / Closed'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _controller.filter == filterKey;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AgrisellColors.headingGreen,
        ),
      ),
      selected: isSelected,
      selectedColor: AgrisellColors.authGreen,
      backgroundColor: AgrisellColors.pageBackground,
      onSelected: (_) => _controller.setFilter(filterKey),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading && _controller.incidents.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AgrisellColors.forestGreen),
      );
    }

    final incidents = _controller.filteredIncidents;

    if (incidents.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AgrisellColors.forestSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: AgrisellColors.forestGreen,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Safety Incidents Found',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AgrisellColors.headingGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _controller.filter == 'all'
                        ? 'You have not reported any safety incidents or SOS alerts.'
                        : 'No reports found matching the selected filter.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AgrisellColors.mutedText),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AgrisellColors.forestSoft,
                    foregroundColor: AgrisellColors.forestGreen,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Submit Safety Report'),
                  onPressed: () => showAppSafetySheet(
                    context: context,
                    role: widget.role,
                    userName: widget.userName,
                    userContact: widget.userContact,
                    userEmail: widget.userEmail,
                    controller: _controller,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return _IncidentCard(incident: incident);
      },
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident});

  final SafetyIncident incident;

  @override
  Widget build(BuildContext context) {
    final isEmergency = incident.isEmergency;
    final isResolved = incident.status.isTerminal;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEmergency && !isResolved
              ? AgrisellColors.statusRedText.withValues(alpha: 0.4)
              : AgrisellColors.borderLine,
          width: isEmergency && !isResolved ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: isEmergency && !isResolved
                  ? AgrisellColors.statusRedBackground.withValues(alpha: 0.5)
                  : Colors.transparent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEmergency
                              ? AgrisellColors.statusRedText
                              : AgrisellColors.forestGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isEmergency ? '🚨 ${incident.category.label}' : incident.category.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Status Chip
                      _statusChip(incident.status),
                    ],
                  ),
                ),
                Text(
                  _formatTimeAgo(incident.reportedAt),
                  style: const TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report ID & references
                Row(
                  children: [
                    Text(
                      'ID: ${incident.reportId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AgrisellColors.mutedText,
                      ),
                    ),
                    if (incident.orderId != null) ...[
                      const Text(' • ', style: TextStyle(color: AgrisellColors.mutedText)),
                      Text(
                        'Order #${incident.orderId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AgrisellColors.forestGreen,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Multi-stage Resolution Stepper
                _buildResolutionStepper(incident.status),
                const SizedBox(height: 12),

                // Description
                const Text(
                  'REPORT STATEMENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AgrisellColors.mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incident.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AgrisellColors.headingGreen,
                    height: 1.4,
                  ),
                ),

                // Admin Resolution Audit Notes (if provided)
                if (incident.resolutionNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AgrisellColors.forestSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AgrisellColors.forestGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: AgrisellColors.forestGreen,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ADMIN RESOLUTION AUDIT NOTE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AgrisellColors.forestGreen,
                              ),
                            ),
                            if (incident.resolvedBy != null) ...[
                              Text(
                                ' • by ${incident.resolvedBy}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AgrisellColors.headingGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          incident.resolutionNotes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AgrisellColors.headingGreen,
                            height: 1.4,
                          ),
                        ),
                        if (incident.resolvedAt != null) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Resolved at ${_formatDateTime(incident.resolvedAt!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AgrisellColors.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionStepper(SafetyIncidentStatus status) {
    final step1Done = true;
    final step2Active = status == SafetyIncidentStatus.underReview ||
        status == SafetyIncidentStatus.waitingForInformation ||
        status == SafetyIncidentStatus.escalated;
    final step2Done = status.isTerminal;
    final step3Done = status == SafetyIncidentStatus.resolved;
    final step3Rejected = status == SafetyIncidentStatus.rejected;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AgrisellColors.pageBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _stepNode(
            title: 'Reported',
            isDone: step1Done,
            isActive: false,
          ),
          _stepConnector(isDone: step2Active || step2Done),
          _stepNode(
            title: status == SafetyIncidentStatus.escalated
                ? 'Escalated'
                : 'Investigating',
            isDone: step2Done,
            isActive: step2Active,
          ),
          _stepConnector(isDone: step3Done || step3Rejected),
          _stepNode(
            title: step3Rejected ? 'Dismissed' : 'Resolved',
            isDone: step3Done,
            isActive: false,
            isRejected: step3Rejected,
          ),
        ],
      ),
    );
  }

  Widget _stepNode({
    required String title,
    required bool isDone,
    required bool isActive,
    bool isRejected = false,
  }) {
    final color = isRejected
        ? AgrisellColors.statusRedText
        : isDone
            ? AgrisellColors.forestGreen
            : isActive
                ? AgrisellColors.accentOrange
                : AgrisellColors.mutedText.withValues(alpha: 0.5);

    final icon = isRejected
        ? Icons.cancel_rounded
        : isDone
            ? Icons.check_circle_rounded
            : isActive
                ? Icons.autorenew_rounded
                : Icons.radio_button_unchecked_rounded;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isDone || isActive ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepConnector({required bool isDone}) {
    return Container(
      width: 20,
      height: 2,
      color: isDone ? AgrisellColors.forestGreen : AgrisellColors.borderLine,
      margin: const EdgeInsets.only(bottom: 12),
    );
  }

  Widget _statusChip(SafetyIncidentStatus status) {
    final (bg, fg) = switch (status) {
      SafetyIncidentStatus.submitted => (
          AgrisellColors.statusBlueBackground,
          AgrisellColors.statusBlueText
        ),
      SafetyIncidentStatus.underReview => (
          AgrisellColors.statusOrangeBackground,
          AgrisellColors.statusOrangeText
        ),
      SafetyIncidentStatus.waitingForInformation => (
          AgrisellColors.statusOrangeBackground,
          AgrisellColors.statusOrangeText
        ),
      SafetyIncidentStatus.escalated => (
          AgrisellColors.statusPurpleBackground,
          AgrisellColors.statusPurpleText
        ),
      SafetyIncidentStatus.resolved => (
          AgrisellColors.statusGreenBackground,
          AgrisellColors.statusGreenText
        ),
      SafetyIncidentStatus.rejected => (
          AgrisellColors.statusRedBackground,
          AgrisellColors.statusRedText
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
