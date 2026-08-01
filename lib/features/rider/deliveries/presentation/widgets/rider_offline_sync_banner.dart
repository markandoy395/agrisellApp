import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_offline_sync.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';

class RiderOfflineSyncBanner extends StatelessWidget {
  const RiderOfflineSyncBanner({required this.controller, super.key});

  final RiderDeliveryController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.offlineSyncState;
    final pending = controller.pendingOfflineActionCount;
    if (state == RiderOfflineSyncState.live && pending == 0) {
      return const SizedBox.shrink();
    }
    final action = switch (state) {
      RiderOfflineSyncState.waiting || RiderOfflineSyncState.synchronized =>
        controller.synchronizeOfflineActions,
      RiderOfflineSyncState.failed => controller.retryFailedOfflineActions,
      _ => null,
    };
    return Semantics(
      liveRegion: true,
      label: 'Offline synchronization: ${state.label}',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AgrisellColors.borderLine),
        ),
        child: Row(
          children: [
            Icon(_iconFor(state), size: 18, color: AgrisellColors.authGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _description(state, pending),
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (action != null)
              TextButton(
                onPressed: () => action(),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(
                  state == RiderOfflineSyncState.failed ? 'Retry' : 'Sync',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(RiderOfflineSyncState state) => switch (state) {
    RiderOfflineSyncState.offline => Icons.cloud_off_rounded,
    RiderOfflineSyncState.requiresAttention ||
    RiderOfflineSyncState.failed => Icons.error_outline_rounded,
    RiderOfflineSyncState.synchronizing => Icons.sync_rounded,
    _ => Icons.cloud_done_outlined,
  };

  String _description(RiderOfflineSyncState state, int pending) {
    if (state == RiderOfflineSyncState.requiresAttention) {
      return 'Some delivery actions require review before they can sync.';
    }
    if (pending > 0) return '${state.label}: $pending action(s).';
    return state.label;
  }
}
