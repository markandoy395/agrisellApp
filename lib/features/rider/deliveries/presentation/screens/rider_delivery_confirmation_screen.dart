import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/data/delivery_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_confirmation_form.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_cash_collection_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_signature_pad.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

part 'rider_delivery_confirmation_actions.dart';

class RiderDeliveryConfirmationScreen extends StatefulWidget {
  const RiderDeliveryConfirmationScreen({
    required this.request,
    required this.riderId,
    required this.controller,
    this.proofStorage,
    super.key,
  });

  final DeliveryRequest request;
  final String riderId;
  final RiderDeliveryController controller;
  final DeliveryProofStorage? proofStorage;

  @override
  State<RiderDeliveryConfirmationScreen> createState() =>
      _RiderDeliveryConfirmationScreenState();
}

class _RiderDeliveryConfirmationScreenState
    extends State<RiderDeliveryConfirmationScreen> {
  late final DeliveryProofStorage _storage;
  late final String _idempotencyKey;
  final _code = TextEditingController();
  final _qr = TextEditingController();
  final _notes = TextEditingController();
  final _cashAmount = TextEditingController();
  final _cashNotes = TextEditingController();
  DeliveryCompletionConfiguration? _configuration;
  String? _error;
  String? _signatureReference;
  String? _photoReference;
  Uint8List? _photoPreviewBytes;
  DateTime? _photoCapturedAt;
  DeliveryStatusLocation? _photoLocation;
  bool _buyerConfirmed = false;
  bool _cashConfirmed = false;
  CashCollectionIssue? _cashIssue;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _storage = widget.proofStorage ?? DeliveryProofStorage();
    _idempotencyKey =
        '${widget.request.id}-${DateTime.now().microsecondsSinceEpoch}';
    _restoreRecovery();
    _notes.addListener(_saveRecovery);
    _cashAmount.addListener(_saveRecovery);
    _cashNotes.addListener(_saveRecovery);
    unawaited(_load());
  }

  @override
  void dispose() {
    _code.dispose();
    _qr.dispose();
    _notes.dispose();
    _cashAmount.dispose();
    _cashNotes.dispose();
    super.dispose();
  }

  String get _recoveryScope => 'deliveryConfirmation:${widget.request.id}';

  void _restoreRecovery() {
    final saved = widget.controller.recoveryDataFor(_recoveryScope);
    _notes.text = saved['deliveryNotes'] as String? ?? '';
    _buyerConfirmed = saved['buyerConfirmed'] as bool? ?? false;
    _signatureReference = saved['signatureReference'] as String?;
    _photoReference = saved['photoReference'] as String?;
    _photoCapturedAt = DateTime.tryParse(
      saved['photoCapturedAt'] as String? ?? '',
    )?.toLocal();
    final photoLatitude = saved['photoLatitude'] as num?;
    final photoLongitude = saved['photoLongitude'] as num?;
    final photoAccuracy = saved['photoAccuracyMeters'] as num?;
    if (photoLatitude != null &&
        photoLongitude != null &&
        photoAccuracy != null) {
      _photoLocation = DeliveryStatusLocation(
        latitude: photoLatitude.toDouble(),
        longitude: photoLongitude.toDouble(),
        accuracyMeters: photoAccuracy.toDouble(),
        timestamp: _photoCapturedAt,
      );
    }
    _cashAmount.text = saved['cashAmount'] as String? ?? '';
    _cashNotes.text = saved['cashNotes'] as String? ?? '';
    _cashConfirmed = saved['cashConfirmed'] as bool? ?? false;
    final issue = saved['cashIssue'] as String?;
    _cashIssue = issue == null
        ? null
        : CashCollectionIssue.values.byName(issue);
  }

  void _saveRecovery() => unawaited(
    widget.controller.saveRecoveryData(_recoveryScope, {
      'deliveryNotes': _notes.text,
      'buyerConfirmed': _buyerConfirmed,
      'signatureReference': _signatureReference,
      'photoReference': _photoReference,
      'photoCapturedAt': _photoCapturedAt?.toUtc().toIso8601String(),
      'photoLatitude': _photoLocation?.latitude,
      'photoLongitude': _photoLocation?.longitude,
      'photoAccuracyMeters': _photoLocation?.accuracyMeters,
      'cashAmount': _cashAmount.text,
      'cashNotes': _cashNotes.text,
      'cashConfirmed': _cashConfirmed,
      'cashIssue': _cashIssue?.name,
    }),
  );

  void _setBuyerConfirmed(bool value) {
    setState(() => _buyerConfirmed = value);
    _saveRecovery();
  }

  void _setCashConfirmed(bool value) {
    setState(() => _cashConfirmed = value);
    _saveRecovery();
  }

  void _setCashIssue(CashCollectionIssue? value) {
    setState(() => _cashIssue = value);
    _saveRecovery();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      // Keep the header and its surrounding Column at the full screen height.
      // The list accounts for the keyboard so focused cash fields remain
      // reachable without making the outer Column overflow on short screens.
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          RiderPageHeader(
            title: 'Confirm delivery',
            subtitle: 'Order ${widget.request.orderNumber}',
            action: IconButton(
              tooltip: 'Close',
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close_rounded,
                color: AgrisellColors.surface,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(14, 14, 14, keyboardInset + 28),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [_content()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    final configuration = _configuration;
    if (configuration == null && _error == null) {
      return const RiderLoadingStateCard(
        title: 'Loading proof requirements',
        message: 'Checking the delivery confirmation methods.',
      );
    }
    if (configuration == null) {
      return RiderErrorStateCard(
        title: 'Confirmation unavailable',
        message: _error!,
        retryLabel: 'Retry',
        onRetry: () => unawaited(_load()),
      );
    }
    return RiderDeliveryConfirmationForm(
      configuration: configuration,
      location: widget.controller.currentRiderLocation,
      codeController: _code,
      qrController: _qr,
      recipientName: widget.request.buyerName,
      notesController: _notes,
      buyerConfirmed: _buyerConfirmed,
      signatureCaptured: _signatureReference != null,
      photoCaptured: _photoReference != null,
      photoPreviewBytes: _photoPreviewBytes,
      photoCapturedAt: _photoCapturedAt,
      photoLocation: _photoLocation,
      isSubmitting: _submitting,
      onBuyerConfirmed: _setBuyerConfirmed,
      onCaptureSignature: _captureSignature,
      onCapturePhoto: _capturePhoto,
      onSubmit: _submit,
      cashCollectionSection: _cashCollectionSection,
    );
  }

  void _update(VoidCallback action) {
    if (mounted) setState(action);
  }
}
