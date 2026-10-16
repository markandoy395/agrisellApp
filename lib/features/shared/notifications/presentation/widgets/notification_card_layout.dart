import 'package:flutter/material.dart';

class NotificationCardLayout extends StatelessWidget {
  const NotificationCardLayout({
    required this.leading,
    required this.content,
    required this.actions,
    super.key,
  });

  final Widget leading;
  final Widget content;
  final Widget actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 320 ||
          MediaQuery.textScalerOf(context).scale(13) > 20) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leading, const Spacer(), actions],
            ),
            const SizedBox(height: 8),
            content,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 11),
          Expanded(child: content),
          actions,
        ],
      );
    },
  );
}
