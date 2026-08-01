import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared code has no role-specific imports or exports', () {
    final violations = _importsMatching(
      'lib/features/shared',
      RegExp(
        r"^(?:import|export) 'package:agresell_app/features/(?:buyer|farmer|rider|admin)/",
        multiLine: true,
      ),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('farmer code does not depend on buyer implementation folders', () {
    final violations = _importsMatching(
      'lib/features/farmer',
      RegExp(
        r"^(?:import|export) 'package:agresell_app/features/buyer/",
        multiLine: true,
      ),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('buyer code does not consume farmer-owned reusable widgets', () {
    final violations = _importsMatching(
      'lib/features/buyer',
      RegExp(
        r"^(?:import|export) 'package:agresell_app/features/farmer/",
        multiLine: true,
      ),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

List<String> _importsMatching(String root, RegExp pattern) {
  final violations = <String>[];
  for (final entity in Directory(root).listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = entity.readAsStringSync();
    for (final match in pattern.allMatches(content)) {
      violations.add('${entity.path}: ${match.group(0)}');
    }
  }
  return violations;
}
