import 'package:agresell_app/features/farmer/products/presentation/styles/add_product_availability_fields_styles.dart';
import 'package:agresell_app/features/farmer/products/presentation/styles/add_product_form_fields_styles.dart';
import 'package:agresell_app/features/farmer/products/presentation/styles/add_product_form_panel_styles.dart';
import 'package:agresell_app/features/farmer/products/presentation/styles/add_product_inventory_lot_fields_styles.dart';
import 'package:agresell_app/features/farmer/products/presentation/styles/add_product_media_widgets_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'dart:typed_data';
import '../../data/farmer_product_publisher.dart';
import '../controllers/product_publish_callback.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/product_description_samples.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/add_product_draft.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_form_message.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_options.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_media_widgets.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_form_panel.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_form_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_details_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_pricing_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_availability_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_inventory_lot_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/controllers/add_product_screen_actions.dart';
part 'package:agresell_app/features/farmer/products/presentation/controllers/add_product_date_actions.dart';
part 'package:agresell_app/features/farmer/products/presentation/controllers/add_product_publish_action.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_content.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    this.pickProductImageBytes,
    this.initialPhotoBytes,
    this.onPublish,
    super.key,
  });
  final ProductImagePicker? pickProductImageBytes;
  final Uint8List? initialPhotoBytes;
  final ProductPublishCallback? onPublish;
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _lotCodeController = TextEditingController();
  final _storageInstructionsController = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _photoBytes;
  bool _isPublishing = false;
  final String _publishRequestKey = FarmerProductPublisher.newRequestKey();
  DateTime? _expectedDate;
  DateTime? _lotHarvestedAt;
  DateTime? _marketableUntil;
  ProductInventoryDateType _inventoryDateType =
      ProductInventoryDateType.freshProduce;
  String? _category;
  String _unitType = _unitTypes.first;
  ProductProductionStage _productionStage = ProductProductionStage.harvested;
  ProductSaleStatus _saleStatus = ProductSaleStatus.readyNow;
  String? _gradeQuality;
  var _isOrganic = false;
  var _sampleDescriptionSeed = 0;
  Map<AddProductField, String> _errors = {};
  @override
  void initState() {
    super.initState();
    _photoBytes = widget.initialPhotoBytes;
    _lotHarvestedAt = ProductAvailabilityDateRules.philippineToday();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _minimumOrderController.dispose();
    _lotCodeController.dispose();
    _storageInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_isPublishing,
    child: AbsorbPointer(
      absorbing: _isPublishing,
      child: _buildContent(context),
    ),
  );

  void _refresh(VoidCallback change) => setState(change);
}
