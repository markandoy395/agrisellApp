import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';

abstract final class OrderDisputeStyles {
  static const sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );
  static EdgeInsets sheetPadding(double bottomInset) =>
      EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset);
  static final handleDecoration = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(2),
  );
  static const title = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static const caption = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );
  static const fieldLabel = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  static const dropdownText = TextStyle(fontSize: 13);
  static const detailLabel = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const detailValue = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const explanation = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    height: 1.4,
  );
  static const resolutionLabel = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const detailsPadding = EdgeInsets.all(14);
  static final detailsDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AgrisellColors.borderLine),
  );
  static final _focusedInputBorder = _inputBorder.copyWith(
    borderSide: const BorderSide(color: AgrisellColors.authGreen, width: 1.5),
  );
  static final dropdownDecoration = InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: _focusedInputBorder,
  );
  static final reasonDecoration = InputDecoration(
    hintText:
        'Describe the damage, rotten batch portion, or missing items in detail...',
    hintStyle: const TextStyle(color: AgrisellColors.mutedText, fontSize: 13),
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: _focusedInputBorder,
  );
  static final submitButton = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  );
  static final closeButton = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.brandBlack,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
  static const submitText = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );
  static const closeText = TextStyle(fontWeight: FontWeight.w600, fontSize: 14);

  static Color statusColor(OrderDisputeStatus status) => switch (status) {
    OrderDisputeStatus.pending => AgrisellColors.statusOrangeText,
    OrderDisputeStatus.resolved => AgrisellColors.authGreen,
    OrderDisputeStatus.rejected => AgrisellColors.statusRedText,
  };
  static Color _statusBackground(OrderDisputeStatus status) => switch (status) {
    OrderDisputeStatus.pending => AgrisellColors.statusOrangeBackground,
    OrderDisputeStatus.resolved => AgrisellColors.limeSoft,
    OrderDisputeStatus.rejected => AgrisellColors.statusRedBackground,
  };
  static IconData statusIcon(OrderDisputeStatus status) => switch (status) {
    OrderDisputeStatus.pending => Icons.hourglass_top_rounded,
    OrderDisputeStatus.resolved => Icons.check_circle_outline_rounded,
    OrderDisputeStatus.rejected => Icons.cancel_outlined,
  };
  static final _iconDecorations = {
    for (final status in OrderDisputeStatus.values)
      status: BoxDecoration(
        color: _statusBackground(status),
        shape: BoxShape.circle,
      ),
  };
  static final _badgeDecorations = {
    for (final status in OrderDisputeStatus.values)
      status: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(999),
      ),
  };
  static final _badgeTextStyles = {
    for (final status in OrderDisputeStatus.values)
      status: TextStyle(
        color: statusColor(status),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
  };
  static const badgePadding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
  static BoxDecoration iconDecoration(OrderDisputeStatus status) =>
      _iconDecorations[status]!;
  static BoxDecoration badgeDecoration(OrderDisputeStatus status) =>
      _badgeDecorations[status]!;
  static TextStyle badgeText(OrderDisputeStatus status) =>
      _badgeTextStyles[status]!;
}
