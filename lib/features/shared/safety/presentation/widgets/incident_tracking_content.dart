import 'package:flutter/material.dart';

import '../controllers/safety_incident_controller.dart';
import '../styles/incident_tracking_styles.dart';
import 'incident_tracking_card.dart';

class IncidentTrackingContent extends StatelessWidget {
  const IncidentTrackingContent({
    super.key,
    required this.controller,
    required this.onReport,
  });
  final SafetyIncidentController controller;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.incidents.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: IncidentTrackingStyles.green),
      );
    }

    final incidents = controller.filteredIncidents;

    if (incidents.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: IncidentTrackingStyles.emptyTopSpacing(context)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: IncidentTrackingStyles.emptyIconPadding,
                  decoration: IncidentTrackingStyles.emptyIcon,
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: IncidentTrackingStyles.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Safety Incidents Found',
                  style: IncidentTrackingStyles.emptyTitle,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: IncidentTrackingStyles.emptyMessagePadding,
                  child: Text(
                    controller.filter == 'all'
                        ? 'You have not reported any safety incidents or SOS alerts.'
                        : 'No reports found matching the selected filter.',
                    textAlign: TextAlign.center,
                    style: IncidentTrackingStyles.emptyMessage,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  style: IncidentTrackingStyles.submitReportButton,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Submit Safety Report'),
                  onPressed: onReport,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: IncidentTrackingStyles.listPadding,
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return IncidentTrackingCard(incident: incident);
      },
    );
  }
}
