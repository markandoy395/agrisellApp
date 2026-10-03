import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';

enum RiderExitChoice { continueRegistration, saveAndExit, discard }

abstract final class RiderRegistrationExitDialog {
  static Future<bool> show(
    BuildContext context, {
    required RiderSignUpController controller,
    required Future<void> Function() onExit,
  }) async {
    final choice = await showDialog<RiderExitChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Your Rider Sign-Up is not yet complete. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, RiderExitChoice.continueRegistration),
            child: const Text('Continue Registration'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, RiderExitChoice.saveAndExit),
            child: const Text('Save and Exit'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, RiderExitChoice.discard),
            child: const Text('Discard Registration'),
          ),
        ],
      ),
    );
    if (choice == null || choice == RiderExitChoice.continueRegistration) {
      return false;
    }
    if (choice == RiderExitChoice.saveAndExit) {
      await controller.saveNow();
    }
    if (choice == RiderExitChoice.discard) {
      await controller.discard();
    }
    await onExit();
    return true;
  }
}
