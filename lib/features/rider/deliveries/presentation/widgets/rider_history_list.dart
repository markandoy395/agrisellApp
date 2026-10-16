import 'package:flutter/material.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import '../../../dashboard/domain/rider_history_models.dart';
import '../../../dashboard/presentation/screens/rider_history_details_screen.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_stage.dart';
import '../controllers/rider_delivery_controller.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_delivery_history_row.dart';

class RiderHistoryList extends StatefulWidget {
  const RiderHistoryList({required this.controller, super.key});
  final RiderDeliveryController controller;

  @override
  State<RiderHistoryList> createState() => _RiderHistoryListState();
}

class _RiderHistoryListState extends State<RiderHistoryList> {
  String _search = '';
  RiderHistoryStatus? _status;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final completedIds = {
      for (final record in controller.completionHistory) record.request.id,
    };
    final history =
        <RiderDeliveryHistoryEntry>[
              for (final record in controller.completionHistory)
                RiderDeliveryHistoryEntry.fromCompletion(record),
              for (final request in controller.requests)
                if (request.stage.isTerminal &&
                    !completedIds.contains(request.id))
                  _fromClosedRequest(request),
            ]
            .where(
              (entry) =>
                  entry.matchesSearch(_search) &&
                  (_status == null || entry.status == _status),
            )
            .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final images = {
      for (final request in controller.requests)
        request.id: request.productImageUrl,
      for (final record in controller.completionHistory)
        record.request.id: record.request.productImageUrl,
    };
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _search = value),
                  style: RiderDeliveriesDesignStyles.body,
                  decoration: RiderDeliveriesDesignStyles.input(
                    'Search delivery history...',
                    prefix: const Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Filter history',
                initialValue: _status?.name ?? 'all',
                onSelected: (value) => setState(
                  () => _status = value == 'all'
                      ? null
                      : RiderHistoryStatus.values.byName(value),
                ),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('All deliveries'),
                  ),
                  for (final status in RiderHistoryStatus.values)
                    PopupMenuItem(
                      value: status.name,
                      child: Text(status.label),
                    ),
                ],
                child: Badge(
                  isLabelVisible: _status != null,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.filter_list),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('rider-history-list'),
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            itemCount: history.length + 1,
            itemBuilder: (context, index) {
              if (index == history.length) {
                return RiderDeliveryHistoryFooter(
                  empty: history.isEmpty,
                  filtered: _search.isNotEmpty || _status != null,
                );
              }
              final entry = history[index];
              final day = DateUtils.dateOnly(entry.completedAt.toLocal());
              final startsDay =
                  index == 0 ||
                  day !=
                      DateUtils.dateOnly(
                        history[index - 1].completedAt.toLocal(),
                      );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (startsDay)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _dayLabel(context, day),
                          style: RiderDeliveriesDesignStyles.caption,
                        ),
                      ),
                    RiderDeliveryHistoryRow(
                      key: ValueKey(entry.id),
                      entry: entry,
                      imageUrl: images[entry.id],
                      onTap: () => Navigator.of(context).push(
                        agrisellPageRoute<void>(
                          builder: (_) =>
                              RiderHistoryDetailsScreen(entry: entry),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _dayLabel(BuildContext context, DateTime day) {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final prefix = day == today
        ? 'Today - '
        : day == yesterday
        ? 'Yesterday - '
        : '';
    return '$prefix${MaterialLocalizations.of(context).formatMediumDate(day)}';
  }

  RiderDeliveryHistoryEntry _fromClosedRequest(DeliveryRequest request) =>
      RiderDeliveryHistoryEntry(
        id: request.id,
        orderNumber: request.orderNumber,
        completedAt:
            request.closedAt ?? request.outcome?.recordedAt ?? DateTime.now(),
        pickupAddress: request.pickupLocation.address,
        deliveryAddress: request.deliveryLocation.address,
        productName: request.productName,
        quantityDescription: request.quantityDescription,
        deliveryFee: request.deliveryFee,
        status: switch (request.stage) {
          DeliveryStage.completed => RiderHistoryStatus.completed,
          DeliveryStage.cancelled => RiderHistoryStatus.cancelled,
          _ => RiderHistoryStatus.failed,
        },
        sellerName: request.sellerName,
        buyerName: request.buyerName,
        proofTypes: [for (final proof in request.proofs) proof.type],
      );
}
