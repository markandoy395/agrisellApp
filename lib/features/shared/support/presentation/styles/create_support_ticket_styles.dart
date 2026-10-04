import 'package:flutter/material.dart';

abstract final class CreateSupportTicketStyles {
  static const backgroundColor = Color(0xFFF5FAF8);
  static const surfaceColor = Colors.white;
  static const appBarTitleColor = Color(0xFF09252B);
  static const primaryGreen = Color(0xFF148548);
  static const headingTextColor = appBarTitleColor;
  static const mutedTextColor = Color(0xFF7C8294);
  static const screenPadding = EdgeInsets.fromLTRB(16, 18, 16, 28);
  static const sectionSpacing = 24.0;
  static const fieldLabelSpacing = 10.0;
  static const submitSpacing = 16.0;
  static const submitButtonHeight = 56.0;
  static const submitIndicatorSize = 24.0;
  static const submitIndicatorStroke = 2.5;
  static const infoCardPadding = EdgeInsets.all(16);
  static const infoIconSize = 28.0;
  static const infoContentSpacing = 12.0;
  static const appBarTitle = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
  );
  static const sectionHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: headingTextColor,
  );
  static const infoText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: headingTextColor,
    height: 1.45,
  );
  static const description = TextStyle(
    fontSize: 13,
    color: mutedTextColor,
    height: 1.45,
  );
  static const fieldText = TextStyle(
    fontSize: 14,
    color: headingTextColor,
    height: 1.5,
  );
  static const errorText = TextStyle(fontSize: 12, color: Color(0xFFB3261E));
  static const inputHint = TextStyle(
    fontSize: 14,
    color: mutedTextColor,
    height: 1.5,
  );
  static const submitButtonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF299959), Color(0xFF107B43)],
  );
  static final infoCardDecoration = BoxDecoration(
    color: const Color(0xFFF1FAF4),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFDCEFE3)),
    boxShadow: const [
      BoxShadow(color: Color(0x080D7045), blurRadius: 20, offset: Offset(0, 6)),
    ],
  );
  static const infoIconDecoration = BoxDecoration(
    color: Color(0xFFE2F4E8),
    shape: BoxShape.circle,
  );
  static final submitDecoration = BoxDecoration(
    gradient: greenGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Color(0x1A138549), blurRadius: 18, offset: Offset(0, 6)),
    ],
  );
  static final submitButtonStyle = FilledButton.styleFrom(
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    disabledForegroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
  static InputDecoration inputDecoration({
    required String hintText,
    bool hasCounter = false,
  }) => InputDecoration(
    hintText: hintText,
    hintStyle: inputHint,
    filled: true,
    fillColor: surfaceColor,
    prefixIcon: Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 10, 16),
      child: Icon(
        hasCounter
            ? Icons.description_outlined
            : Icons.chat_bubble_outline_rounded,
        color: mutedTextColor,
        size: 22,
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 52),
    contentPadding: EdgeInsets.fromLTRB(14, 16, 16, hasCounter ? 16 : 44),
    border: _border(const Color(0xFFE3E9E8)),
    enabledBorder: _border(const Color(0xFFE3E9E8)),
    focusedBorder: _border(primaryGreen),
    counterText: '',
  );
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color),
  );
  static SnackBar successSnackBar(String number) => SnackBar(
    content: Text('Support ticket $number created successfully!'),
    backgroundColor: primaryGreen,
  );
  static SnackBar errorSnackBar(String message) => SnackBar(
    content: Text(message),
    backgroundColor: const Color(0xFFD84343),
  );
}
