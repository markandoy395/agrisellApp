import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/rider_map_design_styles.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

class RiderMapAttribution extends StatelessWidget {
  const RiderMapAttribution({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 12, top: 70),
      child: Material(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () =>
              launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              '\u00a9 OpenStreetMap contributors',
              style: RiderMapDesignStyles.caption,
            ),
          ),
        ),
      ),
    ),
  );
}
