import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';
import 'farmer_profile_style.dart';

class FarmerProfileEditFields extends StatelessWidget {
  const FarmerProfileEditFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.extensionNameController,
    required this.phoneController,
    required this.emailController,
    required this.birthDate,
    required this.onBirthDateChanged,
    required this.onCancel,
    required this.onSave,
    super.key,
  });
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController extensionNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final ProfileBirthDate birthDate;
  final ValueChanged<ProfileBirthDate> onBirthDateChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  static InputDecoration decoration({
    String? hint,
    IconData? icon,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFA3AFB4), fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF3F7F7),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: FarmerProfileStyle.ink, size: 22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC7D3D7)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC7D3D7)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: FarmerProfileStyle.green, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final first = _field('First name', firstNameController);
          final last = _field('Last name', lastNameController);
          if (constraints.maxWidth < 280 ||
              MediaQuery.textScalerOf(context).scale(14) > 19) {
            return Column(children: [first, const SizedBox(height: 16), last]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 16),
              Expanded(child: last),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      _field(
        'Name extension',
        extensionNameController,
        optional: true,
        hint: 'e.g., Jr., Sr., III',
      ),
      const SizedBox(height: 16),
      _field(
        'Phone number',
        phoneController,
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
      ),
      const SizedBox(height: 8),
      PhoneNumberSyncControl(controller: phoneController, spacious: true),
      const SizedBox(height: 12),
      const Text('Date of birth', style: _labelStyle),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _dateSelect(
              'Day',
              birthDate.day,
              [for (var d = 1; d <= birthDate.maxDay; d++) (d, '$d')],
              (d) => onBirthDateChanged(birthDate.copyWith(day: d)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: _dateSelect(
              'Month',
              birthDate.month,
              [
                for (var m = 1; m <= 12; m++)
                  (m, ProfileBirthDate.months[m - 1]),
              ],
              (m) => onBirthDateChanged(birthDate.copyWith(month: m)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _dateSelect(
              'Year',
              birthDate.year,
              [for (var y = DateTime.now().year; y >= 1900; y--) (y, '$y')],
              (y) => onBirthDateChanged(birthDate.copyWith(year: y)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _field(
        'Email',
        emailController,
        icon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        readOnly: true,
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: FarmerProfileStyle.green,
                side: const BorderSide(color: FarmerProfileStyle.green),
                minimumSize: const Size(0, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF197A48),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save changes',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  static const _labelStyle = TextStyle(
    color: FarmerProfileStyle.ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    bool optional = false,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: Text(label, style: _labelStyle)),
          if (optional)
            const Text(
              'Optional',
              style: TextStyle(color: FarmerProfileStyle.muted, fontSize: 12),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Semantics(
        label: label,
        child: TextField(
          key: ValueKey('farmer-edit-$label'),
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: keyboardType == null
              ? TextCapitalization.words
              : TextCapitalization.none,
          style: const TextStyle(color: FarmerProfileStyle.ink, fontSize: 14),
          decoration: decoration(hint: hint, icon: icon),
        ),
      ),
    ],
  );

  Widget _dateSelect(
    String label,
    int? value,
    List<(int, String)> options,
    ValueChanged<int> onChanged,
  ) => DropdownButtonFormField<int>(
    key: ValueKey('farmer-birth-$label-$value'),
    initialValue: value,
    isExpanded: true,
    menuMaxHeight: 280,
    style: const TextStyle(color: FarmerProfileStyle.ink, fontSize: 13),
    icon: const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Color(0xFF244752),
      size: 18,
    ),
    decoration: decoration().copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
    ),
    hint: Text(label),
    items: [
      for (final option in options)
        DropdownMenuItem(
          value: option.$1,
          child: Text(option.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}
