import 'dart:convert';

import 'package:flutter/services.dart';

/// Standalone documents carry their stylesheet and fonts without network access.
abstract final class WaybillHtmlStyles {
  static Future<String>? _stylesheetUri;

  static Future<String> loadUri() => _stylesheetUri ??= _loadUri();

  static Future<String> _loadUri() async {
    try {
      var css = await rootBundle.loadString('assets/styles/waybill.css');
      const fonts = {
        'REGULAR': 'Regular',
        'SEMIBOLD': 'SemiBold',
        'BOLD': 'Bold',
        'EXTRABOLD': 'ExtraBold',
      };
      for (final font in fonts.entries) {
        final data = await rootBundle.load(
          'assets/fonts/Poppins/Poppins-${font.value}.ttf',
        );
        final uri = Uri.dataFromBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          mimeType: 'font/ttf',
        );
        css = css.replaceAll('{{POPPINS_${font.key}}}', uri.toString());
      }
      return Uri.dataFromString(
        css,
        mimeType: 'text/css',
        encoding: utf8,
        base64: true,
      ).toString();
    } catch (_) {
      _stylesheetUri = null;
      rethrow;
    }
  }
}
