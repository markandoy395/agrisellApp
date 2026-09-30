import 'package:flutter/material.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'account_card_style.dart';

class AccountPersonalInfoCard extends StatefulWidget {
  const AccountPersonalInfoCard({
    required this.profile,
    this.onEditProfile,
    this.initiallyExpanded = true,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback? onEditProfile;
  final bool initiallyExpanded;

  @override
  State<AccountPersonalInfoCard> createState() =>
      _AccountPersonalInfoCardState();
}

class _AccountPersonalInfoCardState extends State<AccountPersonalInfoCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant AccountPersonalInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthDate =
        ProfileBirthDate.parse(widget.profile.dateOfBirth).formatted;
    final entries = [
      ('First name', widget.profile.firstName),
      ('Last name', widget.profile.lastName),
      ('Name extension', widget.profile.extensionName),
      ('Phone number', widget.profile.phoneNumber),
      (
        'Date of birth',
        birthDate.isEmpty ? widget.profile.dateOfBirth : birthDate,
      ),
      ('Email', widget.profile.email),
    ];

    return AccountProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AccountProfileStyle.mint,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AccountProfileStyle.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Personal information',
                      style: TextStyle(
                        color: AccountProfileStyle.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isExpanded
                          ? const Color(0xFFE2EFEA)
                          : AccountProfileStyle.mint,
                      foregroundColor: AccountProfileStyle.green,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      _isExpanded
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16,
                    ),
                    label: Text(
                      _isExpanded ? 'Hide' : 'Display',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFEFF3F4)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Account details',
                          style: TextStyle(
                            color: AccountProfileStyle.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.onEditProfile != null)
                        TextButton.icon(
                          onPressed: widget.onEditProfile,
                          style: TextButton.styleFrom(
                            foregroundColor: AccountProfileStyle.green,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(
                            'Edit',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: Color(0xFFE1E7E9)),
                  for (var index = 0; index < entries.length; index++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              entries[index].$1,
                              style: const TextStyle(
                                color: AccountProfileStyle.muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: Text(
                              entries[index].$2.trim().isEmpty
                                   ? '—'
                                  : entries[index].$2,
                              style: const TextStyle(
                                color: AccountProfileStyle.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < entries.length - 1)
                      const Divider(height: 1, color: Color(0xFFEDF0F2)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
