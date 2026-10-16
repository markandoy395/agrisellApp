import 'package:flutter/material.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import '../styles/rider_profile_design_styles.dart';
import '../widgets/rider_document_card.dart';
import '../widgets/rider_profile_design_components.dart';

class RiderDocumentsScreen extends StatelessWidget {
  const RiderDocumentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(
      context,
    ).copyWith(appBarTheme: RiderProfileDesignStyles.appBar),
    child: RiderSafeScaffold(
      appBar: AppBar(title: const Text('Verification documents')),
      backgroundColor: RiderProfileDesignStyles.background,
      body: ListenableBuilder(
        listenable: RiderRegistrationService.instance,
        builder: (context, _) {
          final service = RiderRegistrationService.instance;
          final profile = service.currentProfile;
          final documents = service.currentDocuments
              .where((doc) => doc.riderId == profile?.id)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                'Your private credentials are available only to you and authorized Agrisell verification staff.',
                style: RiderProfileDesignStyles.caption,
              ),
              const SizedBox(height: 16),
              if (documents.isEmpty)
                const RiderProfileSection(
                  title: 'No verification documents',
                  icon: Icons.folder_open_outlined,
                  children: [
                    Text('Upload documents from your Rider application.'),
                  ],
                ),
              for (final document in documents) ...[
                RiderDocumentCard(document: document),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    ),
  );
}
