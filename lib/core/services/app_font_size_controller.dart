import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the text-size preference selected from any account's settings.
class AppFontSizeController extends ChangeNotifier {
  AppFontSizeController();

  static final AppFontSizeController instance = AppFontSizeController();

  static const double minimumScale = 1;
  static const double maximumScale = 1.3;
  static const double scaleStep = 0.1;
  static const String _preferenceKey = 'app_font_size_scale_v1';

  double _textScale = minimumScale;
  Future<void>? _loadRequest;

  double get textScale => _textScale;
  bool get canIncrease => _textScale < maximumScale;
  bool get canDecrease => _textScale > minimumScale;

  String get displayLabel => switch (_textScale) {
    <= 1.0 => 'Default',
    <= 1.1 => 'Large',
    <= 1.2 => 'Larger',
    _ => 'Largest',
  };

  String get percentageLabel => '${(_textScale * 100).round()}%';

  /// Loads the saved choice without preventing the app from opening if local
  /// preferences are temporarily unavailable.
  Future<void> load() => _loadRequest ??= _load();

  Future<void> _load() async {
    try {
      final preferences = await _instance;
      final savedScale = preferences.getDouble(_preferenceKey);
      if (savedScale == null) return;
      _update(_normalise(savedScale));
    } catch (_) {
      // The default text size remains available when local storage fails.
    }
  }

  Future<void> increase() => setTextScale(_textScale + scaleStep);

  Future<void> decrease() => setTextScale(_textScale - scaleStep);

  Future<void> setTextScale(double scale) async {
    final nextScale = _normalise(scale);
    _update(nextScale);
    try {
      final preferences = await _instance;
      await preferences.setDouble(_preferenceKey, nextScale);
    } catch (_) {
      // Keep the change for the current session if it cannot be persisted.
    }
  }

  void _update(double nextScale) {
    if (_textScale == nextScale) return;
    _textScale = nextScale;
    notifyListeners();
  }

  double _normalise(double scale) {
    final clamped = scale.clamp(minimumScale, maximumScale).toDouble();
    return (clamped * 10).roundToDouble() / 10;
  }

  Future<SharedPreferences> get _instance => SharedPreferences.getInstance();
}
