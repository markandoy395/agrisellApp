import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';

export 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_availability_note.dart';

const riderSignUpFieldContentPadding = EdgeInsets.fromLTRB(14, 16, 14, 16);

class RiderSignUpHeader extends StatelessWidget {
  const RiderSignUpHeader({required this.step, super.key});
  final RiderSignUpStep step;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Step ${step.index + 1} of ${RiderSignUpStep.values.length}',
        style: const TextStyle(
          color: AgrisellColors.authGreen,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        step.title,
        style: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: (step.index + 1) / RiderSignUpStep.values.length,
        minHeight: 6,
        borderRadius: BorderRadius.circular(99),
        color: AgrisellColors.authGreen,
        backgroundColor: AgrisellColors.limeSoft,
      ),
    ],
  );
}

class RiderSignUpTextField extends StatelessWidget {
  const RiderSignUpTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.controller,
    this.error,
    this.helper,
    this.keyboardType,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.onTap,
    this.readOnly = false,
    super.key,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? error;
  final String? helper;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final VoidCallback? onTap;
  final bool readOnly;
  @override
  Widget build(BuildContext context) {
    final valid = value.isNotEmpty && error == null;
    return TextFormField(
      key: ValueKey(label),
      controller: controller,
      initialValue: controller == null ? value : null,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AgrisellColors.mutedText,
          fontSize: 13,
        ),
        floatingLabelStyle: const TextStyle(
          color: AgrisellColors.authGreen,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: riderSignUpFieldContentPadding,
        helperText: helper,
        errorText: error,
        suffixIcon: error != null
            ? const Icon(
                Icons.error_outline_rounded,
                color: AgrisellColors.statusRedText,
              )
            : valid
            ? const Icon(
                Icons.check_circle_rounded,
                color: AgrisellColors.statusGreenText,
              )
            : null,
        filled: true,
        fillColor: AgrisellColors.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error == null
                ? AgrisellColors.borderLine
                : AgrisellColors.statusRedText,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AgrisellColors.authGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class RiderSignUpActions extends StatelessWidget {
  const RiderSignUpActions({
    required this.isFirst,
    required this.isLast,
    required this.enabled,
    required this.loading,
    required this.onPrevious,
    required this.onContinue,
    super.key,
  });
  final bool isFirst;
  final bool isLast;
  final bool enabled;
  final bool loading;
  final VoidCallback onPrevious;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (!isFirst)
        Expanded(
          child: OutlinedButton(
            onPressed: onPrevious,
            child: const Text('Previous'),
          ),
        ),
      if (!isFirst) const SizedBox(width: 10),
      Expanded(
        child: FilledButton(
          onPressed: enabled && !loading ? onContinue : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(40)),
          child: loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isLast ? 'Submit Rider Application' : 'Continue'),
        ),
      ),
    ],
  );
}
