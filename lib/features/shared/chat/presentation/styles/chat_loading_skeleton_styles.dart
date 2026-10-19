import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ChatLoadingSkeletonStyles {
  static const row = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
  );
  static const avatar = BoxDecoration(
    color: AgrisellColors.borderLine,
    shape: BoxShape.circle,
  );
  static const block = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );
  static BoxDecoration bubble(bool own) => BoxDecoration(
    color: own ? AgrisellColors.forestSoft : AgrisellColors.borderLine,
    borderRadius: const BorderRadius.all(Radius.circular(16)),
  );
}
