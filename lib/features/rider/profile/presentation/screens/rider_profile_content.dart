part of 'rider_profile_screen.dart';

extension _RiderProfileContent on _RiderProfileScreenState {
  Widget _buildProfile(BuildContext context) {
    final profile = _profile;
    return Material(
      color: RiderProfileDesignStyles.background,
      child: profile != null && _mode == _RiderProfileMode.settings
          ? RiderSettingsPanel(
              profile: profile,
              onEditProfile: _editProfile,
              onVehicle: () => _open(const RiderVehicleScreen()),
              onDocuments: () => _open(const RiderDocumentsScreen()),
              onChangePassword: _changePassword,
              onSafety: _openSafety,
              onIncidentHistory: _openIncidentHistory,
              onSupport: () => _open(const SupportCenterScreen()),
              onSwitchAccount: _switchAccount,
              onLogout: _logout,
              onBack: () => _setMode(_RiderProfileMode.overview),
            )
          : Column(
              children: [
                RiderProfileHeader(
                  onSettings: profile == null
                      ? null
                      : () => _setMode(_RiderProfileMode.settings),
                ),
                Expanded(
                  child: profile == null
                      ? RiderProfileEmptyState(
                          onRegister: () => _open(const RiderSignUpScreen()),
                        )
                      : AnimatedBuilder(
                          animation: _analytics,
                          builder: (context, _) => RiderProfileOverview(
                            profile: profile,
                            performance: _analytics.ratings.summary,
                            onEdit: _editProfile,
                            onVehicle: () => _open(const RiderVehicleScreen()),
                            onDocuments: () =>
                                _open(const RiderDocumentsScreen()),
                            onEarnings: () => _open(
                              RiderEarningsScreen(
                                riderId: profile.id,
                                controller: _analytics,
                              ),
                            ),
                            onHistory: () => _open(
                              RiderHistoryScreen(
                                riderId: profile.id,
                                controller: _analytics,
                                deliveryController: widget.deliveryController,
                              ),
                            ),
                            onRatings: () => _open(
                              RiderRatingsScreen(
                                riderId: profile.id,
                                controller: _analytics,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
