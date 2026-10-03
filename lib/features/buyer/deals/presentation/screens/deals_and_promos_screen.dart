import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/deals/data/buyer_deals_repository.dart';
import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import 'package:agresell_app/features/buyer/deals/presentation/styles/deals_and_promos_screen_styles.dart';
import 'package:agresell_app/features/buyer/deals/presentation/widgets/deals_error_view.dart';
import 'package:agresell_app/features/buyer/deals/presentation/widgets/deals_search_bar.dart';
import 'package:agresell_app/features/buyer/deals/presentation/widgets/deals_voucher_list_view.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/sale_products_screen.dart';

class DealsAndPromosScreen extends StatefulWidget {
  const DealsAndPromosScreen({
    this.dealsRepository = const BuyerDealsRepository(),
    this.isSelectingForCheckout = false,
    this.onVoucherSelected,
    super.key,
  });

  final BuyerDealsRepository dealsRepository;
  final bool isSelectingForCheckout;
  final ValueChanged<DealVoucher>? onVoucherSelected;

  @override
  State<DealsAndPromosScreen> createState() => _DealsAndPromosScreenState();
}

class _DealsAndPromosScreenState extends State<DealsAndPromosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  List<DealVoucher> _deals = const [];
  var _isLoading = true;
  var _loadFailed = false;
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeals() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final deals = await widget.dealsRepository.loadActiveDeals();
      if (!mounted) return;
      setState(() {
        _deals = deals;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _isLoading = false;
      });
    }
  }

  List<DealVoucher> _filterDeals(List<DealVoucher> source) {
    if (_searchQuery.isEmpty) return source;
    return source
        .where((deal) {
          final name = deal.name.toLowerCase();
          final code = deal.code?.toLowerCase() ?? '';
          final farm = deal.farmName?.toLowerCase() ?? '';
          return name.contains(_searchQuery) ||
              code.contains(_searchQuery) ||
              farm.contains(_searchQuery);
        })
        .toList(growable: false);
  }

  List<DealVoucher> get _vouchers =>
      _filterDeals(_deals.where((d) => d.hasCode).toList(growable: false));

  List<DealVoucher> get _allDeals => _filterDeals(_deals);

  void _openShopProducts(DealVoucher voucher) {
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => SaleProductsScreen(
          title: voucher.name,
          campaignSaleId: voucher.saleId,
        ),
      ),
    );
  }

  void _applyVoucher(DealVoucher voucher) {
    if (widget.onVoucherSelected != null) {
      widget.onVoucherSelected!(voucher);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        backgroundColor: DealsAndPromosScreenStyles.appBarBackground,
        foregroundColor: Colors.white,
        elevation: DealsAndPromosScreenStyles.appBarElevation,
        title: Text(
          widget.isSelectingForCheckout
              ? 'Select Voucher'
              : 'Deals & Voucher Wallet',
          style: DealsAndPromosScreenStyles.appBarTitleStyle,
        ),
        bottom: PreferredSize(
          preferredSize: DealsAndPromosScreenStyles.tabBarPreferredSize,
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: DealsAndPromosScreenStyles.tabLabelColor,
              unselectedLabelColor:
                  DealsAndPromosScreenStyles.tabUnselectedLabelColor,
              indicatorColor: DealsAndPromosScreenStyles.tabIndicatorColor,
              indicatorWeight: DealsAndPromosScreenStyles.tabIndicatorWeight,
              labelStyle: DealsAndPromosScreenStyles.tabLabelStyle,
              tabs: [
                Tab(
                  text:
                      'Vouchers & Codes (${_deals.where((d) => d.hasCode).length})',
                ),
                Tab(text: 'All Deals (${_deals.length})'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          DealsSearchBar(
            controller: _searchController,
            hasQuery: _searchQuery.isNotEmpty,
            onChanged: (value) =>
                setState(() => _searchQuery = value.trim().toLowerCase()),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AgrisellColors.authGreen,
                    ),
                  )
                : _loadFailed
                ? DealsErrorView(onRetry: _loadDeals)
                : RefreshIndicator(
                    onRefresh: _loadDeals,
                    color: AgrisellColors.authGreen,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        DealsVoucherListView(
                          items: _vouchers,
                          onShopProducts: _openShopProducts,
                          onApply: widget.isSelectingForCheckout
                              ? _applyVoucher
                              : null,
                        ),
                        DealsVoucherListView(
                          items: _allDeals,
                          onShopProducts: _openShopProducts,
                          onApply: widget.isSelectingForCheckout
                              ? _applyVoucher
                              : null,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
