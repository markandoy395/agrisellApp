part of 'rider_sign_up_personal_step.dart';

class _RiderPhoneField extends StatefulWidget {
  const _RiderPhoneField({required this.controller, required this.value});
  final RiderSignUpController controller;
  final String value;
  @override
  State<_RiderPhoneField> createState() => _RiderPhoneFieldState();
}

class _RiderPhoneFieldState extends State<_RiderPhoneField> {
  late final _phoneController = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant _RiderPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_phoneController.text != widget.value) {
      _phoneController.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RiderSignUpTextField(
        label: 'Phone number (09XXXXXXXXX)',
        value: widget.value,
        controller: _phoneController,
        error: widget.controller.errorFor(RiderSignUpFields.mobile),
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
        onChanged: (value) =>
            widget.controller.updateValue(RiderSignUpFields.mobile, value),
      ),
      PhoneNumberSyncControl(
        controller: _phoneController,
        onSynced: (value) =>
            widget.controller.updateValue(RiderSignUpFields.mobile, value),
      ),
      const SizedBox(height: 10),
    ],
  );
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.controller});
  final RiderSignUpController controller;
  @override
  Widget build(BuildContext context) {
    final value = controller.draft.value(RiderSignUpFields.dateOfBirth);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Date of birth',
        contentPadding: riderSignUpFieldContentPadding,
        errorText: controller.errorFor(RiderSignUpFields.dateOfBirth),
        labelStyle: const TextStyle(
          color: AgrisellColors.mutedText,
          fontSize: 13,
        ),
        floatingLabelStyle: const TextStyle(
          color: AgrisellColors.authGreen,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AgrisellColors.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AgrisellColors.authGreen,
            width: 1.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _select(context, value),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? 'Select your date of birth' : value,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const Icon(Icons.calendar_month_outlined),
          ],
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context, String value) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(value) ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      controller.updateValue(
        RiderSignUpFields.dateOfBirth,
        selected.toIso8601String().split('T').first,
      );
    }
  }
}
