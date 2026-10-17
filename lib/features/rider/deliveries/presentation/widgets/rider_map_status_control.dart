import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_map_design_styles.dart';

/// Read-only status from the shared rider availability controller.
class RiderMapStatusControl extends StatelessWidget {
  const RiderMapStatusControl({required this.online, super.key});

  final bool? online;

  @override
  Widget build(BuildContext context) {
    final isOnline = online ?? false;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: isOnline
            ? RiderMapDesignStyles.onlinePill
            : RiderMapDesignStyles.offlinePill,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.radio_button_checked,
                size: 18,
                color: isOnline
                    ? AgrisellColors.surface
                    : AgrisellColors.mutedText,
              ),
              const SizedBox(width: 8),
              Text(
                online == null
                    ? 'Work status'
                    : isOnline
                    ? 'Online'
                    : 'Offline',
                style: isOnline
                    ? RiderMapDesignStyles.onlineText
                    : RiderMapDesignStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
