import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_add_product_button_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_dashboard_header_styles.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_dashboard_tabs_styles.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_product_card_styles.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_product_details_content_styles.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid_skeleton.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_categories_card.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_dashboard_styles.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_product_details_styles.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_product_coordinator.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_quick_menu.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_sold_status_overlay.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/widgets/farmer_information_request_banner.dart';

part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_header.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_add_product_button.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_tabs.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_product_card.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_product_actions.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_product_details.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_empty_state.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_tab_content.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_body.dart';
part 'farmer_dashboard_verification.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({
    this.pickProductImageBytes,
    this.commodityRepository = const FarmerCommodityRepository(),
    this.verificationRepository = const FarmerVerificationRepository(),
    this.onNavigate,
    super.key,
  });

  final ProductImagePicker? pickProductImageBytes;
  final FarmerCommodityRepository commodityRepository;
  final FarmerVerificationRepository verificationRepository;
  final ValueChanged<FarmerQuickDestination>? onNavigate;

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  final _products = <FarmerDashboardProduct>[];
  final _searchController = TextEditingController();
  var _activeTab = _FarmerDashboardTab.products;
  var _selectedCategory = 'All';
  var _searchQuery = '';
  var _isLoadingProducts = false;
  final _restockingProductIds = <int>{};
  FarmerVerificationDetails? _verificationDetails;
  Timer? _verificationTimer;
  RealtimeChannel? _verificationChannel;
  int _verificationGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _watchVerification();
  }

  @override
  void dispose() {
    _disposeVerificationUpdates();
    _searchController.dispose();
    super.dispose();
  }

  List<FarmerDashboardProduct> get _visibleProducts =>
      FarmerProductCoordinator.filterProducts(
        products: _products,
        category: _selectedCategory,
        query: _searchQuery,
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FarmerDashboardStyles.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _FarmerDashboardHeader(
              horizontalPadding: FarmerDashboardStyles.horizontalPadding(
                MediaQuery.sizeOf(context).width,
              ),
              searchController: _searchController,
              onSearchChanged: (value) => setState(() {
                _searchQuery = value;
                _activeTab = _FarmerDashboardTab.products;
              }),
              onMenuTap: _openQuickMenu,
            ),
            Expanded(child: _FarmerDashboardBody(state: this)),
          ],
        ),
      ),
    );
  }

  void _selectTab(_FarmerDashboardTab tab) => setState(() => _activeTab = tab);

  void _selectCategory(String category) => setState(() {
    _selectedCategory = category;
    _activeTab = _FarmerDashboardTab.products;
  });

  Future<void> _openQuickMenu() async {
    final dest = await showFarmerQuickMenu(
      context,
      current: FarmerQuickDestination.products,
    );
    if (dest != null && mounted) widget.onNavigate?.call(dest);
  }

  Future<void> _openAddProductScreen() =>
      FarmerProductCoordinator.handleAddProduct(
        context: context,
        repository: widget.commodityRepository,
        pickProductImageBytes: widget.pickProductImageBytes,
        canPostProducts: _canPostProducts,
        onMessage: _showMessage,
        onSaved: (saved) => setState(() {
          _activeTab = _FarmerDashboardTab.products;
          _products.add(saved);
        }),
      );

  Future<void> _openEditProduct(int index) =>
      FarmerProductCoordinator.handleEditProductByIndex(
        context: context,
        repository: widget.commodityRepository,
        products: _products,
        index: index,
        pickProductImageBytes: widget.pickProductImageBytes,
        onMessage: _showMessage,
        onUpdated: () => setState(() {}),
      );

  Future<void> _openRestockProduct(int index) =>
      FarmerProductCoordinator.handleRestockProductByIndex(
        context: context,
        repository: widget.commodityRepository,
        products: _products,
        index: index,
        restockingProductIds: _restockingProductIds,
        onRestockStateChanged: (id, isRestocking) => setState(
          () => isRestocking
              ? _restockingProductIds.add(id)
              : _restockingProductIds.remove(id),
        ),
        onMessage: _showMessage,
        onUpdated: () => setState(() {}),
      );

  Future<void> _loadProducts() async {
    if (!widget.commodityRepository.isAvailable) return;
    setState(() => _isLoadingProducts = true);
    final products = await FarmerProductCoordinator.loadProducts(
      repository: widget.commodityRepository,
      onMessage: _showMessage,
    );
    if (mounted) {
      setState(() {
        _products.addAll(products);
        _isLoadingProducts = false;
      });
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showAppSnackBar(SnackBar(content: Text(message)));

  void _refresh(VoidCallback update) => setState(update);
}
