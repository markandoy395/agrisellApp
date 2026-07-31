import 'package:agresell_app/core/services/app_font_size_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads, changes, and clamps the saved font size', () async {
    SharedPreferences.setMockInitialValues({'app_font_size_scale_v1': 1.2});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppFontSizeController();

    await controller.load();
    expect(controller.textScale, 1.2);
    expect(controller.displayLabel, 'Larger');

    await controller.increase();
    await controller.increase();
    expect(controller.textScale, AppFontSizeController.maximumScale);
    expect(controller.canIncrease, isFalse);
    expect(preferences.getDouble('app_font_size_scale_v1'), 1.3);

    await controller.setTextScale(0.5);
    expect(controller.textScale, AppFontSizeController.minimumScale);
    expect(controller.canDecrease, isFalse);
  });
}
