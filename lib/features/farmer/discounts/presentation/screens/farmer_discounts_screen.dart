import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import '../styles/farmer_discounts_styles.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import '../controllers/farmer_discounts_controller.dart';
import '../widgets/farmer_discount_dialog.dart';
import '../widgets/farmer_discounts_body.dart';

class FarmerDiscountsScreen extends StatefulWidget {
  const FarmerDiscountsScreen({
    this.farmId,
    this.discountRepository = const FarmerDiscountRepository(),
    this.commodityRepository = const FarmerCommodityRepository(),
    super.key,
  });

  final int? farmId;
  final FarmerDiscountRepository discountRepository;
  final FarmerCommodityRepository commodityRepository;

  @override
  State<FarmerDiscountsScreen> createState() => _FarmerDiscountsScreenState();
}

class _FarmerDiscountsScreenState extends State<FarmerDiscountsScreen> {
  late final FarmerDiscountsController _controller;
  @override
  void initState() {
    super.initState();
    _controller = FarmerDiscountsController(
      farmId: widget.farmId,
      discountRepository: widget.discountRepository,
      commodityRepository: widget.commodityRepository,
    );
    _controller.load();
  }

  @override
  void didUpdateWidget(covariant FarmerDiscountsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.discountRepository = widget.discountRepository;
    _controller.commodityRepository = widget.commodityRepository;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openDiscountDialog([FarmerDiscount? discount]) async {
    final farmId = _controller.farmId;
    if (farmId == null) return;
    final saved = await showFarmerDiscountDialog(
      context,
      farmId: farmId,
      existingDiscount: discount,
      availableProducts: _controller.products,
      discountRepository: widget.discountRepository,
    );
    if (saved == null || !mounted) return;
    final action = discount == null ? 'created' : 'updated';
    ScaffoldMessenger.of(context).showAppSnackBar(
      SnackBar(content: Text('Promotion "${saved.name}" $action.')),
    );
    _controller.load();
  }

  Future<void> _deleteDiscount(FarmerDiscount discount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promotion?'),
        content: Text(
          'Are you sure you want to delete "${discount.name}"? '
          'Discounts will be removed from all associated products.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FarmerDiscountsStyles.confirmDeleteButton,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _controller.deleteDiscount(discount);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(content: Text('Promotion "${discount.name}" deleted.')),
      );
      _controller.load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('Unable to delete promotion. Please try again.'),
        ),
      );
    }
  }

  Future<void> _toggleDiscountEnabled(
    FarmerDiscount discount,
    bool enabled,
  ) async {
    try {
      await _controller.setEnabled(discount, enabled);
      if (!mounted) return;
      _controller.load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Unable to update status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Discounts & Promotions',
          style: FarmerDiscountsStyles.appBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDiscountDialog,
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Promotion',
          style: FarmerDiscountsStyles.boldButtonText,
        ),
      ),
      body: FarmerDiscountsBody(
        controller: _controller,
        onCreate: _openDiscountDialog,
        onEdit: _openDiscountDialog,
        onDelete: _deleteDiscount,
        onToggle: _toggleDiscountEnabled,
      ),
    ),
  );
}
