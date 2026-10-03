import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerInformationRequestBannerStyles {
  static final containerDecoration = BoxDecoration(
    color: const Color(0xFFFFF8E1),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFE65100).withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static final containerDecoration2 = BoxDecoration(
    color: const Color(0xFFFFE082),
    borderRadius: BorderRadius.circular(10),
  );

  static const actionRequiredInformationRequestedText = TextStyle(
    color: Color(0xFFBF360C),
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const messageText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static final containerDecoration3 = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: const Color(0xFFFFCC80)),
  );

  static const itemText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE65100),
  );

  static const textStyle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w500,
  );

  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE65100),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
