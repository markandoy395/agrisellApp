import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/password_policy.dart';

class AuthPasswordRequirements extends StatelessWidget {
  const AuthPasswordRequirements({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) return const SizedBox.shrink();

        final requirements = PasswordPolicy.evaluate(value.text);
        if (requirements.every((requirement) => requirement.isMet)) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password requirements',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              for (var index = 0; index < requirements.length; index += 2)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index + 2 < requirements.length ? 4 : 0,
                  ),
                  child: _RequirementRow(
                    first: requirements[index],
                    second: index + 1 < requirements.length
                        ? requirements[index + 1]
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.first, this.second});

  final PasswordRequirement first;
  final PasswordRequirement? second;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _RequirementItem(requirement: first)),
        const SizedBox(width: 8),
        Expanded(
          child: second == null
              ? const SizedBox.shrink()
              : _RequirementItem(requirement: second!),
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({required this.requirement});

  final PasswordRequirement requirement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          requirement.isMet
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked,
          size: 15,
          color: requirement.isMet
              ? AgrisellColors.statusGreenText
              : AgrisellColors.mutedText,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(requirement.label, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
