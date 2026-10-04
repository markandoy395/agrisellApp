import 'package:flutter/material.dart';
import '../styles/create_support_ticket_styles.dart';

class CreateSupportTicketMessageField extends StatelessWidget {
  const CreateSupportTicketMessageField({
    required this.controller,
    required this.validator,
    super.key,
  });
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => FormField<String>(
    initialValue: controller.text,
    validator: validator,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            TextField(
              controller: controller,
              minLines: 5,
              maxLines: 8,
              maxLength: 4000,
              style: CreateSupportTicketStyles.fieldText,
              textCapitalization: TextCapitalization.sentences,
              onChanged: field.didChange,
              decoration: CreateSupportTicketStyles.inputDecoration(
                hintText:
                    'Provide details, context, or questions for our support team...',
              ),
            ),
            Positioned(
              right: 14,
              bottom: 12,
              child: IgnorePointer(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) => Text(
                    value.text.characters.length.toString() + '/4000',
                    style: CreateSupportTicketStyles.description,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (field.hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6),
            child: Text(
              field.errorText!,
              style: CreateSupportTicketStyles.errorText,
            ),
          ),
      ],
    ),
  );
}
