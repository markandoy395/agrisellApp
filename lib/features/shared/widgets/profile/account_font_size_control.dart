import 'package:flutter/material.dart';

import 'package:agresell_app/core/services/app_font_size_controller.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_card_style.dart';

class AccountFontSizeControl extends StatelessWidget {
  const AccountFontSizeControl({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppFontSizeController.instance,
    builder: (context, _) {
      final controller = AppFontSizeController.instance;
      final stepper = Container(
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0EAEB)),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _stepButton(
              'Decrease font size',
              Icons.remove_rounded,
              controller.canDecrease ? controller.decrease : null,
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 48),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: const Color(0xFFF8FAFA),
              child: Text(
                controller.percentageLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AccountProfileStyle.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _stepButton(
              'Increase font size',
              Icons.add_rounded,
              controller.canIncrease ? controller.increase : null,
            ),
          ],
        ),
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: AccountProfileStyle.borderSubtle,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.text_fields_rounded,
                color: AccountProfileStyle.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  'Font size',
                  style: TextStyle(
                    color: AccountProfileStyle.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            stepper,
          ],
        ),
      );
    },
  );

  Widget _stepButton(String tooltip, IconData icon, VoidCallback? onPressed) =>
      ColoredBox(
        color: AccountProfileStyle.mint,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          color: AccountProfileStyle.green,
          icon: Icon(icon, size: 19),
          constraints: const BoxConstraints(minWidth: 36),
          padding: EdgeInsets.zero,
        ),
      );
}

typedef FarmerFontSizeControl = AccountFontSizeControl;
