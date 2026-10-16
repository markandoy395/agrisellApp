import 'package:flutter/material.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

import '../controllers/farmer_discount_form_controller.dart';
import '../styles/farmer_discount_dialog_styles.dart';
import 'farmer_discount_form.dart';

Future<FarmerDiscount?> showFarmerDiscountDialog(
  BuildContext context, {
  required int farmId,
  FarmerDiscount? existingDiscount,
  FarmerDashboardProduct? initialProduct,
  List<FarmerDashboardProduct> availableProducts = const [],
  FarmerDiscountRepository discountRepository =
      const FarmerDiscountRepository(),
}) {
  return showModalBottomSheet<FarmerDiscount>(
    context: context,
    isScrollControlled: true,
    backgroundColor: FarmerDiscountDialogStyles.transparent,
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
  late final FarmerDiscountFormController _form;

  @override
  void initState() {
    super.initState();
    _form = FarmerDiscountFormController(
      farmId: widget.farmId,
      existingDiscount: widget.existingDiscount,
      initialProduct: widget.initialProduct,
      availableProducts: widget.availableProducts,
      repository: widget.discountRepository,
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _form.startsAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (mounted && picked != null) {
      _form.setStartDate(picked);
    }
  }

  Future<void> _pickEndDate() async {
    final base = _form.startsAt ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _form.endsAt ?? base.add(const Duration(days: 7)),
      firstDate: base,
      lastDate: base.add(const Duration(days: 365)),
    );
    if (mounted && picked != null) {
      _form.setEndDate(picked);
    }
  }

  Future<void> _save() async {
    final discount = await _form.save();
    if (mounted && discount != null) Navigator.of(context).pop(discount);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _form,
    builder: (context, _) => Padding(
      padding: FarmerDiscountDialogStyles.keyboardPadding(context),
      child: FarmerDiscountForm(
        form: _form,
        onPickStartDate: _pickStartDate,
        onPickEndDate: _pickEndDate,
        onSave: _save,
      ),
    ),
  );
}
