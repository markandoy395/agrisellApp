import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_font_size_control.dart';

class BuyerSettingsPanel extends StatelessWidget {
  const BuyerSettingsPanel({
    required this.profile,
    required this.onEditProfile,
    required this.onSwitchAccount,
    required this.onLogout,
    required this.onBack,
    this.onSafety,
    this.onIncidentHistory,
    this.onSupport,
    this.scrollController,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;
  final VoidCallback onBack;
  final VoidCallback? onSafety;
  final VoidCallback? onIncidentHistory;
  final VoidCallback? onSupport;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => Material(
    color: BuyerProfileStyle.background,
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
                      fontFamily: 'Poppins',
                      color: BuyerProfileStyle.ink,
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
                        color: BuyerProfileStyle.mint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BuyerProfileStyle.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: BuyerProfileStyle.green,
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
                            fontFamily: 'Poppins',
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
                            fontFamily: 'Poppins',
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
                    'Edit buyer profile',
                    onEditProfile,
                  ),
                ]),
                _group('Display', [const AccountFontSizeControl()]),
                _group('Safety', [
                  if (onSafety != null)
                    _action(
                      Icons.shield_outlined,
                      'Safety & emergency SOS',
                      onSafety!,
                    ),
                  if (onIncidentHistory != null)
                    _action(
                      Icons.history_rounded,
                      'Incident history & status',
                      onIncidentHistory!,
                    ),
                ]),
                _group('Support', [
                  _action(
                    Icons.support_agent_rounded,
                    'Customer support tickets',
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
                    onSwitchAccount,
                  ),
                  _action(
                    Icons.logout_rounded,
                    'Logout',
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
            style: BuyerProfileStyle.sectionLabel,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: BuyerProfileStyle.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
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
    VoidCallback onTap, {
    String? subtitle,
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
            child: _SettingsLabel(title, subtitle: subtitle, destructive: destructive),
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
            : BuyerProfileStyle.borderSubtle,
        width: 1,
      ),
    ),
    child: Icon(
      icon,
      color: destructive ? const Color(0xFFD63031) : BuyerProfileStyle.green,
      size: 20,
    ),
  );
}

class _SettingsLabel extends StatelessWidget {
  const _SettingsLabel(this.title, {this.subtitle, this.destructive = false});
  final String title;
  final String? subtitle;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: BuyerProfileStyle.tileTitle.copyWith(
          color: destructive ? const Color(0xFFD63031) : BuyerProfileStyle.ink,
        ),
      ),
      if (subtitle != null && subtitle!.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text(
          subtitle!,
          style: BuyerProfileStyle.tileSubtitle,
        ),
      ],
    ],
  );
}
