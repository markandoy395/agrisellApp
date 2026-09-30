import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';

class RiderCashOutDialog extends StatefulWidget {
  const RiderCashOutDialog({
    required this.riderId,
    required this.controller,
    required this.availableEarnings,
    super.key,
  });

  final String riderId;
  final RiderAnalyticsController controller;
  final double availableEarnings;

  @override
  State<RiderCashOutDialog> createState() => _RiderCashOutDialogState();
}

class _RiderCashOutDialogState extends State<RiderCashOutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _notesController = TextEditingController();

  RiderWithdrawalMethod? _selectedMethod;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _initMethods();
  }

  void _initMethods() {
    final methods = widget.controller.withdrawalMethods;
    if (methods.isNotEmpty) {
      _selectedMethod =
          methods.firstWhere((m) => m.isDefault, orElse: () => methods.first);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) {
      setState(() => _errorMessage = 'Please select a withdrawal method.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final request = RiderWithdrawalRequest(
      requestId: '',
      amount: amount,
      payoutMethod: _selectedMethod!.payoutMethod,
      accountName: _selectedMethod!.accountName,
      accountNumber: _selectedMethod!.accountNumber,
      bankName: _selectedMethod!.bankName,
      notes: _notesController.text.trim(),
    );

    try {
      final result = await widget.controller.submitWithdrawalRequest(
        riderId: widget.riderId,
        request: request,
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Cash-out failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AgrisellColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AgrisellColors.statusGreenBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AgrisellColors.authGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cash Out Earnings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AgrisellColors.headingGreen,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Submit a withdrawal request to transfer earnings to your account.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AgrisellColors.mutedText,
                  ),
                ),
                const SizedBox(height: 16),
                // Available Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AgrisellColors.statusGreenBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available to Withdraw',
                              style: TextStyle(
                                fontSize: 12,
                                color: AgrisellColors.brandBlack,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Net unwithdrawn earnings',
                              style: TextStyle(
                                fontSize: 12,
                                color: AgrisellColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatRiderCurrency(widget.availableEarnings),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AgrisellColors.authGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                // Withdrawal Destination
                const Text(
                  'Withdrawal Destination',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgrisellColors.brandBlack,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.controller.withdrawalMethods.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AgrisellColors.searchBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: AgrisellColors.statusOrangeText),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No withdrawal method configured. Please add one first.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  DropdownButtonFormField<RiderWithdrawalMethod>(
                    isExpanded: true,
                    initialValue: _selectedMethod,
                    items: [
                      for (final m in widget.controller.withdrawalMethods)
                        DropdownMenuItem(
                          value: m,
                          child: Text(
                            '${m.methodLabel} (${m.accountNumber}) - ${m.accountName}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (val) => setState(() => _selectedMethod = val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AgrisellColors.searchBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Withdrawal Amount (₱)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgrisellColors.brandBlack,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter amount (e.g. 500)',
                    prefixText: '₱ ',
                    prefixStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AgrisellColors.headingGreen,
                    ),
                    filled: true,
                    fillColor: AgrisellColors.searchBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid amount greater than 0';
                    }
                    if (widget.availableEarnings > 0 &&
                        parsed > widget.availableEarnings) {
                      return 'Amount exceeds available earnings (${formatRiderCurrency(widget.availableEarnings)})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Quick Amount Chips
                Wrap(
                  spacing: 8,
                  children: [
                    if (widget.availableEarnings >= 200)
                      ActionChip(
                        label: const Text('₱200'),
                        onPressed: () => _setAmount(200),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    if (widget.availableEarnings >= 500)
                      ActionChip(
                        label: const Text('₱500'),
                        onPressed: () => _setAmount(500),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    if (widget.availableEarnings >= 1000)
                      ActionChip(
                        label: const Text('₱1,000'),
                        onPressed: () => _setAmount(1000),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    if (widget.availableEarnings > 0)
                      ActionChip(
                        label: const Text('All'),
                        onPressed: () => _setAmount(widget.availableEarnings),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AgrisellColors.authGreen,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Notes (Optional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgrisellColors.brandBlack,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Add any notes for payout processing',
                    filled: true,
                    fillColor: AgrisellColors.searchBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(
                            color: AgrisellColors.borderLine,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AgrisellColors.brandBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AgrisellColors.authGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                                'Submit Cash Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
