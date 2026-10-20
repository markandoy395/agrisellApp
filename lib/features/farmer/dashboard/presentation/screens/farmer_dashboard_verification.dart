part of 'farmer_dashboard_screen.dart';

extension _FarmerDashboardVerification on _FarmerDashboardScreenState {
  Future<void> _loadVerificationDetails() async {
    final owner = AuthSessionService.instance.currentAccount?.id;
    final generation = ++_verificationGeneration;
    final details = await FarmerProductCoordinator.loadVerificationDetails(
      widget.verificationRepository,
    );
    if (mounted &&
        generation == _verificationGeneration &&
        owner == AuthSessionService.instance.currentAccount?.id &&
        details != null) {
      _refresh(() => _verificationDetails = details);
    }
  }

  bool get _canPostProducts => _verificationDetails == null
      ? AuthSessionService.instance.currentAccount?.isFarmerVerified ?? false
      : _verificationDetails?.verificationStatus?.trim().toLowerCase() ==
                'verified' &&
            (_verificationDetails?.accountStatus ?? 'active')
                    .trim()
                    .toLowerCase() ==
                'active';

  void _watchVerification() {
    unawaited(_loadVerificationDetails());
    _verificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) unawaited(_loadVerificationDetails());
    });
    if (!AgrisellSupabase.isInitialized) return;
    final owner = AgrisellSupabase.client.auth.currentUser?.id;
    if (owner == null) return;
    _verificationChannel = AgrisellSupabase.client
        .channel('farmer-approval:$owner:${identityHashCode(this)}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'farmers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'auth_user_id',
            value: owner,
          ),
          callback: (_) {
            if (mounted) unawaited(_loadVerificationDetails());
          },
        )
        .subscribe();
  }

  void _disposeVerificationUpdates() {
    _verificationGeneration++;
    _verificationTimer?.cancel();
    final channel = _verificationChannel;
    if (channel != null && AgrisellSupabase.isInitialized) {
      unawaited(AgrisellSupabase.client.removeChannel(channel));
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
