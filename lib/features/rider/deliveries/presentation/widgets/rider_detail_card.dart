import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_delivery_reference_styles.dart';

class RiderDetailCard extends StatelessWidget {
  const RiderDetailCard({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderDeliveryReferenceStyles.card,
    padding: const EdgeInsets.all(14),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class RiderDetailSection extends StatelessWidget {
  const RiderDetailSection({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
    this.color = AgrisellColors.authGreen,
    super.key,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final Color color;
  @override
  Widget build(BuildContext context) => RiderDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, style: RiderDeliveryReferenceStyles.title),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Flexible(child: trailing!),
            ],
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );
}

class RiderDetailLine extends StatelessWidget {
  const RiderDetailLine({
    required this.icon,
    required this.label,
    this.value,
    this.color = AgrisellColors.authGreen,
    super.key,
  });
  final IconData icon;
  final String label;
  final String? value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: RiderDeliveryReferenceStyles.body),
              if (value != null)
                Text(value!, style: RiderDeliveryReferenceStyles.caption),
            ],
          ),
        ),
      ],
    ),
  );
}

class RiderDetailInstructions extends StatelessWidget {
  const RiderDetailInstructions({
    required this.text,
    this.delivery = false,
    super.key,
  });
  final String text;
  final bool delivery;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: RiderDeliveryReferenceStyles.tint(
      delivery ? AgrisellColors.statusRedText : AgrisellColors.authGreen,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          delivery ? 'Delivery instructions' : 'Pickup instructions',
          style: RiderDeliveryReferenceStyles.strongCaption,
        ),
        const SizedBox(height: 3),
        Text(text, style: RiderDeliveryReferenceStyles.caption),
      ],
    ),
  );
}

String riderDetailDate(BuildContext context, DateTime date) {
  final local = date.toLocal();
  final material = MaterialLocalizations.of(context);
  return '${material.formatMediumDate(local)} · ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}
