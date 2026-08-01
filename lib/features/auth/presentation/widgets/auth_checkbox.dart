import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

class AuthCheckbox extends StatefulWidget {
  const AuthCheckbox({
    required this.label,
    this.value,
    this.onChanged,
    super.key,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool>? onChanged;

  @override
  State<AuthCheckbox> createState() => _AuthCheckboxState();
}

class _AuthCheckboxState extends State<AuthCheckbox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return _CheckboxRow(
      value: widget.value ?? _isChecked,
      onChanged: _handleChanged,
      child: Text(widget.label, style: _labelStyle(scale)),
    );
  }

  void _handleChanged(bool? value) {
    final isChecked = value ?? false;
    final onChanged = widget.onChanged;
    if (onChanged != null) {
      onChanged(isChecked);
      return;
    }
    setState(() => _isChecked = isChecked);
  }
}

class AuthPolicyCheckbox extends StatefulWidget {
  const AuthPolicyCheckbox({this.value, this.onChanged, super.key});

  final bool? value;
  final ValueChanged<bool>? onChanged;

  @override
  State<AuthPolicyCheckbox> createState() => _AuthPolicyCheckboxState();
}

class _AuthPolicyCheckboxState extends State<AuthPolicyCheckbox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return _CheckboxRow(
      value: widget.value ?? _isChecked,
      onChanged: _handleChanged,
      child: Expanded(
        child: Text.rich(
          TextSpan(
            text: 'I Agree with ',
            style: _labelStyle(scale),
            children: const [
              TextSpan(
                text: 'privacy',
                style: TextStyle(color: AgrisellColors.authGreen),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'policy',
                style: TextStyle(color: AgrisellColors.authGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChanged(bool? value) {
    final isChecked = value ?? false;
    final onChanged = widget.onChanged;

    if (onChanged != null) {
      onChanged(isChecked);
      return;
    }

    setState(() => _isChecked = isChecked);
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.value,
    required this.onChanged,
    required this.child,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AgrisellColors.authGreen,
              side: const BorderSide(
                color: AgrisellColors.checkboxBorder,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 9),
          child,
        ],
      ),
    );
  }
}

TextStyle _labelStyle(double scale) {
  return TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: lerpDouble(12, 14, scale),
    fontWeight: FontWeight.w400,
  );
}
