import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_restock.dart';
import '../controllers/farmer_restock_controller.dart';
import '../styles/farmer_restock_dialog_styles.dart';
import 'farmer_restock_form.dart';
import 'farmer_restock_header.dart';

Future<FarmerRestockRequest?> showFarmerRestockDialog(
  BuildContext context, {
  required FarmerDashboardProduct product,
}) => showModalBottomSheet<FarmerRestockRequest>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: FarmerRestockDialogStyles.dialogBackground,
  shape: FarmerRestockDialogStyles.sheetShape,
  clipBehavior: Clip.antiAlias,
  builder: (_) => FarmerRestockDialog(product: product),
);

class FarmerRestockDialog extends StatefulWidget {
  const FarmerRestockDialog({required this.product, super.key});

  final FarmerDashboardProduct product;

  @override
  State<FarmerRestockDialog> createState() => _FarmerRestockDialogState();
}

class _FarmerRestockDialogState extends State<FarmerRestockDialog> {
  late final FarmerRestockController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FarmerRestockController(product: widget.product);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final request = _controller.submit();
    if (request != null && mounted) Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .92,
          maxWidth: 640,
        ),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 38,
                  height: 5,
                  decoration: FarmerRestockDialogStyles.handleDecoration,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FarmerRestockHeader(productName: widget.product.name),
                      const SizedBox(height: 18),
                      FarmerRestockForm(
                        product: widget.product,
                        controller: _controller,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FarmerRestockDialogStyles.cancelButtonStyle,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        key: const Key('confirm-restock-button'),
                        onPressed: _handleSubmit,
                        style: FarmerRestockDialogStyles.restockButtonStyle,
                        child: const Text(
                          'Confirm restock',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
