part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

class _AvailabilityFields extends StatelessWidget {
  const _AvailabilityFields({
    required this.productionStage,
    required this.sellingOption,
    required this.showExpectedDate,
    required this.expectedDate,
    required this.dateWindow,
    required this.errors,
    required this.onProductionStageChanged,
    required this.onSellingOptionChanged,
    required this.onSelectExpectedDate,
  });

  final ProductProductionStage productionStage;
  final ProductSaleStatus sellingOption;
  final bool showExpectedDate;
  final DateTime? expectedDate;
  final AvailabilityDateWindow dateWindow;
  final Map<AddProductField, String> errors;
  final ValueChanged<ProductProductionStage?> onProductionStageChanged;
  final ValueChanged<ProductSaleStatus?> onSellingOptionChanged;
  final VoidCallback onSelectExpectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputRow(
          label: 'Production stage *',
          child: _CompactDropdown(
            value: productionStage,
            hint: 'Select stage',
            items: ProductProductionStage.values,
            itemLabel: (stage) => stage.farmerLabel,
            onChanged: onProductionStageChanged,
          ),
        ),
        const SizedBox(height: 14),
        _InputRow(
          label: 'Selling option *',
          child: _CompactDropdown(
            value: sellingOption,
            hint: 'Select option',
            items: _sellingOptions,
            itemLabel: (status) => status.farmerLabel,
            onChanged: onSellingOptionChanged,
          ),
        ),
        if (showExpectedDate) ...[
          const SizedBox(height: 14),
          _InputRow(
            label: 'Expected availability *',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onSelectExpectedDate,
                    icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: Text(
                      expectedDate == null
                          ? 'Select date'
                          : _displayDate(expectedDate!),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: AgrisellColors.authGreen,
                      side: BorderSide(
                        color: errors.containsKey(AddProductField.harvestDate)
                            ? AgrisellColors.statusRedText
                            : AgrisellColors.borderLine,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  errors[AddProductField.harvestDate] ?? dateWindow.guidance,
                  style: TextStyle(
                    color: errors.containsKey(AddProductField.harvestDate)
                        ? AgrisellColors.statusRedText
                        : AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<ProductSaleStatus> get _sellingOptions {
    if (productionStage == ProductProductionStage.harvested) {
      return ProductSaleStatus.values;
    }
    return const [
      ProductSaleStatus.preOrder,
      ProductSaleStatus.notAcceptingOrders,
    ];
  }

  String _displayDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';
}
