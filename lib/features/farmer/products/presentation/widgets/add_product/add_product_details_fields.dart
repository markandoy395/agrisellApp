part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

class _AdditionalCommodityFields extends StatelessWidget {
  const _AdditionalCommodityFields({
    required this.descriptionController,
    required this.pricingFields,
    required this.availabilityFields,
    required this.inventoryLotFields,
    required this.gradeQuality,
    required this.isOrganic,
    required this.errors,
    required this.onDescriptionChanged,
    required this.onGenerateDescription,
    required this.onGradeQualityChanged,
    required this.onOrganicChanged,
  });

  final TextEditingController descriptionController;
  final Widget pricingFields;
  final Widget availabilityFields;
  final Widget inventoryLotFields;
  final String? gradeQuality;
  final bool isOrganic;
  final Map<AddProductField, String> errors;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onGenerateDescription;
  final ValueChanged<String?> onGradeQualityChanged;
  final ValueChanged<bool> onOrganicChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputRow(
          label: 'Description *',
          child: _RoundedTextField(
            controller: descriptionController,
            textInputAction: TextInputAction.newline,
            hintText: 'Describe freshness, size, or growing method',
            errorText: errors[AddProductField.description],
            maxLines: 3,
            maxLength: 300,
            onChanged: onDescriptionChanged,
            suffixIcon: _DescriptionSampleButton(
              onPressed: onGenerateDescription,
            ),
            suffixIconConstraints:
                AddProductFormFieldsStyles.suffixIconConstraints,
          ),
        ),
        const SizedBox(height: 24),
        const _FormSectionTitle(
          icon: Icons.payments_outlined,
          title: 'Price and inventory',
        ),
        const SizedBox(height: 14),
        pricingFields,
        const SizedBox(height: 24),
        const _FormSectionTitle(
          icon: Icons.event_available_outlined,
          title: 'Availability',
        ),
        const SizedBox(height: 14),
        availabilityFields,
        const SizedBox(height: 24),
        const _FormSectionTitle(
          icon: Icons.event_repeat_outlined,
          title: 'Batch freshness',
        ),
        const SizedBox(height: 14),
        inventoryLotFields,
        const SizedBox(height: 24),
        const _FormSectionTitle(
          icon: Icons.eco_outlined,
          title: 'Product quality',
        ),
        const SizedBox(height: 14),
        _InputRow(
          label: 'Quality grade',
          child: _CompactDropdown(
            value: gradeQuality,
            hint: 'Optional',
            items: _gradeQualities,
            onChanged: onGradeQualityChanged,
          ),
        ),
        const SizedBox(height: 12),
        _InputRow(
          label: 'Organic',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              label: 'Organic product',
              child: Switch.adaptive(
                value: isOrganic,
                onChanged: onOrganicChanged,
                activeTrackColor: AgrisellColors.authGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DescriptionSampleButton extends StatelessWidget {
  const _DescriptionSampleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: 'Generate sample description',
        child: IconButton(
          key: const Key('description-sample-button'),
          onPressed: onPressed,
          style: AddProductFormFieldsStyles.sampleDescriptionButtonStyle,
          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
        ),
      ),
    );
  }
}
