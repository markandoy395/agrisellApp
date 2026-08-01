import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_editor.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class ShippingAddressCard extends StatelessWidget {
  const ShippingAddressCard({
    required this.address,
    required this.onSave,
    this.fullName = '',
    this.phoneNumber = '',
    this.latitude,
    this.longitude,
    super.key,
  });

  final String address;
  final Future<void> Function(BuyerShippingAddress address) onSave;
  final String fullName;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    final hasAddress = address.trim().isNotEmpty;
    return ProfileCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionLabel(text: 'Shipping Address'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AddressIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: hasAddress
                      ? _SavedAddress(
                          address: address,
                          onEdit: () => _showEditor(context),
                        )
                      : _MissingAddress(
                          onSetAddress: () => _showEditor(context),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditor(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ShippingAddressEditor(
      onSave: onSave,
      initialAddress: address,
      fullName: fullName,
      phoneNumber: phoneNumber,
      latitude: latitude,
      longitude: longitude,
    ),
  );
}

class _AddressIcon extends StatelessWidget {
  const _AddressIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AgrisellColors.authGreen.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(
      Icons.local_shipping_outlined,
      color: AgrisellColors.authGreen,
    ),
  );
}

class _SavedAddress extends StatelessWidget {
  const _SavedAddress({required this.address, required this.onEdit});

  final String address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Delivery address', style: ProfileTextStyles.infoLabel(context)),
      const SizedBox(height: 3),
      Text(address, style: ProfileTextStyles.infoValue(context)),
      const SizedBox(height: 4),
      TextButton(onPressed: onEdit, child: const Text('Edit address')),
    ],
  );
}

class _MissingAddress extends StatelessWidget {
  const _MissingAddress({required this.onSetAddress});

  final VoidCallback onSetAddress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'No shipping address set',
        style: ProfileTextStyles.infoValue(context),
      ),
      const SizedBox(height: 3),
      Text(
        'Add one before placing an order.',
        style: ProfileTextStyles.profileDescription(context),
      ),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: onSetAddress,
        icon: const Icon(Icons.add_location_alt_outlined, size: 18),
        label: const Text('Set shipping address'),
      ),
    ],
  );
}
