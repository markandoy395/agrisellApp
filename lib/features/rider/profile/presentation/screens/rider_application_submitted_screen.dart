import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/rider/profile/data/rider_verification_repository.dart';
import 'package:agresell_app/features/rider/profile/data/supabase_rider_verification_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_application_status_cards.dart';

class RiderApplicationSubmittedScreen extends StatelessWidget {
  const RiderApplicationSubmittedScreen({required this.reference, super.key});
  final String reference;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 68,
                color: AgrisellColors.statusGreenText,
              ),
              const SizedBox(height: 14),
              const Text(
                'Rider application submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reference: $reference',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              const _PendingMessage(),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    agrisellPageRoute<void>(
                      builder: (_) =>
                          RiderApplicationStatusScreen(reference: reference),
                    ),
                  ),
                  child: const Text('View application status'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: () => _returnToLogin(context),
                  child: const Text('Return to login'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _returnToLogin(BuildContext context) async {
  await AuthSessionService.instance.clear();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    agrisellPageRoute<void>(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

enum RiderApplicationStatus { pending, rejected }

class RiderApplicationStatusScreen extends StatefulWidget {
  const RiderApplicationStatusScreen({
    required this.reference,
    this.status = RiderApplicationStatus.pending,
    this.repository,
    this.initialDetails,
    super.key,
  });

  final String reference;
  final RiderApplicationStatus status;
  final RiderVerificationRepository? repository;
  final RiderVerificationDetails? initialDetails;

  @override
  State<RiderApplicationStatusScreen> createState() =>
      _RiderApplicationStatusScreenState();
}

class _RiderApplicationStatusScreenState
    extends State<RiderApplicationStatusScreen> {
  late final RiderVerificationRepository _repository =
      widget.repository ?? SupabaseRiderVerificationRepository();

  RiderVerificationDetails? _details;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _details = widget.initialDetails;
    if (_details == null) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      final details = await _repository.getVerificationDetails(
        reference: widget.reference,
      );
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _isPending =>
      _details?.isPending ?? (widget.status == RiderApplicationStatus.pending);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    appBar: AppBar(
      title: const Text('Application status'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh status',
          onPressed: _isLoading ? null : _loadDetails,
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _loadDetails,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth < 360 ? 16.0 : 24.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(padding, 24, padding, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rider application',
                        style: TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Keep this reference handy if you need help with your application.',
                        style: TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RiderApplicationReferenceCard(
                        reference: widget.reference,
                      ),
                      const SizedBox(height: 16),
                      RiderApplicationStatusCard(
                        isPending: _isPending,
                        details: _details,
                      ),
                      if (_details != null) ...[
                        if (_details!.hasRejectionReason ||
                            _details!.hasMessage ||
                            _details!.hasMissingItems) ...[
                          const SizedBox(height: 16),
                          RiderVerificationFeedbackCard(details: _details!),
                        ],
                        if (_details!.hasRejectedDocuments) ...[
                          const SizedBox(height: 16),
                          RiderRejectedDocumentsCard(details: _details!),
                        ],
                      ],
                      const SizedBox(height: 16),
                      RiderApplicationNextStepsCard(
                        isPending: _isPending,
                        details: _details,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => _returnToLogin(context),
                          child: const Text('Return to login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _PendingMessage extends StatelessWidget {
  const _PendingMessage();

  @override
  Widget build(BuildContext context) => const Text(
    'Your information and documents will be reviewed before your account is activated. We will notify you when its status changes.',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 12,
      color: AgrisellColors.mutedText,
      height: 1.35,
    ),
  );
}
