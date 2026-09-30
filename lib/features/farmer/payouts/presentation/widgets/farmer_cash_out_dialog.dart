import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';

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
      backgroundColor: Colors.transparent,
      builder: (_) => FarmerCashOutDialog(
        onSubmit: onSubmit,
        initialAmount: initialAmount,
      ),
    );
  }

  @override
  State<FarmerCashOutDialog> createState() => _FarmerCashOutDialogState();
}

class _FarmerCashOutDialogState extends State<FarmerCashOutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _notesController = TextEditingController();

  String _payoutMethod = 'gcash'; // 'gcash' or 'bank_transfer'
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final request = FarmerCashOutRequest(
      requestId: '',
      amount: amount,
      payoutMethod: _payoutMethod,
      accountName: _accountNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      bankName: _payoutMethod == 'bank_transfer'
          ? _bankNameController.text.trim()
          : '',
      notes: _notesController.text.trim(),
    );

    try {
      final result = await widget.onSubmit(request);
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Failed to submit cash-out request: $e';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AgrisellColors.borderLine,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AgrisellColors.statusGreenBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: AgrisellColors.authGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Request Cash Out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AgrisellColors.headingGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
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
                  'Submit a payout request to disburse your farm earnings.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AgrisellColors.mutedText,
                  ),
                ),
                const SizedBox(height: 18),
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
                const Text(
                  'Payout Method',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgrisellColors.brandBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MethodCard(
                        title: 'GCash',
                        subtitle: 'Instant e-wallet',
                        icon: Icons.phone_android_rounded,
                        isSelected: _payoutMethod == 'gcash',
                        onTap: () => setState(() => _payoutMethod = 'gcash'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MethodCard(
                        title: 'Bank Transfer',
                        subtitle: 'Direct to account',
                        icon: Icons.account_balance_rounded,
                        isSelected: _payoutMethod == 'bank_transfer',
                        onTap: () =>
                            setState(() => _payoutMethod = 'bank_transfer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cash-Out Amount (₱)',
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
                    hintText: 'Enter amount (e.g. 1000)',
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
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Account Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgrisellColors.brandBlack,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Full name on account',
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
                      return 'Account name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  _payoutMethod == 'gcash'
                      ? 'GCash Mobile Number'
                      : 'Bank Account Number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AgrisellColors.brandBlack,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: _payoutMethod == 'gcash'
                        ? '09XXXXXXXXX'
                        : 'Account number',
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
                      return _payoutMethod == 'gcash'
                          ? 'GCash mobile number is required'
                          : 'Account number is required';
                    }
                    if (_payoutMethod == 'gcash') {
                      final clean = value.replaceAll(RegExp(r'\s+'), '');
                      if (!RegExp(r'^09\d{9}$').hasMatch(clean)) {
                        return 'Enter a valid 11-digit GCash number (09XXXXXXXXX)';
                      }
                    }
                    return null;
                  },
                ),
                if (_payoutMethod == 'bank_transfer') ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Bank Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgrisellColors.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _bankNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. BDO, BPI, Landbank, UnionBank',
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
                      if (_payoutMethod == 'bank_transfer' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Bank name is required for bank transfers';
                      }
                      return null;
                    },
                  ),
                ],
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
                    hintText: 'Add any notes for admin review',
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
                                'Submit Request',
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
    ),
  ),
),
);
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AgrisellColors.statusGreenBackground
              : AgrisellColors.searchBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AgrisellColors.authGreen
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AgrisellColors.authGreen
                      : AgrisellColors.mutedText,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AgrisellColors.authGreen,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AgrisellColors.authGreen
                    : AgrisellColors.brandBlack,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
