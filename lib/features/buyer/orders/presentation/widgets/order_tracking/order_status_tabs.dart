part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderStatusTabs extends StatelessWidget {
  const _OrderStatusTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 10.0 : 14.0;

    return Container(
      color: AgrisellColors.homeBackground,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        14,
        horizontalPadding,
        10,
      ),
      child: DecoratedBox(
        decoration: OrderStatusTabsStyles.decoratedBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            indicator: OrderStatusTabsStyles.tabBarDecoration,
            labelColor: AgrisellColors.surface,
            unselectedLabelColor: AgrisellColors.brandBlack,
            labelStyle: SharedPresentationStyles.captionBold,
            unselectedLabelStyle: SharedPresentationStyles.captionSemibold,
            tabs: [
              for (final filter in _orderTrackingTabs)
                SizedBox(width: 82, height: 38, child: Tab(text: filter.label)),
            ],
          ),
        ),
      ),
    );
  }
}
