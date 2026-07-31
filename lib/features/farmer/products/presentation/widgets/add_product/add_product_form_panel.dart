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
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a new product',
            style: TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Complete the details buyers need before publishing.',
            style: TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '* Required fields',
            style: TextStyle(
              color: AgrisellColors.statusRedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AgrisellColors.authGreen,
                      side: const BorderSide(color: AgrisellColors.authGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: AgrisellColors.authGreen,
                      foregroundColor: AgrisellColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.publish_rounded, size: 17),
                    label: const Text(
                      'Publish Product',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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
        Text(
          title,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
