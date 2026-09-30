import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

Future<FarmerDiscount?> showFarmerDiscountDialog(
  BuildContext context, {
  required int farmId,
  FarmerDiscount? existingDiscount,
  FarmerDashboardProduct? initialProduct,
  List<FarmerDashboardProduct> availableProducts = const [],
  FarmerDiscountRepository discountRepository = const FarmerDiscountRepository(),
}) {
  return showModalBottomSheet<FarmerDiscount>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FarmerDiscountDialogContent(
      farmId: farmId,
      existingDiscount: existingDiscount,
      initialProduct: initialProduct,
      availableProducts: availableProducts,
      discountRepository: discountRepository,
    ),
  );
}

class _FarmerDiscountDialogContent extends StatefulWidget {
  const _FarmerDiscountDialogContent({
    required this.farmId,
    this.existingDiscount,
    this.initialProduct,
    this.availableProducts = const [],
    this.discountRepository = const FarmerDiscountRepository(),
  });

  final int farmId;
  final FarmerDiscount? existingDiscount;
  final FarmerDashboardProduct? initialProduct;
  final List<FarmerDashboardProduct> availableProducts;
  final FarmerDiscountRepository discountRepository;

  @override
  State<_FarmerDiscountDialogContent> createState() =>
      _FarmerDiscountDialogContentState();
}

class _FarmerDiscountDialogContentState
    extends State<_FarmerDiscountDialogContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  late final TextEditingController _promoCodeController;

  late String _discountType;
  DateTime? _startsAt;
  DateTime? _endsAt;
  late Set<int> _selectedCommodityIds;
  var _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingDiscount;

    _nameController = TextEditingController(text: existing?.name ?? '');
    _valueController = TextEditingController(
      text: existing != null ? existing.discountValue.toString() : '',
    );
    _promoCodeController = TextEditingController(
      text: existing?.promoCode ?? '',
    );

    _discountType = existing?.discountType ?? 'percentage';
    _startsAt = existing?.startsAt;
    _endsAt = existing?.endsAt;

    if (existing != null) {
      _selectedCommodityIds = existing.commodityIds.toSet();
    } else if (widget.initialProduct?.commodityId != null) {
      _selectedCommodityIds = {widget.initialProduct!.commodityId!};
    } else {
      _selectedCommodityIds = {};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startsAt = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final base = _startsAt ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsAt ?? base.add(const Duration(days: 7)),
      firstDate: base,
      lastDate: base.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endsAt = picked);
    }
  }

  String _previewPrice(FarmerDashboardProduct product) {
    final val = double.tryParse(_valueController.text.trim()) ?? 0.0;
    if (val <= 0) return product.price;

    final base = double.tryParse(
          RegExp(r'[\d.]+').firstMatch(product.price)?.group(0) ?? '',
        ) ??
        0.0;

    double result;
    if (_discountType == 'percentage') {
      result = base * (1 - val / 100);
    } else if (_discountType == 'sale_price') {
      result = val;
    } else {
      result = base - val;
    }

    if (result <= 0) return 'Invalid discount';
    return '\u20b1${result.toStringAsFixed(2)}';
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter a promotion name.');
      return;
    }

    final value = double.tryParse(_valueController.text.trim());
    if (value == null || value <= 0) {
      setState(() => _errorMessage = 'Please enter a valid discount value.');
      return;
    }

    if (_discountType == 'percentage' && value > 90) {
      setState(() => _errorMessage = 'Percentage discount cannot exceed 90%.');
      return;
    }

    if (_endsAt != null && _startsAt != null && _endsAt!.isBefore(_startsAt!)) {
      setState(() => _errorMessage = 'End date must be after start date.');
      return;
    }

    if (_selectedCommodityIds.isEmpty) {
      setState(
        () => _errorMessage = 'Select at least one product for this discount.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final promoCode = _promoCodeController.text.trim().isEmpty
          ? null
          : _promoCodeController.text.trim().toUpperCase();

      if (widget.existingDiscount != null) {
        await widget.discountRepository.updateDiscount(
          saleId: widget.existingDiscount!.saleId,
          farmId: widget.farmId,
          name: name,
          discountType: _discountType,
          discountValue: value,
          startsAt: _startsAt,
          endsAt: _endsAt,
          promoCode: promoCode,
          commodityIds: _selectedCommodityIds.toList(growable: false),
        );

        if (!mounted) return;
        Navigator.of(context).pop(
          FarmerDiscount(
            saleId: widget.existingDiscount!.saleId,
            farmId: widget.farmId,
            name: name,
            discountType: _discountType,
            discountValue: value,
            startsAt: _startsAt,
            endsAt: _endsAt,
            promoCode: promoCode,
            commodityIds: _selectedCommodityIds.toList(growable: false),
          ),
        );
      } else {
        final newSaleId = await widget.discountRepository.createDiscount(
          farmId: widget.farmId,
          name: name,
          discountType: _discountType,
          discountValue: value,
          startsAt: _startsAt,
          endsAt: _endsAt,
          promoCode: promoCode,
          commodityIds: _selectedCommodityIds.toList(growable: false),
        );

        if (!mounted) return;
        Navigator.of(context).pop(
          FarmerDiscount(
            saleId: newSaleId,
            farmId: widget.farmId,
            name: name,
            discountType: _discountType,
            discountValue: value,
            startsAt: _startsAt,
            endsAt: _endsAt,
            promoCode: promoCode,
            commodityIds: _selectedCommodityIds.toList(growable: false),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to save discount. Please try again.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDiscount != null;
    final allProducts = widget.availableProducts.isNotEmpty
        ? widget.availableProducts
        : (widget.initialProduct != null ? [widget.initialProduct!] : <FarmerDashboardProduct>[]);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AgrisellColors.borderLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AgrisellColors.forestSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: AgrisellColors.authGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Promotion' : 'Create Promotion / Discount',
                    style: const TextStyle(
                      color: AgrisellColors.brandBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Promotion Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgrisellColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Weekend Flash Sale, Harvest Promo',
                      filled: true,
                      fillColor: AgrisellColors.homeBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AgrisellColors.borderLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AgrisellColors.borderLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AgrisellColors.authGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discount Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgrisellColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTypeChoice('percentage', 'Percentage (%)'),
                      const SizedBox(width: 8),
                      _buildTypeChoice('amount', 'Amount Off (\u20b1)'),
                      const SizedBox(width: 8),
                      _buildTypeChoice('sale_price', 'Sale Price (\u20b1)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _discountType == 'percentage'
                        ? 'Discount Percentage (%)'
                        : _discountType == 'sale_price'
                            ? 'New Sale Price (\u20b1)'
                            : 'Discount Amount (\u20b1)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgrisellColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: _discountType == 'percentage' ? 'e.g. 15' : 'e.g. 50',
                      prefixText: _discountType == 'percentage' ? '' : '\u20b1 ',
                      suffixText: _discountType == 'percentage' ? '%' : '',
                      filled: true,
                      fillColor: AgrisellColors.homeBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AgrisellColors.borderLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AgrisellColors.borderLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AgrisellColors.authGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Promo Code (Optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgrisellColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Leave blank to automatically apply discount to selected products.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AgrisellColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _promoCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g. HARVEST10',
                      filled: true,
                      fillColor: AgrisellColors.homeBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AgrisellColors.borderLine),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AgrisellColors.borderLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AgrisellColors.authGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgrisellColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickStartDate,
                          icon: const Icon(Icons.calendar_today_rounded, size: 14),
                          label: Text(
                            _startsAt == null
                                ? 'Start Date (Now)'
                                : '${_startsAt!.month}/${_startsAt!.day}/${_startsAt!.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AgrisellColors.brandBlack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickEndDate,
                          icon: const Icon(Icons.event_rounded, size: 14),
                          label: Text(
                            _endsAt == null
                                ? 'End Date (Optional)'
                                : '${_endsAt!.month}/${_endsAt!.day}/${_endsAt!.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AgrisellColors.brandBlack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Apply to Products',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AgrisellColors.brandBlack,
                        ),
                      ),
                      const Spacer(),
                      if (allProducts.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_selectedCommodityIds.length == allProducts.length) {
                                _selectedCommodityIds.clear();
                              } else {
                                _selectedCommodityIds = allProducts
                                    .map((p) => p.commodityId)
                                    .whereType<int>()
                                    .toSet();
                              }
                            });
                          },
                          child: Text(
                            _selectedCommodityIds.length == allProducts.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AgrisellColors.authGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (allProducts.isEmpty)
                    const Text(
                      'No products available to discount.',
                      style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AgrisellColors.homeBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AgrisellColors.borderLine),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allProducts.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = allProducts[index];
                          final id = product.commodityId;
                          final isSelected = id != null && _selectedCommodityIds.contains(id);

                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: AgrisellColors.authGreen,
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  'Base: ${product.price}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AgrisellColors.mutedText,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 11,
                                    color: AgrisellColors.authGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sale: ${_previewPrice(product)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AgrisellColors.authGreen,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onChanged: id == null
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedCommodityIds.add(id);
                                      } else {
                                        _selectedCommodityIds.remove(id);
                                      }
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AgrisellColors.statusRedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AgrisellColors.authGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'Update Promotion' : 'Save & Apply Discount',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChoice(String type, String label) {
    final isSelected = _discountType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _discountType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AgrisellColors.forestSoft
                : AgrisellColors.homeBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AgrisellColors.authGreen
                  : AgrisellColors.borderLine,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AgrisellColors.authGreen
                    : AgrisellColors.brandBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
