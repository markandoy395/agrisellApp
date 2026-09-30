import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/widgets/farmer_discount_dialog.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_context.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

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
  int? _farmId;
  List<FarmerDiscount> _discounts = const [];
  List<FarmerDashboardProduct> _products = const [];
  var _isLoading = true;
  var _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _farmId = widget.farmId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      var farmId = _farmId;
      if (farmId == null) {
        final context = await FarmerCommodityContext.load();
        farmId = context.farmId;
        _farmId = farmId;
      }

      final results = await Future.wait([
        widget.discountRepository.loadDiscounts(farmId),
        widget.commodityRepository.loadProducts(),
      ]);

      if (!mounted) return;
      setState(() {
        _discounts = results[0] as List<FarmerDiscount>;
        _products = results[1] as List<FarmerDashboardProduct>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _openCreateDiscount() async {
    final farmId = _farmId;
    if (farmId == null) return;

    final created = await showFarmerDiscountDialog(
      context,
      farmId: farmId,
      availableProducts: _products,
      discountRepository: widget.discountRepository,
    );

    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(content: Text('Promotion "${created.name}" created.')),
      );
      _loadData();
    }
  }

  Future<void> _openEditDiscount(FarmerDiscount discount) async {
    final farmId = _farmId;
    if (farmId == null) return;

    final updated = await showFarmerDiscountDialog(
      context,
      farmId: farmId,
      existingDiscount: discount,
      availableProducts: _products,
      discountRepository: widget.discountRepository,
    );

    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(content: Text('Promotion "${updated.name}" updated.')),
      );
      _loadData();
    }
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AgrisellColors.statusRedText,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.discountRepository.deleteDiscount(
        discount.saleId,
        discount.farmId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(content: Text('Promotion "${discount.name}" deleted.')),
      );
      _loadData();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Unable to delete promotion. Please try again.')),
      );
    }
  }

  Future<void> _toggleDiscountEnabled(FarmerDiscount discount, bool enabled) async {
    try {
      await widget.discountRepository.updateDiscount(
        saleId: discount.saleId,
        farmId: discount.farmId,
        name: discount.name,
        discountType: discount.discountType,
        discountValue: discount.discountValue,
        startsAt: discount.startsAt,
        endsAt: discount.endsAt,
        promoCode: discount.promoCode,
        isEnabled: enabled,
        commodityIds: discount.commodityIds,
      );
      if (!mounted) return;
      _loadData();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Unable to update status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _discounts.where((d) => d.isActive).length;
    final scheduledCount = _discounts.where((d) => d.isScheduled).length;

    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Discounts & Promotions',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDiscount,
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Promotion',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AgrisellColors.authGreen,
              ),
            )
          : _loadFailed
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load promotions.',
                        style: TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AgrisellColors.authGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AgrisellColors.authGreen,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              _buildSummaryCard(
                                'Active',
                                '$activeCount',
                                const Color(0xFFE8F5E9),
                                AgrisellColors.authGreen,
                              ),
                              const SizedBox(width: 10),
                              _buildSummaryCard(
                                'Scheduled',
                                '$scheduledCount',
                                const Color(0xFFFFF3E0),
                                const Color(0xFFE65100),
                              ),
                              const SizedBox(width: 10),
                              _buildSummaryCard(
                                'Total',
                                '${_discounts.length}',
                                AgrisellColors.surface,
                                AgrisellColors.brandBlack,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_discounts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_offer_outlined,
                                  size: 64,
                                  color: AgrisellColors.borderLine,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No promotions created yet',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AgrisellColors.brandBlack,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    'Create limited-time sales and promo codes to boost your product orders!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AgrisellColors.mutedText,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _openCreateDiscount,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AgrisellColors.authGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text(
                                    'Create First Promotion',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final discount = _discounts[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDiscountCard(discount),
                                );
                              },
                              childCount: _discounts.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String count,
    Color bg,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AgrisellColors.borderLine),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AgrisellColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountCard(FarmerDiscount discount) {
    final statusColor = switch (discount.status) {
      'Active' => AgrisellColors.authGreen,
      'Scheduled' => const Color(0xFFE65100),
      'Ended' => AgrisellColors.mutedText,
      _ => AgrisellColors.statusRedText,
    };

    return Container(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AgrisellColors.borderLine),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AgrisellColors.forestSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    discount.discountLabel,
                    style: const TextStyle(
                      color: AgrisellColors.authGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    discount.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: discount.isEnabled,
                  activeTrackColor: AgrisellColors.authGreen,
                  onChanged: (val) => _toggleDiscountEnabled(discount, val),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              discount.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AgrisellColors.brandBlack,
              ),
            ),
            if (discount.hasCode) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    size: 13,
                    color: AgrisellColors.mutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Code: ${discount.promoCode}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AgrisellColors.authGreen,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AgrisellColors.mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  discount.formattedDates,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgrisellColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (discount.commodities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: discount.commodities.map((c) {
                  return Chip(
                    label: Text(
                      c['commodity_name']?.toString() ?? 'Product',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AgrisellColors.homeBackground,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(growable: false),
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openEditDiscount(discount),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AgrisellColors.brandBlack,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteDiscount(discount),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: AgrisellColors.statusRedText,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
