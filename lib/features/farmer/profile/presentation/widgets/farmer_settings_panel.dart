import 'package:flutter/material.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_font_size_control.dart';
import 'farmer_profile_style.dart';
import 'farmer_gcash_settings_sheet.dart';

export 'package:agresell_app/features/shared/widgets/profile/account_font_size_control.dart';

class FarmerSettingsPanel extends StatelessWidget {
  const FarmerSettingsPanel({
    required this.profile,
    required this.onEditProfile,
    required this.onEditFarm,
    required this.onSwitchAccount,
    required this.onLogout,
    required this.onBack,
    this.onReviews,
    this.onSafety,
    this.onIncidentHistory,
    this.onSupport,
    this.scrollController,
    super.key,
  });
  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onEditFarm;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;
  final VoidCallback onBack;
  final VoidCallback? onReviews;
  final VoidCallback? onSafety;
  final VoidCallback? onIncidentHistory;
  final VoidCallback? onSupport;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => Material(
    color: FarmerProfileStyle.background,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
    clipBehavior: Clip.antiAlias,
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCFDAD6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Header bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: FarmerProfileStyle.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Close settings',
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: FarmerProfileStyle.mint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FarmerProfileStyle.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: FarmerProfileStyle.green,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // User identity card — gradient hero
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF062E1D), Color(0xFF0B5435), Color(0xFF0E6B43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.55, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFB8F0D6),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.headerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                _group('Account', [
                  _action(
                    Icons.person_outline_rounded,
                    'Edit farmer profile',
                    'Update your contact information',
                    onEditProfile,
                  ),
                  _action(
                    Icons.agriculture_outlined,
                    'Edit farm',
                    'Update your farm and crop details',
                    onEditFarm,
                  ),
                ]),
                _group('Reviews & Feedback', [
                  if (onReviews != null)
                    _action(
                      Icons.star_outline_rounded,
                      'Customer reviews & ratings',
                      'View ratings breakdown and buyer feedback',
                      onReviews!,
                    ),
                ]),
                _group('Display', [const FarmerFontSizeControl()]),
                _group('Safety', [
                  if (onSafety != null)
                    _action(
                      Icons.shield_outlined,
                      'Safety & emergency SOS',
                      'Report a safety issue or emergency alert',
                      onSafety!,
                    ),
                  if (onIncidentHistory != null)
                    _action(
                      Icons.history_rounded,
                      'Incident history & status',
                      'Track status of submitted safety reports',
                      onIncidentHistory!,
                    ),
                ]),
                _group('Payments', [
                  _action(
                    Icons.account_balance_wallet_outlined,
                    'GCash payment details',
                    'Manage where buyers send payments',
                    () => showFarmerGcashSettingsSheet(context),
                  ),
                ]),
                _group('Help & Support', [
                  _action(
                    Icons.support_agent_rounded,
                    'Customer support tickets',
                    'Open and track helpdesk inquiries with Agrisell',
                    onSupport ??
                        () {
                          Navigator.of(context).push(
                            agrisellPageRoute<void>(
                              builder: (_) => const SupportCenterScreen(),
                            ),
                          );
                        },
                  ),
                ]),
                _group('Session', [
                  _action(
                    Icons.switch_account_outlined,
                    'Switch account',
                    'Choose a saved account on this device',
                    onSwitchAccount,
                  ),
                  _action(
                    Icons.logout_rounded,
                    'Logout',
                    'Sign out of this device',
                    onLogout,
                    destructive: true,
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _group(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: FarmerProfileStyle.sectionLabel,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: FarmerProfileStyle.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FarmerProfileStyle.borderSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF08683F).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    const Divider(height: 1, indent: 58, endIndent: 0, color: Color(0xFFEEF3F0)),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _action(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool destructive = false,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _SettingsIcon(icon, destructive: destructive),
          const SizedBox(width: 12),
          Expanded(
            child: _SettingsLabel(title, subtitle, destructive: destructive),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: destructive
                ? const Color(0xFFD63031)
                : const Color(0xFFA0B8AF),
            size: 20,
          ),
        ],
      ),
    ),
  );
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon(this.icon, {this.destructive = false});
  final IconData icon;
  final bool destructive;
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      gradient: destructive
          ? const LinearGradient(
              colors: [Color(0xFFFFF0F0), Color(0xFFFFE4E4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: destructive
            ? const Color(0xFFFFCCCC)
            : FarmerProfileStyle.borderSubtle,
        width: 1,
      ),
    ),
    child: Icon(
      icon,
      color: destructive ? const Color(0xFFD63031) : FarmerProfileStyle.green,
      size: 20,
    ),
  );
}

class _SettingsLabel extends StatelessWidget {
  const _SettingsLabel(this.title, this.subtitle, {this.destructive = false});
  final String title;
  final String subtitle;
  final bool destructive;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: destructive ? const Color(0xFFD63031) : FarmerProfileStyle.ink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
      const SizedBox(height: 1),
      Text(
        subtitle,
        style: FarmerProfileStyle.tileSubtitle,
      ),
    ],
  );
}

typedef FarmerFontSizeControl = AccountFontSizeControl;
