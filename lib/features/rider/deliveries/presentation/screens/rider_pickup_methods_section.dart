part of 'rider_pickup_confirmation_screen.dart';

extension _PickupMethodsSection on _RiderPickupConfirmationScreenState {
  Widget _methods(PickupConfiguration config) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required confirmation',
            style: RiderPickupConfirmationStyles.sectionHeaderStyle,
          ),
          if (config.requiredMethods.contains(
            PickupConfirmationMethod.confirmationCode,
          ))
            TextField(
              controller: _code,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.number,
              decoration: RiderPickupMethodsSectionStyles.inputDecoration,
            ),
          if (config.requiredMethods.contains(PickupConfirmationMethod.qrCode))
            TextField(
              controller: _qr,
              decoration: RiderPickupMethodsSectionStyles.inputDecoration2,
            ),
          if (config.requiredMethods.contains(
                PickupConfirmationMethod.quantityConfirmation,
              ) ||
              config.requiredMethods.contains(
                PickupConfirmationMethod.weightConfirmation,
              ))
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration:
                        RiderPickupMethodsSectionStyles.inputDecoration3,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        RiderPickupMethodsSectionStyles.inputDecoration4,
                  ),
                ),
              ],
            ),
          for (final method in {
            ...config.requiredMethods,
            PickupConfirmationMethod.productPhoto,
          }.where(_requiresProof))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => _capture(method),
                icon: Icon(
                  _proofs.containsKey(method)
                      ? Icons.check_circle
                      : Icons.add_a_photo_outlined,
                  size: 17,
                ),
                label: Text(_methodLabel(method)),
              ),
            ),
        ],
      ),
    ),
  );
}
