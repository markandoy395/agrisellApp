import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/features/buyer/chat/presentation/buyer_conversation_launcher.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_shop_styles.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_shop_content.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_profile_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_shop_header.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_shop_tabs.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';

part 'farmer_shop_screen_actions.dart';
part 'farmer_shop_screen_loading.dart';

class FarmerShopScreen extends StatefulWidget {
  const FarmerShopScreen({
    required this.farmer,
    this.productRepository = const HomeProductRepository(),
    this.followController,
    super.key,
  });

  final FarmerProfile farmer;
  final HomeProductRepository productRepository;
  final FarmerFollowController? followController;

  @override
  State<FarmerShopScreen> createState() => _FarmerShopScreenState();
}

class _FarmerShopScreenState extends State<FarmerShopScreen> {
  late final TextEditingController _searchController;
  late final FarmerFollowController _followController;
  List<HomeProduct> _products = const [];
  var _isLoading = true;
  var _loadFailed = false;
  var _activeTab = FarmerShopTab.products;
  String? _selectedCategory;
  var _searchQuery = '';

  void _updateUi(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _followController =
        widget.followController ?? FarmerFollowController.instance;
    _followController.seed([widget.farmer]);
    unawaited(_loadFollowState());
    unawaited(_loadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, int> get _categoryCounts {
    final counts = <String, int>{};
    for (final product in _products) {
      if (!product.canOrder) continue;
      counts.update(product.category, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  List<HomeProduct> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    return [
      for (final product in _products)
        if (product.canOrder &&
            _matchesCategory(product) &&
            _matchesQuery(product, query))
          product,
    ];
  }

  bool _matchesCategory(HomeProduct product) {
    return _selectedCategory == null || product.category == _selectedCategory;
  }

  bool _matchesQuery(HomeProduct product, String query) {
    return query.isEmpty ||
        product.name.toLowerCase().contains(query) ||
        product.category.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final headerHeight = FarmerShopStyles.headerHeight(size);
    final profileHeight = FarmerShopStyles.profileHeight(size.width);
    final profileTop = FarmerShopStyles.profileTop(headerHeight);
    final contentTop = FarmerShopStyles.contentTop(profileTop, profileHeight);

    return BuyerResponsiveText(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: FarmerShopStyles.backgroundColor,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: headerHeight,
              child: FarmerShopHeader(
                coverImage: widget.farmer.coverImage,
                coverImageUrl: widget.farmer.coverImageUrl,
                height: headerHeight,
                searchController: _searchController,
                onSearchChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                onBack: () => Navigator.of(context).maybePop(),
                onMenuSelected: _handleMenuAction,
              ),
            ),
            Positioned(
              left: 0,
              top: profileTop,
              right: 0,
              child: AnimatedBuilder(
                animation: _followController,
                builder: (context, _) {
                  final state = _followController.stateFor(widget.farmer);
                  return FarmerProfileCard(
                    farmer: widget.farmer.copyWith(
                      followerCount: state.followerCount,
                      isFollowing: state.isFollowing,
                    ),
                    height: profileHeight,
                    followController: _followController,
                    onChat: _openChat,
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              top: contentTop,
              right: 0,
              bottom: 0,
              child: FarmerShopContent(
                activeTab: _activeTab,
                categoryCounts: _categoryCounts,
                selectedCategory: _selectedCategory,
                products: _filteredProducts,
                isLoading: _isLoading,
                loadFailed: _loadFailed,
                onRetry: _loadProducts,
                onTabChanged: (tab) {
                  setState(() {
                    _activeTab = tab;
                    if (tab == FarmerShopTab.products) {
                      _selectedCategory = null;
                    }
                  });
                },
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                    _activeTab = FarmerShopTab.products;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                onProductTap: _openProduct,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
