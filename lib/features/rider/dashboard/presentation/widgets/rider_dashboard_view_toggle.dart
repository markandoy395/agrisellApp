import 'package:flutter/material.dart';

class RiderViewToggle extends StatelessWidget {
  const RiderViewToggle({
    required this.showMap,
    required this.onChanged,
    super.key,
  });

  final bool showMap;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: false, label: Text('List')),
        ButtonSegment(value: true, label: Text('Map')),
      ],
      selected: {showMap},
      onSelectionChanged: (value) => onChanged(value.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
