import 'package:flutter/material.dart';

/// Prefetch one page near the viewport without notifying catalog listeners
/// during a scroll layout or scheduling several requests in the same frame.
class HomeCatalogPagination extends StatefulWidget {
  const HomeCatalogPagination({
    required this.enabled,
    required this.onLoadMore,
    required this.child,
    super.key,
  });

  final bool enabled;
  final VoidCallback? onLoadMore;
  final Widget child;

  @override
  State<HomeCatalogPagination> createState() => _HomeCatalogPaginationState();
}

class _HomeCatalogPaginationState extends State<HomeCatalogPagination> {
  bool _queued = false;

  void _prefetch(ScrollMetrics metrics, int depth) {
    if (!widget.enabled || widget.onLoadMore == null || _queued) return;
    if (depth != 0 || metrics.axis != Axis.vertical) return;
    if (metrics.extentAfter > metrics.viewportDimension) return;
    _queued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queued = false;
      if (mounted && widget.enabled) widget.onLoadMore?.call();
    });
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        onNotification: (event) {
          _prefetch(event.metrics, event.depth);
          return false;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (event) {
            if (event is ScrollUpdateNotification && event.scrollDelta != 0) {
              _prefetch(event.metrics, event.depth);
            }
            return false;
          },
          child: widget.child,
        ),
      );
}
