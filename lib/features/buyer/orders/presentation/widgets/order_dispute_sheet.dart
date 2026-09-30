import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

Future<void> showOrderDisputeSheet(
  BuildContext context, {
  required PlacedOrder order,
  required Future<void> Function({
    required String orderId,
    required OrderDisputeCategory category,
    required String reason,
    required OrderDisputeResolution requestedResolution,
  }) onSubmitDispute,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderDisputeSheet(
        order: order,
        onSubmitDispute: onSubmitDispute,
      ),
    );

class _OrderDisputeSheet extends StatefulWidget {
  const _OrderDisputeSheet({
    required this.order,
    required this.onSubmitDispute,
  });

  final PlacedOrder order;
  final Future<void> Function({
    required String orderId,
    required OrderDisputeCategory category,
    required String reason,
    required OrderDisputeResolution requestedResolution,
  }) onSubmitDispute;

  @override
  State<_OrderDisputeSheet> createState() => _OrderDisputeSheetState();
}

class _OrderDisputeSheetState extends State<_OrderDisputeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  var _selectedCategory = OrderDisputeCategory.damagedRottenProduce;
  var _selectedResolution = OrderDisputeResolution.fullRefund;
  var _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Pending';
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year · $hour:$minute $period';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmitDispute(
        orderId: widget.order.id,
        category: _selectedCategory,
        reason: _reasonController.text.trim(),
        requestedResolution: _selectedResolution,
      );

      if (mounted) {
        Navigator.of(context).pop();
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showAppSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Dispute submitted for administrator review.'),
          ),
        );
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final detail = error.toString().replaceFirst('Exception: ', '').trim();
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showAppSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(detail.isEmpty ? 'Failed to submit dispute.' : detail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dispute = widget.order.dispute;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AgrisellColors.borderLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (dispute != null)
                _buildActiveDisputeView(context, dispute)
              else
                _buildDisputeForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDisputeView(BuildContext context, OrderDispute dispute) {
    final (statusColor, statusBg, statusIcon) = switch (dispute.status) {
      OrderDisputeStatus.pending => (
        AgrisellColors.statusOrangeText,
        AgrisellColors.statusOrangeBackground,
        Icons.hourglass_top_rounded,
      ),
      OrderDisputeStatus.resolved => (
        AgrisellColors.authGreen,
        AgrisellColors.limeSoft,
        Icons.check_circle_outline_rounded,
      ),
      OrderDisputeStatus.rejected => (
        AgrisellColors.statusRedText,
        AgrisellColors.statusRedBackground,
        Icons.cancel_outlined,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: statusBg,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Goods Dispute',
                    style: TextStyle(
                      color: AgrisellColors.brandBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Order ${widget.order.id}',
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                dispute.status.label,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AgrisellColors.searchBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AgrisellColors.borderLine),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Claim Category', dispute.category.label),
              const SizedBox(height: 10),
              _detailRow('Desired Resolution', dispute.requestedResolution.label),
              const SizedBox(height: 10),
              _detailRow('Reported At', _formatDateTime(dispute.submittedAt)),
              const Divider(height: 20, color: AgrisellColors.borderLine),
              const Text(
                'Buyer Explanation',
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dispute.reason,
                style: const TextStyle(
                  color: AgrisellColors.brandBlack,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              if (dispute.resolutionNote != null &&
                  dispute.resolutionNote!.trim().isNotEmpty) ...[
                const Divider(height: 20, color: AgrisellColors.borderLine),
                const Text(
                  'Administrator Resolution',
                  style: TextStyle(
                    color: AgrisellColors.authGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dispute.resolutionNote!,
                  style: const TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (dispute.resolvedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Resolved on ${_formatDateTime(dispute.resolvedAt)}',
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AgrisellColors.brandBlack,
              side: const BorderSide(color: AgrisellColors.borderLine),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisputeForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AgrisellColors.statusOrangeBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.report_problem_outlined,
                  color: AgrisellColors.statusOrangeText,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Produce Issue',
                      style: TextStyle(
                        color: AgrisellColors.brandBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Order ${widget.order.id} · ${widget.order.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'What is the issue with your delivered produce?',
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<OrderDisputeCategory>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AgrisellColors.authGreen,
                  width: 1.5,
                ),
              ),
            ),
            items: OrderDisputeCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category.label,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Requested Resolution',
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<OrderDisputeResolution>(
            initialValue: _selectedResolution,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AgrisellColors.authGreen,
                  width: 1.5,
                ),
              ),
            ),
            items: OrderDisputeResolution.values.map((resolution) {
              return DropdownMenuItem(
                value: resolution,
                child: Text(
                  resolution.label,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedResolution = value);
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Details & Evidence Description',
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reasonController,
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return 'Please describe the condition of the delivered produce.';
              }
              if (text.length < 10) {
                return 'Please provide more details (at least 10 characters).';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText:
                  'Describe the damage, rotten batch portion, or missing items in detail...',
              hintStyle: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AgrisellColors.authGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AgrisellColors.authGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Dispute Claim',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
