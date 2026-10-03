import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class OrderFeedbackStyles {
  static const titleStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const subtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const commentInputStyle = TextStyle(fontSize: 13);

  static const errorTextStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const submitButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static final submitButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static OutlineInputBorder feedbackBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: color),
  );

  static InputDecoration feedbackInputDecoration({
    required String labelText,
    required String hintText,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: feedbackBorder(AgrisellColors.borderLine),
    enabledBorder: feedbackBorder(AgrisellColors.borderLine),
    focusedBorder: feedbackBorder(AgrisellColors.authGreen),
  );
}
