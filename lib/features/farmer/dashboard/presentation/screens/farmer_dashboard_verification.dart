part of 'farmer_dashboard_screen.dart';

extension _FarmerDashboardVerification on _FarmerDashboardScreenState {
  Future<void> _loadVerificationDetails() async {
    final details = await FarmerProductCoordinator.loadVerificationDetails(
      widget.verificationRepository,
    );
    if (mounted && details != null) {
      _refresh(() => _verificationDetails = details);
    }
  }

  Future<void> _openResubmitInformation() async {
    final updated = await FarmerProductCoordinator.resubmitInformation(
      context: context,
      repository: widget.verificationRepository,
      details: _verificationDetails,
    );
    if (updated != null && mounted) {
      _refresh(() => _verificationDetails = updated);
    }
  }
}
