import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_editor.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

class ShippingAddressCard extends StatelessWidget {
  const ShippingAddressCard({
    required this.address,
    required this.onSave,
    this.fullName = '',
    this.phoneNumber = '',
    this.latitude,
    this.longitude,
    this.gpsGateway,
    super.key,
  });

  final String address;
  final Future<void> Function(BuyerShippingAddress address) onSave;
  final String fullName;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final GpsLocationGateway? gpsGateway;

  @override
  Widget build(BuildContext context) {
    final hasAddress = address.trim().isNotEmpty;
    return BuyerProfileCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AddressIcon(),
            const SizedBox(width: 14),
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
    );
  }

  Future<void> _showEditor(BuildContext context) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ShippingAddressEditor(
        onSave: onSave,
        initialAddress: address,
        fullName: fullName,
        phoneNumber: phoneNumber,
        latitude: latitude,
        longitude: longitude,
        gpsGateway: gpsGateway,
      ),
    );
    if (saved != true || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showAppSnackBar(
        const SnackBar(content: Text('Shipping address saved.')),
      );
  }
}

class _AddressIcon extends StatelessWidget {
  const _AddressIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: BuyerProfileStyle.borderSubtle,
        width: 1,
      ),
    ),
    child: const Icon(
      Icons.local_shipping_outlined,
      color: BuyerProfileStyle.green,
      size: 22,
    ),
  );
}

class _SavedAddress extends StatelessWidget {
  const _SavedAddress({required this.address, required this.onEdit});

  final String address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onEdit,
    borderRadius: BorderRadius.circular(8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delivery address',
                style: BuyerProfileStyle.tileTitle,
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: BuyerProfileStyle.tileSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(
            foregroundColor: BuyerProfileStyle.green,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: const Text(
            'Edit address',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MissingAddress extends StatelessWidget {
  const _MissingAddress({required this.onSetAddress});

  final VoidCallback onSetAddress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'No shipping address set',
        style: BuyerProfileStyle.tileTitle,
      ),
      const SizedBox(height: 2),
      const Text(
        'Add one before placing an order.',
        style: BuyerProfileStyle.tileSubtitle,
      ),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: onSetAddress,
        style: FilledButton.styleFrom(
          backgroundColor: BuyerProfileStyle.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        ),
        icon: const Icon(Icons.add_location_alt_outlined, size: 16),
        label: const Text(
          'Set shipping address',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
