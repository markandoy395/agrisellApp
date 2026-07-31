import 'dart:io';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderDashboardHeader extends StatelessWidget {
  const RiderDashboardHeader({
    required this.profile,
    required this.workStatus,
    required this.unreadNotifications,
    required this.onOpenNotifications,
    super.key,
  });

  final RiderProfile? profile;
  final RiderAvailability workStatus;
  final int unreadNotifications;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final firstName = profile?.firstName.trim();
    return RiderPageHeader(
      title: firstName == null || firstName.isEmpty
          ? 'Hello, Rider'
          : 'Hello, $firstName',
      subtitle: 'Current work status: ${workStatus.displayLabel}',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            foregroundImage: _photoImage(profile?.profilePhotoUrl),
            child: const Icon(Icons.person_rounded, size: 20),
          ),
          IconButton(
            tooltip: unreadNotifications == 0
                ? 'Notifications'
                : '$unreadNotifications unread notifications',
            onPressed: onOpenNotifications,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

ImageProvider<Object>? _photoImage(String? value) {
  if (value == null || value.isEmpty) return null;
  if (Uri.tryParse(value)?.hasScheme ?? false) return NetworkImage(value);
  return FileImage(File(value));
}
