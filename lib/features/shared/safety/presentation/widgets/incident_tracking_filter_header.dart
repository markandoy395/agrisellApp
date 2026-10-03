import 'package:flutter/material.dart';

import '../controllers/safety_incident_controller.dart';
import '../styles/incident_tracking_styles.dart';

class IncidentTrackingFilterHeader extends StatelessWidget {
  const IncidentTrackingFilterHeader({super.key, required this.controller});
  final SafetyIncidentController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: IncidentTrackingStyles.surface,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: IncidentTrackingStyles.filterPadding,
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
    final isSelected = controller.filter == filterKey;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(
        label,
        style: isSelected
            ? IncidentTrackingStyles.selectedFilter
            : IncidentTrackingStyles.unselectedFilter,
      ),
      selected: isSelected,
      selectedColor: IncidentTrackingStyles.selectedFilterColor,
      backgroundColor: IncidentTrackingStyles.filterBackground,
      onSelected: (_) => controller.setFilter(filterKey),
    );
  }
}
