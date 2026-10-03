import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';
import 'package:agresell_app/features/farmer/profile/presentation/controllers/farmer_farm_form_controllers.dart';
import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_farm_edit_styles.dart';
import 'package:agresell_app/features/farmer/profile/presentation/utils/farmer_farm_location_coordinator.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_actions.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_form_fields.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_header.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_style.dart';
import 'package:agresell_app/features/farmer/registration/domain/farm_model.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

class FarmerFarmEditCard extends StatefulWidget {
  const FarmerFarmEditCard({
    required this.onCancel,
    this.service,
    this.gpsGateway,
    super.key,
  });

  final VoidCallback onCancel;
  final FarmerFarmService? service;
  final GpsLocationGateway? gpsGateway;

  @override
  State<FarmerFarmEditCard> createState() => _FarmerFarmEditCardState();
}

class _FarmerFarmEditCardState extends State<FarmerFarmEditCard>
    with WidgetsBindingObserver {
  late final FarmerFarmService _service;
  late final GpsLocationGateway _gpsGateway;
  final _controllers = FarmerFarmFormControllers();
  FarmModel? _farm;
  var _loading = true;
  var _saving = false;
  var _capturing = false;
  String? _locationError;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? const FarmerFarmService();
    _gpsGateway = widget.gpsGateway ?? GeolocatorGpsLocationGateway();
    WidgetsBinding.instance.addObserver(this);
    _load();
    unawaited(_startGpsCapture());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controllers.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_capturing &&
        (_latitude == null || _longitude == null)) {
      unawaited(_startGpsCapture(openSettings: false));
    }
  }

  Future<void> _load() async {
    try {
      final farm = await _service.load();
      if (!mounted) return;
      _farm = farm;
      _controllers.populate(farm);
    } on FarmerFarmException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startGpsCapture({bool openSettings = true}) async {
    if (_capturing) return;
    setState(() {
      _capturing = true;
      _locationError = null;
    });
    try {
      final coords = await FarmerFarmLocationCoordinator.captureCoordinates(
        gpsGateway: _gpsGateway,
        openSettings: openSettings,
      );
      _latitude = coords.latitude;
      _longitude = coords.longitude;
    } on FarmerFarmException catch (error) {
      if (mounted) setState(() => _locationError = error.message);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _save() async {
    if (_saving || _capturing) return;
    final validationError = _controllers.validate();
    if (validationError != null) {
      _message(validationError);
      return;
    }

    setState(() => _saving = true);
    try {
      if (_latitude == null || _longitude == null) {
        await _startGpsCapture();
        if (_latitude == null || _longitude == null) return;
      }
      if (!mounted) return;
      final draft = _controllers.buildDraft(
        latitude: _latitude,
        longitude: _longitude,
      );
      final farm = await _service.save(draft, farmId: _farm?.id);
      if (!mounted) return;
      setState(() => _farm = farm);
      _message('Farm details saved.');
      widget.onCancel();
    } on FarmerFarmException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return FarmerProfileCard(
      child: Padding(
        padding: FarmerFarmEditStyles.cardPadding,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmerFarmEditHeader(
                    isCapturing: _capturing,
                    locationError: _locationError,
                    onRetryGps: _startGpsCapture,
                  ),
                  FarmerFarmEditFormFields(
                    controllers: _controllers,
                    onAddressChanged: () => setState(() {}),
                  ),
                  FarmerFarmEditActions(
                    isSaving: _saving,
                    isCapturing: _capturing,
                    onCancel: widget.onCancel,
                    onSave: _save,
                  ),
                ],
              ),
      ),
    );
  }
}
