import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_categories_card.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/farmer_product_edit_screen.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/farm_creation_dialog.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/farmer_restock_dialog.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_quick_menu.dart';
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
    this.onNavigate,
    super.key,
  });
  final ProductImagePicker? pickProductImageBytes;
  final FarmerCommodityRepository commodityRepository;
  final ValueChanged<FarmerQuickDestination>? onNavigate;
  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  late final List<FarmerDashboardProduct> _products;
  final _searchController = TextEditingController();
  var _activeTab = _FarmerDashboardTab.products;
  var _selectedCategory = 'All';
  var _searchQuery = '';
  var _isLoadingProducts = false;
  var _isSavingProduct = false;
  final _restockingProductIds = <int>{};
  @override
  void initState() {
    super.initState();
    _products = <FarmerDashboardProduct>[];
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmerDashboardProduct> get _visibleProducts {
    final query = _searchQuery.trim().toLowerCase();
    return [
      for (final product in _products)
        if ((_selectedCategory == 'All' ||
                product.category == _selectedCategory) &&
            (query.isEmpty ||
                product.name.toLowerCase().contains(query) ||
                product.category.toLowerCase().contains(query) ||
                product.description.toLowerCase().contains(query)))
          product,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final canPostProducts = _canPostProducts;
    final visibleProducts = _visibleProducts;
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
            _FarmerDashboardHeader(
              horizontalPadding: horizontalPadding,
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _activeTab = _FarmerDashboardTab.products;
                });
              },
              onMenuTap: _openQuickMenu,
            ),
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
                    else if (visibleProducts.isEmpty)
                      const SliverToBoxAdapter(
                        child: _FarmerDashboardEmptyState(
                          message: 'No products match your search or category.',
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
                          itemCount: visibleProducts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: gridSpacing,
                                mainAxisSpacing: gridSpacing + 2,
                                childAspectRatio: productRatio,
                              ),
                          itemBuilder: (context, index) {
                            final product = visibleProducts[index];
                            return _FarmerProductCard(
                              product: product,
                              onEdit: () =>
                                  _openEditProduct(_products.indexOf(product)),
                              onRestock: () => _openRestockProduct(
                                _products.indexOf(product),
                              ),
                              isRestocking:
                                  product.commodityId != null &&
                                  _restockingProductIds.contains(
                                    product.commodityId,
                                  ),
                            );
                          },
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
                      sliver: SliverToBoxAdapter(
                        child: HomeCategoriesCard(
                          selectedCategory: _selectedCategory,
                          onSelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                              _activeTab = _FarmerDashboardTab.products;
                            });
                          },
                        ),
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

  Future<void> _openQuickMenu() async {
    final destination = await showFarmerQuickMenu(
      context,
      current: FarmerQuickDestination.products,
    );
    if (destination != null && mounted) widget.onNavigate?.call(destination);
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

  Future<void> _openRestockProduct(int index) async {
    if (index < 0 || index >= _products.length) return;
    final product = _products[index];
    final commodityId = product.commodityId;
    if (commodityId == null || commodityId <= 0) {
      _showMessage('Save this product before adding stock.');
      return;
    }
    if (_restockingProductIds.contains(commodityId)) return;

    final request = await showFarmerRestockDialog(context, product: product);
    if (request == null || !mounted) return;

    setState(() => _restockingProductIds.add(commodityId));
    try {
      final updatedProduct = await widget.commodityRepository.restock(
        product: product,
        quantity: request.quantity,
        inventoryLot: request.inventoryLot,
        reason: request.reason,
      );
      if (!mounted) return;
      final currentIndex = _products.indexWhere(
        (candidate) => candidate.commodityId == commodityId,
      );
      if (currentIndex >= 0) {
        setState(() => _products[currentIndex] = updatedProduct);
      }
      _showMessage(
        '${updatedProduct.name} now has ${updatedProduct.availableWeight} in stock.',
      );
    } on FarmerCommodityException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) {
        _showMessage('Stock could not be added. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _restockingProductIds.remove(commodityId));
      }
    }
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
