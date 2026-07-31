import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';

class FarmerAddressSyncControl extends StatefulWidget {
  const FarmerAddressSyncControl({
    required this.controllers,
    required this.onSynced,
    super.key,
  });

  final FarmerSignupControllers controllers;
  final VoidCallback onSynced;

  @override
  State<FarmerAddressSyncControl> createState() =>
      _FarmerAddressSyncControlState();
}

class _FarmerAddressSyncControlState extends State<FarmerAddressSyncControl> {
  var _isSynced = false;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: Row(
      children: [
        const Icon(Icons.sync_rounded, size: 18),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Same as farmer address',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch.adaptive(
            value: _isSynced,
            onChanged: widget.controllers.hasPersonalAddressDetails
                ? _onChanged
                : null,
          ),
        ),
      ],
    ),
  );

  void _onChanged(bool value) {
    if (value) {
      widget.controllers.copyPersonalAddressDetailsToFarm();
      widget.onSynced();
    }
    setState(() => _isSynced = value);
  }
}
