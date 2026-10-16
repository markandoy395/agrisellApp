import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
import 'dart:async';
import '../widgets/rider_earning_guide.dart';
import '../widgets/rider_wallet_card.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/utils/rider_earnings_actions_handler.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_content_view.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_header_actions.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_period_chips.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderEarningsScreen extends StatefulWidget {
  const RiderEarningsScreen({this.riderId = '', this.controller, super.key});
  final String riderId;
  final RiderAnalyticsController? controller;
  @override
  State<RiderEarningsScreen> createState() => _RiderEarningsScreenState();
}

class _RiderEarningsScreenState extends State<RiderEarningsScreen> {
  late final RiderAnalyticsController _controller;
  late final bool _ownsController;
  var _period = RiderAnalyticsPeriod.today;
  RiderDateRange? _customRange;
  RiderDateRange get _dateRange =>
      _customRange ?? RiderDateRange.forPeriod(_period, DateTime.now());

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RiderAnalyticsController();
    unawaited(_load());
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RiderSafeScaffold(
    backgroundColor: RiderEarningsStyles.backgroundColor,
    body: Column(
      children: [
        RiderPageHeader(
          title: 'Earnings',
          subtitle: formatRiderDateRange(_dateRange),
          action: RiderEarningsHeaderActions(
            onExportCsv: () => RiderEarningsActionsHandler.exportCsv(
              context: context,
              controller: _controller,
              dateRange: _dateRange,
            ),
            onOpenWithdrawalMethods: () =>
                RiderEarningsActionsHandler.openWithdrawalMethods(
                  context: context,
                  riderId: widget.riderId,
                  controller: _controller,
                ),
            onOpenRatings: () => RiderEarningsActionsHandler.openRatings(
              context: context,
              riderId: widget.riderId,
              controller: _controller,
            ),
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => ListView(
              padding: RiderEarningsStyles.listPadding,
              children: [
                const RiderEarningGuide(),
                RiderEarningsStyles.cardSpacing,
                RiderWalletCard(
                  controller: _controller,
                  onRetry: () => unawaited(_load()),
                ),
                RiderEarningsStyles.cardSpacing,
                RiderEarningsPeriodChips(
                  selectedPeriod: _period,
                  onSelected: _selectPeriod,
                ),
                RiderEarningsStyles.sectionSpacing,
                RiderEarningsContentView(
                  controller: _controller,
                  onRetry: () => unawaited(_load()),
                  onCashOut: () => RiderEarningsActionsHandler.openCashOut(
                    context: context,
                    riderId: widget.riderId,
                    controller: _controller,
                    onReload: _load,
                    isMounted: () => mounted,
                  ),
                  onManageMethods: () =>
                      RiderEarningsActionsHandler.openWithdrawalMethods(
                        context: context,
                        riderId: widget.riderId,
                        controller: _controller,
                      ),
                  onOpenDelivery: (id) =>
                      RiderEarningsActionsHandler.openDelivery(
                        context: context,
                        riderId: widget.riderId,
                        controller: _controller,
                        deliveryId: id,
                        isMounted: () => mounted,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _selectPeriod(RiderAnalyticsPeriod period) async {
    if (period == RiderAnalyticsPeriod.custom) {
      final today = DateTime.now();
      final selected = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(today.year, today.month, today.day),
        initialDateRange: DateTimeRange(
          start: _dateRange.start,
          end: _dateRange.end,
        ),
      );
      if (selected == null || !mounted) return;
      setState(() {
        _period = period;
        _customRange = RiderDateRange.fromDates(selected.start, selected.end);
      });
    } else {
      setState(() {
        _period = period;
        _customRange = null;
      });
    }
    await _load();
  }

  Future<void> _load() async {
    await Future.wait([
      _controller.loadEarnings(riderId: widget.riderId, dateRange: _dateRange),
      _controller.loadWallet(riderId: widget.riderId),
    ]);
  }
}
