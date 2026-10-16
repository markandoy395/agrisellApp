part of 'rider_pickup_confirmation_screen.dart';

extension _PickupMethodsSection on _RiderPickupConfirmationScreenState {
  Widget _methods(PickupConfiguration config) => RiderDetailSection(
    title: 'Required confirmation',
    icon: Icons.verified_user_outlined,
    children: [
      if (config.requiredMethods.contains(
        PickupConfirmationMethod.confirmationCode,
      )) ...[
        TextField(
          controller: _code,
          obscureText: _obscureCode,
          enabled: !_busy,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.number,
          style: RiderPickupDesignStyles.body,
          decoration: RiderPickupDesignStyles.input(
            'Pickup confirmation code',
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              tooltip: _obscureCode ? 'Show pickup code' : 'Hide pickup code',
              onPressed: () => _toggleCodeVisibility(),
              icon: Icon(
                _obscureCode
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
      if (config.requiredMethods.contains(PickupConfirmationMethod.qrCode)) ...[
        TextField(
          controller: _qr,
          enabled: !_busy,
          style: RiderPickupDesignStyles.body,
          enableSuggestions: false,
          autocorrect: false,
          decoration: RiderPickupDesignStyles.input(
            'QR scan result',
            icon: Icons.qr_code_rounded,
            hint: 'Enter QR scan result (if required)',
          ),
        ),
        const SizedBox(height: 14),
      ],
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _quantity,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              style: RiderPickupDesignStyles.body,
              decoration: RiderPickupDesignStyles.input(
                'Quantity',
                icon: Icons.inventory_2_outlined,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _weight,
              enabled: !_busy,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: RiderPickupDesignStyles.body,
              decoration: RiderPickupDesignStyles.input(
                'Weight (kg)',
                icon: Icons.scale_outlined,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text('Product photo (required)', style: RiderPickupDesignStyles.title),
      const SizedBox(height: 10),
      RiderPickupProductProof(
        reference: _proofs[PickupConfirmationMethod.productPhoto],
        localImagePath: _photoPaths[PickupConfirmationMethod.productPhoto],
        onAdd: _busy
            ? null
            : () => _capture(PickupConfirmationMethod.productPhoto),
        onRemove: _busy
            ? null
            : () => _removeProof(PickupConfirmationMethod.productPhoto),
      ),
      const SizedBox(height: 18),
      Text(
        'Additional proof (if required)',
        style: RiderPickupDesignStyles.body,
      ),
      const SizedBox(height: 10),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              constraints.maxWidth < 330 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.2
              ? 1
              : 3;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final method in [
                PickupConfirmationMethod.packagePhoto,
                PickupConfirmationMethod.farmerConfirmation,
                PickupConfirmationMethod.farmerSignature,
              ])
                SizedBox(
                  width: (constraints.maxWidth - (columns - 1) * 8) / columns,
                  child: _proofTile(
                    method,
                    required: config.requiredMethods.contains(method),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );

  Widget _proofTile(PickupConfirmationMethod method, {bool required = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (required)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('Required', style: RiderPickupDesignStyles.error),
            ),
          RiderPickupProofTile(
            label: _pickupProofLabel(method),
            icon: _pickupProofIcon(method),
            reference: _proofs[method],
            isPhoto: method.requiresImage,
            localImagePath: _photoPaths[method],
            onAdd: _busy ? null : () => _capture(method),
            onRemove: _busy ? null : () => _removeProof(method),
          ),
        ],
      );
}

String _pickupProofLabel(PickupConfirmationMethod method) => switch (method) {
  PickupConfirmationMethod.productPhoto => 'product photo',
  PickupConfirmationMethod.packagePhoto => 'package photo',
  PickupConfirmationMethod.farmerConfirmation => 'farmer confirmation',
  PickupConfirmationMethod.farmerSignature => 'signed receipt photo',
  _ => method.name,
};
IconData _pickupProofIcon(PickupConfirmationMethod method) => switch (method) {
  PickupConfirmationMethod.productPhoto => Icons.add_a_photo_outlined,
  PickupConfirmationMethod.packagePhoto => Icons.inventory_2_outlined,
  PickupConfirmationMethod.farmerConfirmation => Icons.person_outline_rounded,
  PickupConfirmationMethod.farmerSignature => Icons.draw_outlined,
  _ => Icons.verified_outlined,
};
