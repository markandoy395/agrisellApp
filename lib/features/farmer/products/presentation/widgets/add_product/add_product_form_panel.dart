part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.nameController,
    required this.category,
    required this.categories,
    required this.errors,
    required this.details,
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onCancel,
    required this.onPublish,
  });

  final TextEditingController nameController;
  final String? category;
  final List<String> categories;
  final Map<AddProductField, String> errors;
  final Widget details;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onCancel;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      decoration: AddProductFormPanelStyles.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a new product',
            style: SharedPresentationStyles.headingTitleExtraBold,
          ),
          const SizedBox(height: 5),
          const Text(
            'Complete the details buyers need before publishing.',
            style: SharedPresentationStyles.mutedCaptionRelaxed,
          ),
          const SizedBox(height: 5),
          const Text(
            '* Required fields',
            style: SharedPresentationStyles.errorCaptionSemibold,
          ),
          const SizedBox(height: 22),
          const _FormSectionTitle(
            icon: Icons.inventory_2_outlined,
            title: 'Product details',
          ),
          const SizedBox(height: 14),
          _InputRow(
            label: 'Product name *',
            child: _RoundedTextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              hintText: 'e.g. Fresh tomatoes',
              errorText: errors[AddProductField.name],
              onChanged: onNameChanged,
            ),
          ),
          const SizedBox(height: 14),
          _InputRow(
            label: 'Category *',
            child: _CompactDropdown(
              value: category,
              hint: 'Select category',
              items: categories,
              errorText: errors[AddProductField.category],
              onChanged: onCategoryChanged,
            ),
          ),
          const SizedBox(height: 14),
          details,
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: AddProductFormPanelStyles.outlinedButtonStyle,
                    child: const Text(
                      'Cancel',
                      style: SharedPresentationStyles.bodyBold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    onPressed: onPublish,
                    style: AddProductFormPanelStyles.filledButtonStyle,
                    icon: const Icon(Icons.publish_rounded, size: 17),
                    label: const Text(
                      'Publish Product',
                      style: SharedPresentationStyles.captionExtraBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AgrisellColors.authGreen, size: 18),
        const SizedBox(width: 8),
        Text(title, style: SharedPresentationStyles.headingSubtitleExtraBold),
      ],
    );
  }
}
