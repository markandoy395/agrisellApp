import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_history_details_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_ratings_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_cash_out_dialog.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_withdrawal_methods_sheet.dart';
import 'package:agresell_app/features/rider/reporting/rider_financial_exporter.dart';
import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';

abstract final class RiderEarningsActionsHandler {
  static void exportCsv({
    required BuildContext context,
    required RiderAnalyticsController controller,
    required RiderDateRange dateRange,
  }) {
    final report = RiderFinancialExporter.buildEarningsReport(
      earnings: controller.earnings.entries,
      dateRange: dateRange,
      summary: controller.earnings.summary,
    );
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    ExportReportSheet.show(
      context,
      title: 'Rider Earnings Statement',
      fileName: 'rider_earnings_$dateStr.csv',
      headers: report.headers,
      rows: report.rows,
      totalAmountLabel: formatRiderCurrency(report.totalAmount),
      dateRangeLabel: report.dateRangeLabel,
    );
  }

  static void openRatings({
    required BuildContext context,
    required String riderId,
    required RiderAnalyticsController controller,
  }) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) =>
            RiderRatingsScreen(riderId: riderId, controller: controller),
      ),
    );
  }

  static void openWithdrawalMethods({
    required BuildContext context,
    required String riderId,
    required RiderAnalyticsController controller,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: RiderEarningsStyles.modalBackgroundColor,
      shape: RiderEarningsStyles.modalShape,
      builder: (_) =>
          RiderWithdrawalMethodsSheet(riderId: riderId, controller: controller),
    );
  }

  static Future<void> openCashOut({
    required BuildContext context,
    required String riderId,
    required RiderAnalyticsController controller,
    required Future<void> Function() onReload,
    required bool Function() isMounted,
  }) async {
    await controller.loadWallet(riderId: riderId);
    if (!isMounted()) return;
    final wallet = controller.wallet;
    if (wallet == null || wallet.available <= 0) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            controller.walletError ?? 'No earnings available for cash out.',
          ),
        ),
      );
      return;
    }
    await controller.loadWithdrawalMethods(riderId: riderId);
    if (!isMounted()) return;

    if (controller.withdrawalMethods.isEmpty) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text(
            'Please add a withdrawal method first before cashing out.',
          ),
        ),
      );
      openWithdrawalMethods(
        context: context,
        riderId: riderId,
        controller: controller,
      );
      return;
    }

    final result = await showDialog<RiderWithdrawalRequest>(
      context: context,
      builder: (_) => RiderCashOutDialog(
        riderId: riderId,
        controller: controller,
        availableEarnings: wallet.available,
      ),
    );

    if (result != null && isMounted()) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            'Cash-out request for ${formatRiderCurrency(result.amount)} submitted successfully.',
          ),
          backgroundColor: AgrisellColors.authGreen,
        ),
      );
      await onReload();
    }
  }

  static Future<void> openDelivery({
    required BuildContext context,
    required String riderId,
    required RiderAnalyticsController controller,
    required String deliveryId,
    required bool Function() isMounted,
  }) async {
    await controller.loadHistory(riderId: riderId);
    if (!isMounted()) return;
    final matches = controller.history.where((entry) => entry.id == deliveryId);
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Delivery history is unavailable.')),
      );
      return;
    }
    await Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderHistoryDetailsScreen(entry: matches.first),
      ),
    );
  }
}
