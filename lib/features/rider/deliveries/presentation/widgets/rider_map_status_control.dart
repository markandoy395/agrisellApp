import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_map_design_styles.dart';

class RiderMapStatusControl extends StatelessWidget {
  const RiderMapStatusControl({
    required this.online,
    this.onChanged,
    required this.onRefresh,
    super.key,
  });
  final bool? online;
  final ValueChanged<bool>? onChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isOnline = online ?? false;
    return PopupMenuButton<String>(
      tooltip: 'Work status and GPS',
      onSelected: (value) {
        if (value == 'refresh') {
          onRefresh();
          return;
        }
        onChanged?.call(value == 'online');
      },
      itemBuilder: (_) => [
        if (onChanged != null) ...[
          const PopupMenuItem(value: 'online', child: Text('Go Online')),
          const PopupMenuItem(value: 'offline', child: Text('Go Offline')),
        ],
        const PopupMenuItem(value: 'refresh', child: Text('Refresh location')),
      ],
      child: Material(
        color: Colors.transparent,
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
                      : online!
                      ? 'Online'
                      : 'Offline',
                  style: isOnline
                      ? RiderMapDesignStyles.onlineText
                      : RiderMapDesignStyles.caption,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: isOnline
                      ? AgrisellColors.surface
                      : AgrisellColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
