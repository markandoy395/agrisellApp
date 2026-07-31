import 'package:flutter/material.dart';

class RiderKeepAliveTab extends StatefulWidget {
  const RiderKeepAliveTab({required this.child, super.key});

  final Widget child;

  @override
  State<RiderKeepAliveTab> createState() => _RiderKeepAliveTabState();
}

class _RiderKeepAliveTabState extends State<RiderKeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
