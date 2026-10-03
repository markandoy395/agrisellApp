import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import '../styles/farmer_discounts_styles.dart';
import '../controllers/farmer_discounts_controller.dart';
import 'farmer_discount_summary_card.dart';
import 'farmer_promotion_card.dart';

class FarmerDiscountsBody extends StatelessWidget {
  const FarmerDiscountsBody({
    required this.controller,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    super.key,
  });
  final FarmerDiscountsController controller;
  final VoidCallback onCreate;
  final ValueChanged<FarmerDiscount> onEdit;
  final ValueChanged<FarmerDiscount> onDelete;
  final void Function(FarmerDiscount, bool) onToggle;
  @override
  Widget build(BuildContext context) {
    final activeCount = controller.discounts
        .where((discount) => discount.isActive)
        .length;
    final scheduledCount = controller.discounts
        .where((discount) => discount.isScheduled)
        .length;
    return controller.isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AgrisellColors.authGreen),
          )
        : controller.loadFailed
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unable to load promotions.',
                  style: FarmerDiscountsStyles.loadError,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: controller.load,
                  style: FarmerDiscountsStyles.retryButton,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: controller.load,
            color: AgrisellColors.authGreen,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: FarmerDiscountsStyles.summarySectionPadding,
                    child: Row(
                      children: [
                        FarmerDiscountSummaryCard(
                          'Active',
                          '$activeCount',
                          FarmerDiscountsStyles.activeSummaryBackground,
                          AgrisellColors.authGreen,
                        ),
                        const SizedBox(width: 10),
                        FarmerDiscountSummaryCard(
                          'Scheduled',
                          '$scheduledCount',
                          FarmerDiscountsStyles.scheduledSummaryBackground,
                          FarmerDiscountsStyles.scheduledColor,
                        ),
                        const SizedBox(width: 10),
                        FarmerDiscountSummaryCard(
                          'Total',
                          '${controller.discounts.length}',
                          AgrisellColors.surface,
                          AgrisellColors.brandBlack,
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.discounts.isEmpty)
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
                            style: FarmerDiscountsStyles.promotionTitle,
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding:
                                FarmerDiscountsStyles.emptyDescriptionPadding,
                            child: Text(
                              'Create limited-time sales and promo codes to boost your product orders!',
                              textAlign: TextAlign.center,
                              style: FarmerDiscountsStyles.emptyDescription,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: onCreate,
                            style: FarmerDiscountsStyles.createFirstButton,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text(
                              'Create First Promotion',
                              style: FarmerDiscountsStyles.boldButtonText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: FarmerDiscountsStyles.listPadding,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final discount = controller.discounts[index];
                        return Padding(
                          padding: FarmerDiscountsStyles.listItemPadding,
                          child: FarmerPromotionCard(
                            discount: discount,
                            onToggle: (value) => onToggle(discount, value),
                            onEdit: () => onEdit(discount),
                            onDelete: () => onDelete(discount),
                          ),
                        );
                      }, childCount: controller.discounts.length),
                    ),
                  ),
              ],
            ),
          );
  }
}
