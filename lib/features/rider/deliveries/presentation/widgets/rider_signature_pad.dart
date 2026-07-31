import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:flutter/rendering.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import '../../data/delivery_proof_storage.dart';
import '../../domain/delivery_completion.dart';

Future<String?> showRiderSignaturePad(
  BuildContext context, {
  required String deliveryId,
  required DeliveryProofStorage storage,
}) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (_) =>
      _RiderSignatureDialog(deliveryId: deliveryId, storage: storage),
);

class _RiderSignatureDialog extends StatefulWidget {
  const _RiderSignatureDialog({
    required this.deliveryId,
    required this.storage,
  });

  final String deliveryId;
  final DeliveryProofStorage storage;

  @override
  State<_RiderSignatureDialog> createState() => _RiderSignatureDialogState();
}

class _RiderSignatureDialogState extends State<_RiderSignatureDialog> {
  final _boundaryKey = GlobalKey();
  final _points = <Offset?>[];
  bool _saving = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Buyer signature'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ask the recipient to sign inside the box.'),
        const SizedBox(height: 10),
        RepaintBoundary(
          key: _boundaryKey,
          child: ColoredBox(
            color: AgrisellColors.surface,
            child: GestureDetector(
              onPanStart: (details) => _add(details.localPosition),
              onPanUpdate: (details) => _add(details.localPosition),
              onPanEnd: (_) => _add(null),
              child: CustomPaint(
                painter: _SignaturePainter(_points),
                size: const Size(280, 160),
              ),
            ),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => setState(_points.clear),
        child: const Text('Clear'),
      ),
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving || _points.whereType<Offset>().length < 3
            ? null
            : _save,
        child: Text(_saving ? 'Saving...' : 'Save signature'),
      ),
    ],
  );

  void _add(Offset? point) => setState(() => _points.add(point));

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final boundary =
          _boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw const DeliveryProofStorageException('');
      final reference = await widget.storage.saveBytes(
        deliveryId: widget.deliveryId,
        method: DeliveryConfirmationMethod.buyerSignature,
        bytes: data.buffer.asUint8List(),
        extension: 'png',
      );
      if (mounted) Navigator.of(context).pop(reference);
    } on Exception {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('The signature could not be saved.')),
      );
    }
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AgrisellColors.brandBlack
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;
    for (var index = 0; index < points.length - 1; index++) {
      final first = points[index];
      final second = points[index + 1];
      if (first != null && second != null) {
        canvas.drawLine(first, second, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
