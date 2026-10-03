import 'package:agresell_app/features/rider/presentation/styles/rider_page_widgets_styles.dart';
import 'package:flutter/material.dart';

class RiderPageHeader extends StatelessWidget {
  const RiderPageHeader({
    required this.title,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, topInset + 14, 18, 18),
      decoration: RiderPageWidgetsStyles.containerDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RiderPageWidgetsStyles.titleText),
                if (subtitle case final value?) ...[
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RiderPageWidgetsStyles.valueText,
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class RiderSurfaceCard extends StatelessWidget {
  const RiderSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: RiderPageWidgetsStyles.decoratedBoxDecoration,
      child: Padding(padding: padding, child: child),
    );
  }
}

class RiderSectionTitle extends StatelessWidget {
  const RiderSectionTitle({required this.title, this.action, super.key});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: RiderPageWidgetsStyles.titleText2)),
        ?action,
      ],
    );
  }
}
