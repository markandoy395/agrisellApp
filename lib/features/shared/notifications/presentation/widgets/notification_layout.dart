import 'package:flutter/material.dart';

/// Lets the header give space back to the feed on short viewports.
class NotificationLayout extends StatelessWidget {
  const NotificationLayout({
    required this.header,
    required this.body,
    super.key,
  });

  final List<Widget> header;
  final Widget body;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Column(mainAxisSize: MainAxisSize.min, children: header),
        ),
      ],
      body: body,
    ),
  );
}
