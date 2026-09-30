import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';

class RiderWithdrawalMethodsSheet extends StatefulWidget {
  const RiderWithdrawalMethodsSheet({
    required this.riderId,
    required this.controller,
    super.key,
  });

  final String riderId;
  final RiderAnalyticsController controller;

  @override
  State<RiderWithdrawalMethodsSheet> createState() =>
      _RiderWithdrawalMethodsSheetState();
}

class _RiderWithdrawalMethodsSheetState
    extends State<RiderWithdrawalMethodsSheet> {
  bool _isAdding = false;
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  String _payoutMethod = 'gcash';
  bool _isDefault = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    widget.controller.loadWithdrawalMethods(riderId: widget.riderId);
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _saveMethod() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await widget.controller.saveWithdrawalMethod(
        riderId: widget.riderId,
        method: RiderWithdrawalMethod(
          methodId: '',
          payoutMethod: _payoutMethod,
          accountName: _accountNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          bankName: _payoutMethod == 'bank_transfer'
              ? _bankNameController.text.trim()
              : '',
          isDefault: _isDefault,
        ),
      );
      if (!mounted) return;
      setState(() {
        _isAdding = false;
        _isSaving = false;
        _accountNameController.clear();
        _accountNumberController.clear();
        _bankNameController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save withdrawal method: $e')),
      );
    }
  }

  Future<void> _deleteMethod(String methodId) async {
    try {
      await widget.controller.deleteWithdrawalMethod(
        riderId: widget.riderId,
        methodId: methodId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete method: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final methods = widget.controller.withdrawalMethods;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Withdrawal Methods',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AgrisellColors.headingGreen,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Text(
                    'Manage your GCash and bank accounts for earnings payouts.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AgrisellColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isAdding) ...[
                    if (methods.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AgrisellColors.searchBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No withdrawal methods saved yet.\nAdd GCash or a bank account to receive your payouts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AgrisellColors.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      for (final m in methods) ...[
                        _WithdrawalMethodTile(
                          method: m,
                          onDelete: () => _deleteMethod(m.methodId),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _isAdding = true),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Withdrawal Method'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AgrisellColors.authGreen,
                          side: const BorderSide(
                            color: AgrisellColors.authGreen,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Add Method Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Type',
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
                                child: _TypeButton(
                                  title: 'GCash',
                                  icon: Icons.phone_android_rounded,
                                  isSelected: _payoutMethod == 'gcash',
                                  onTap: () => setState(
                                      () => _payoutMethod = 'gcash'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TypeButton(
                                  title: 'Bank Account',
                                  icon: Icons.account_balance_rounded,
                                  isSelected: _payoutMethod == 'bank_transfer',
                                  onTap: () => setState(
                                      () => _payoutMethod = 'bank_transfer'),
                                ),
                              ),
                            ],
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
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Account name is required'
                                : null,
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
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return _payoutMethod == 'gcash'
                                    ? 'GCash mobile number is required'
                                    : 'Account number is required';
                              }
                              if (_payoutMethod == 'gcash') {
                                final clean = val.replaceAll(RegExp(r'\s+'), '');
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
                              validator: (val) =>
                                  _payoutMethod == 'bank_transfer' &&
                                          (val == null || val.trim().isEmpty)
                                      ? 'Bank name is required'
                                      : null,
                            ),
                          ],
                          const SizedBox(height: 14),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Set as default withdrawal method',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AgrisellColors.brandBlack,
                              ),
                            ),
                            value: _isDefault,
                            activeThumbColor: AgrisellColors.authGreen,
                            onChanged: (val) => setState(() => _isDefault = val),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () =>
                                          setState(() => _isAdding = false),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveMethod,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AgrisellColors.authGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Save Method',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WithdrawalMethodTile extends StatelessWidget {
  const _WithdrawalMethodTile({
    required this.method,
    required this.onDelete,
  });

  final RiderWithdrawalMethod method;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: method.isDefault
              ? AgrisellColors.authGreen
              : AgrisellColors.borderLine,
          width: method.isDefault ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: method.isDefault
                  ? AgrisellColors.statusGreenBackground
                  : AgrisellColors.searchBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              method.isGcash
                  ? Icons.phone_android_rounded
                  : Icons.account_balance_rounded,
              color: method.isDefault
                  ? AgrisellColors.authGreen
                  : AgrisellColors.mutedText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.methodLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AgrisellColors.brandBlack,
                      ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AgrisellColors.statusGreenBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: AgrisellColors.authGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${method.accountName} · ${method.accountNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgrisellColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.delete_outline_rounded,
                size: 20, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AgrisellColors.statusGreenBackground
              : AgrisellColors.searchBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? AgrisellColors.authGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AgrisellColors.authGreen
                  : AgrisellColors.mutedText,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AgrisellColors.authGreen
                    : AgrisellColors.brandBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
