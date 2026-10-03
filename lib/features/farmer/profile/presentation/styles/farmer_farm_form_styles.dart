import 'package:flutter/material.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_style.dart';

abstract final class FarmerFarmFormStyles {
  static const textStyle = TextStyle(color: Colors.red);

  static const textStyle2 = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const textStyle3 = TextStyle(
    fontSize: 14,
    color: FarmerProfileStyle.ink,
  );

  static InputDecoration inputDecoration(String? hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF8999B3)),
  );
}

abstract final class FarmerFarmFormStyle {
  static const borderColor = Color(0xFFCBD3E2);
  static final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: borderColor),
  );
  static final decoration = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: FarmerProfileStyle.green, width: 1.5),
    ),
  );

  static Widget label(String text, IconData icon, {bool required = true}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF18783E), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: text),
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: FarmerFarmFormStyles.textStyle,
                    ),
                ],
              ),
              style: FarmerFarmFormStyles.textStyle2,
            ),
          ),
        ],
      );
}
