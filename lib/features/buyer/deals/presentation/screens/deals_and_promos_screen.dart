import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/deals/data/buyer_deals_repository.dart';
import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import 'package:agresell_app/features/buyer/deals/presentation/widgets/voucher_card.dart';
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
    return source.where((deal) {
      final name = deal.name.toLowerCase();
      final code = deal.code?.toLowerCase() ?? '';
      final farm = deal.farmName?.toLowerCase() ?? '';
      return name.contains(_searchQuery) ||
          code.contains(_searchQuery) ||
          farm.contains(_searchQuery);
    }).toList(growable: false);
  }

  List<DealVoucher> get _vouchers =>
      _filterDeals(_deals.where((d) => d.hasCode).toList(growable: false));

  List<DealVoucher> get _allDeals => _filterDeals(_deals);

  void _openShopProducts(DealVoucher voucher) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
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
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isSelectingForCheckout
              ? 'Select Voucher'
              : 'Deals & Voucher Wallet',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AgrisellColors.authGreen,
              unselectedLabelColor: AgrisellColors.mutedText,
              indicatorColor: AgrisellColors.authGreen,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(
                  text: 'Vouchers & Codes (${_deals.where((d) => d.hasCode).length})',
                ),
                Tab(
                  text: 'All Deals (${_deals.length})',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vouchers by name or code...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AgrisellColors.mutedText,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AgrisellColors.mutedText,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AgrisellColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AgrisellColors.borderLine),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AgrisellColors.borderLine),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AgrisellColors.authGreen,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AgrisellColors.authGreen,
                    ),
                  )
                : _loadFailed
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Unable to load deals.',
                              style: TextStyle(
                                color: AgrisellColors.mutedText,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadDeals,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AgrisellColors.authGreen,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDeals,
                        color: AgrisellColors.authGreen,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildVouchersList(_vouchers),
                            _buildVouchersList(_allDeals),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildVouchersList(List<DealVoucher> items) {
    if (items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 60),
          Icon(
            Icons.confirmation_number_outlined,
            size: 56,
            color: AgrisellColors.borderLine,
          ),
          SizedBox(height: 14),
          Center(
            child: Text(
              'No active vouchers found',
              style: TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 6),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                'Check back soon! New promotional deals and vouchers are added regularly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final voucher = items[index];
        return VoucherCard(
          voucher: voucher,
          onShopProducts: voucher.productCount > 0
              ? () => _openShopProducts(voucher)
              : null,
          onApply: widget.isSelectingForCheckout
              ? () => _applyVoucher(voucher)
              : null,
        );
      },
    );
  }
}
