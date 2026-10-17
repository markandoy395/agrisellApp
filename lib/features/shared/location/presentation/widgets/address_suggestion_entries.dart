import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

/// Retains menu entries (and Flutter's menu item keys) across parent rebuilds.
class AddressSuggestionEntries {
  static const limit = 20;
  List<PsgcAddressOption> _visible = const [];
  List<DropdownMenuEntry<PsgcAddressOption>> _entries = const [];

  List<DropdownMenuEntry<PsgcAddressOption>> resolve(
    List<PsgcAddressOption> options,
    String query,
  ) {
    // Search the entire catalogue, but only construct the visible menu items.
    final visible = options
        .where(
          (option) =>
              query.isEmpty ||
              option.name.toLowerCase().contains(query) ||
              option.province.toLowerCase().contains(query),
        )
        .take(limit)
        .toList(growable: false);
    if (listEquals(visible, _visible)) return _entries;
    _visible = visible;
    return _entries = visible
        .map(
          (option) => DropdownMenuEntry<PsgcAddressOption>(
            value: option,
            label: option.name,
            labelWidget: Text(
              option.province.isEmpty
                  ? option.name
                  : '${option.name} \u2014 ${option.province}',
              style: SharedPresentationStyles.caption,
            ),
          ),
        )
        .toList(growable: false);
  }
}
