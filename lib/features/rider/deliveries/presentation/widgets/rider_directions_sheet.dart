import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';

void showRiderDirectionsSheet(BuildContext context, RiderRoutePlan route) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: route.instructions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final step = route.instructions[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: AgrisellColors.forestSoft,
              child: Text(
                '${index + 1}',
                style: SharedPresentationStyles.caption,
              ),
            ),
            title: Text(step.text, style: SharedPresentationStyles.body),
            subtitle: Text(
              '${step.distanceMeters.round()} m',
              style: SharedPresentationStyles.caption,
            ),
          );
        },
      ),
    ),
  );
}
