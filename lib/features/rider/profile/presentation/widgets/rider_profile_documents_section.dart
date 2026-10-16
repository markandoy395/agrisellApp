import 'package:flutter/material.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'rider_profile_design_components.dart';
import 'rider_document_card.dart';
import '../styles/rider_profile_design_styles.dart';

class RiderProfileDocumentsSection extends StatelessWidget {
  const RiderProfileDocumentsSection({this.onViewAll, super.key});
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: RiderRegistrationService.instance,
    builder: (context, _) {
      final service = RiderRegistrationService.instance;
      final profile = service.currentProfile;
      final documents = service.currentDocuments
          .where((doc) => doc.riderId == profile?.id)
          .toList();
      return RiderProfileSection(
        title: 'Verification documents',
        icon: Icons.verified_user_outlined,
        action: onViewAll == null
            ? null
            : TextButton(onPressed: onViewAll, child: const Text('View all')),
        children: [
          if (documents.isEmpty)
            Text(
              'No verification documents',
              style: RiderProfileDesignStyles.muted,
            ),
          for (final document in documents) ...[
            RiderDocumentCard(document: document, onTap: onViewAll),
            const SizedBox(height: 8),
          ],
        ],
      );
    },
  );
}
