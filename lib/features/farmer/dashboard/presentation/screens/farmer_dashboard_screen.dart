import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/agrisellPageRoute.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_categories_card.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/farmer_product_edit_screen.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/farm_creation_dialog.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_sold_status_overlay.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_header.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_add_product_button.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_tabs.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_product_card.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_product_details.dart';
part 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_dashboard_empty_state.dart';

enum _FarmerDashboardTab { products, categories }

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({
    this.pickProductImageBytes,
    this.commodityRepository = const FarmerCommodityRepository(),
    super.key,
  });
  final ProductImagePicker? pickProductImageBytes;
  final FarmerCommodityRepository commodityRepository;
  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  late final List<FarmerDashboardProduct> _products;
  var _activeTab = _FarmerDashboardTab.products;
  var _isLoadingProducts = false;
  var _isSavingProduct = false;
  @override
  void initState() {
    super.initState();
    _products = <FarmerDashboardProduct>[];
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final canPostProducts = _canPostProducts;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 14.0;
    final gridSpacing = width < 380 ? 9.0 : 11.0;
    final productRatio = width < 380 ? 0.6 : 0.65;
    final navClearance = 148.0 + MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _FarmerDashboardHeader(horizontalPadding: horizontalPadding),
            Expanded(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _FarmerAddProductButton(
                      horizontalPadding: horizontalPadding,
                      isEnabled: canPostProducts,
                      onPressed: _openAddProductScreen,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        0,
                      ),
                      child: _FarmerDashboardTabs(
                        activeTab: _activeTab,
                        onChanged: (tab) => setState(() => _activeTab = tab),
                      ),
                    ),
                  ),
                  if (_activeTab == _FarmerDashboardTab.products)
                    if (_products.isEmpty && _isLoadingProducts)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (_products.isEmpty)
                      const SliverToBoxAdapter(
                        child: _FarmerDashboardEmptyState(
                          message:
                              'Products from the backend will appear here.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          10,
                          horizontalPadding,
                          0,
                        ),
                        sliver: SliverGrid.builder(
                          itemCount: _products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: gridSpacing,
                                mainAxisSpacing: gridSpacing + 2,
                                childAspectRatio: productRatio,
                              ),
                          itemBuilder: (context, index) => _FarmerProductCard(
                            product: _products[index],
                            onEdit: () => _openEditProduct(index),
                          ),
                        ),
                      )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        10,
                        horizontalPadding,
                        0,
                      ),
                      sliver: const SliverToBoxAdapter(
                        child: HomeCategoriesCard(),
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: navClearance)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddProductScreen() async {
    if (!_canPostProducts) {
      _showMessage(
        'Your farmer account must be verified before you can add products.',
      );
      return;
    }
    final product = await Navigator.of(context).push<FarmerDashboardProduct>(
      agrisellPageRoute<FarmerDashboardProduct>(
        builder: (_) => AddProductScreen(
          pickProductImageBytes: widget.pickProductImageBytes,
        ),
      ),
    );
    if (product == null || !mounted) {
      return;
    }
    final savedProduct = await _saveProduct(product);
    if (savedProduct == null || !mounted) return;
    setState(() {
      _activeTab = _FarmerDashboardTab.products;
      _products.add(savedProduct);
    });
    _showMessage('${savedProduct.name} has been saved.');
  }

  Future<void> _openEditProduct(int index) async {
    if (index < 0 || index >= _products.length) {
      return;
    }
    final product = _products[index];
    final updatedProduct = await Navigator.of(context)
        .push<FarmerDashboardProduct>(
          agrisellPageRoute<FarmerDashboardProduct>(
            builder: (_) => FarmerProductEditScreen(
              product: product,
              pickProductImageBytes: widget.pickProductImageBytes,
            ),
          ),
        );
    if (updatedProduct == null || !mounted) {
      return;
    }
    final savedProduct = await _saveProduct(updatedProduct);
    if (savedProduct == null || !mounted) return;
    setState(() => _products[index] = savedProduct);
    _showMessage('${savedProduct.name} has been saved.');
  }

  Future<FarmerDashboardProduct?> _saveProduct(
    FarmerDashboardProduct product,
  ) async {
    if (_isSavingProduct) return null;
    _isSavingProduct = true;
    try {
      return await _saveToDatabase(product);
    } on FarmRequiredException {
      if (!mounted) return null;
      final farmName = await showFarmCreationDialog(context);
      if (farmName == null || !mounted) return null;
      try {
        await widget.commodityRepository.createFarm(farmName);
        return await _saveToDatabase(product);
      } on FarmerCommodityException catch (error) {
        if (mounted) _showMessage(error.message);
        return null;
      }
    } on FarmerCommodityException catch (error) {
      if (mounted) _showMessage(error.message);
      return null;
    } catch (_) {
      if (mounted) {
        _showMessage('The product could not be saved. Please try again.');
      }
      return null;
    } finally {
      _isSavingProduct = false;
    }
  }

  Future<FarmerDashboardProduct> _saveToDatabase(
    FarmerDashboardProduct product,
  ) {
    if (!widget.commodityRepository.isAvailable) {
      return Future.value(product);
    }
    return widget.commodityRepository.save(product);
  }

  Future<void> _loadProducts() async {
    if (!widget.commodityRepository.isAvailable) return;
    setState(() => _isLoadingProducts = true);
    try {
      final products = await widget.commodityRepository.loadProducts();
      if (mounted) setState(() => _products.addAll(products));
    } on FarmerCommodityException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SnackBar(content: Text(message)));
  }

  bool get _canPostProducts {
    final account = AuthSessionService.instance.currentAccount;
    return account == null || account.isFarmerVerified;
  }
}
