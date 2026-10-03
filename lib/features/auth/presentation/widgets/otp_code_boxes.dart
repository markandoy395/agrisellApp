import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/otp_verification_styles.dart';
import 'package:flutter/services.dart';

class OtpCodeBoxes extends StatelessWidget {
  const OtpCodeBoxes({
    required this.code,
    required this.length,
    required this.accentColor,
    required this.hasError,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
  });

  final String code;
  final int length;
  final Color accentColor;
  final bool hasError;
  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final mid = (length / 2).ceil();
    final group1Indices = List.generate(mid, (i) => i);
    final group2Indices = List.generate(length - mid, (i) => mid + i);

    return Semantics(
      label: '$length digit verification code',
      textField: true,
      child: GestureDetector(
        onTap: focusNode.requestFocus,
        child: SizedBox(
          height: 54,
          child: Stack(
            children: [
              Row(
                children: [
                  _buildCodeGroup(
                    indices: group1Indices,
                    code: code,
                    isFocused: focusNode.hasFocus,
                    hasError: hasError,
                    accentColor: accentColor,
                  ),
                  if (group2Indices.isNotEmpty) ...[
                    const Padding(
                      padding: OtpVerificationStyles.codeSeparatorPadding,
                      child: Text(
                        '—',
                        style: OtpVerificationStyles.codeSeparatorText,
                      ),
                    ),
                    _buildCodeGroup(
                      indices: group2Indices,
                      code: code,
                      isFocused: focusNode.hasFocus,
                      hasError: hasError,
                      accentColor: accentColor,
                    ),
                  ],
                ],
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: length,
                    onChanged: onChanged,
                    decoration: OtpVerificationStyles.hiddenCodeInput,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeGroup({
    required List<int> indices,
    required String code,
    required bool isFocused,
    required bool hasError,
    required Color accentColor,
  }) {
    final hasCurrentInGroup = indices.contains(code.length) && isFocused;
    final borderColor = hasError
        ? AgrisellColors.statusRedText
        : hasCurrentInGroup
        ? accentColor
        : AgrisellColors.borderLine;

    return Expanded(
      child: Container(
        height: 54,
        decoration: OtpVerificationStyles.codeGroupDecoration(
          borderColor,
          hasCurrentInGroup,
        ),
        child: Row(
          children: [
            for (int i = 0; i < indices.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  height: double.infinity,
                  color: AgrisellColors.borderLine,
                ),
              Expanded(
                child: _buildDigitCell(
                  digit: indices[i] < code.length ? code[indices[i]] : '',
                  isCurrent: indices[i] == code.length && isFocused,
                  accentColor: accentColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDigitCell({
    required String digit,
    required bool isCurrent,
    required Color accentColor,
  }) {
    return Center(
      child: isCurrent && digit.isEmpty
          ? Container(
              width: 2,
              height: 22,
              decoration: OtpVerificationStyles.cursorDecoration(accentColor),
            )
          : Text(digit, style: OtpVerificationStyles.digitText),
    );
  }
}
