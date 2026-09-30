import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:agresell_app/features/shared/reporting/services/csv_export_service.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  group('CsvExportService Tests', () {
    test('generateCsv prepends UTF-8 BOM and formats headers and rows', () {
      final headers = ['Name', 'Category', 'Price'];
      final rows = [
        ['Carrots', 'Vegetable', 45.50],
        ['Strawberries', 'Fruit', 120.00],
      ];

      final csv = CsvExportService.generateCsv(headers: headers, rows: rows);

      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv.contains('Name,Category,Price\r\n'), isTrue);
      expect(csv.contains('Carrots,Vegetable,45.5\r\n'), isTrue);
      expect(csv.contains('Strawberries,Fruit,120.0\r\n'), isTrue);
    });

    test('generateCsv correctly escapes commas, quotes, and newlines per RFC 4180', () {
      final headers = ['Description', 'Notes'];
      final rows = [
        ['Fresh, organic carrots', 'Great quality'],
        ['Strawberries "Sweet"', 'Bruised\nat bottom'],
        [null, 'Normal note'],
      ];

      final csv = CsvExportService.generateCsv(headers: headers, rows: rows);

      // Comma must be wrapped in quotes
      expect(csv.contains('"Fresh, organic carrots",Great quality'), isTrue);
      // Double quotes must be escaped as double-double-quotes and wrapped in quotes
      expect(csv.contains('"Strawberries ""Sweet""","Bruised\nat bottom"'), isTrue);
      // Null cell outputs empty string
      expect(csv.contains(',Normal note'), isTrue);
    });

    test('saveCsvToFile writes file to directory', () async {
      const fileName = 'test_report_2026';
      const content = '\uFEFFHeader1,Header2\r\nVal1,Val2\r\n';

      final file = await CsvExportService.saveCsvToFile(
        fileName: fileName,
        csvContent: content,
      );

      expect(file.existsSync(), isTrue);
      expect(file.readAsBytesSync().sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      expect(file.readAsStringSync(), content.replaceAll('\uFEFF', ''));

      // Cleanup
      file.deleteSync();
    });
  });
}
