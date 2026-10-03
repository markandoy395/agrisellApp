import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';

import '../controllers/farmer_cash_out_form_controller.dart';
import '../styles/cash_out_dialog_styles.dart';
import 'cash_out_dialog_form.dart';

class FarmerCashOutDialog extends StatefulWidget {
  const FarmerCashOutDialog({
    required this.onSubmit,
    this.initialAmount,
    super.key,
  });

  final Future<FarmerCashOutRequest> Function(FarmerCashOutRequest request)
  onSubmit;
  final double? initialAmount;

  static Future<FarmerCashOutRequest?> show(
    BuildContext context, {
    required Future<FarmerCashOutRequest> Function(FarmerCashOutRequest request)
    onSubmit,
    double? initialAmount,
  }) {
    return showModalBottomSheet<FarmerCashOutRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CashOutDialogStyles.transparent,
      builder: (_) =>
          FarmerCashOutDialog(onSubmit: onSubmit, initialAmount: initialAmount),
    );
  }

  @override
  State<FarmerCashOutDialog> createState() => _FarmerCashOutDialogState();
}

class _FarmerCashOutDialogState extends State<FarmerCashOutDialog> {
  late final FarmerCashOutFormController _form;

  @override
  void initState() {
    super.initState();
    _form = FarmerCashOutFormController(initialAmount: widget.initialAmount);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await _form.submit(widget.onSubmit);
    if (mounted && result != null) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _form,
    builder: (context, _) => CashOutDialogForm(form: _form, onSubmit: _submit),
  );
}
