// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'package:jetleaf_convert/convert.dart';
import 'package:jetleaf_lang/lang.dart';
import 'package:test/test.dart';

import '_dependencies.dart';
import '_test_models.dart';

void main() async {
  setUpAll(() async {
    await setupRuntime();
    return Future<void>.value();
  });

  group('ConvertingComparator', () {
    test('should sort MapEntry by keys', () {
      final entries = [
        MapEntry('c', 1),
        MapEntry('a', 3),
        MapEntry('b', 2),
      ];
      entries.sort(ConvertingComparator.mapEntryKeys(Comparator.naturalOrder()).compare);
      expect(entries.map((e) => e.key), ['a', 'b', 'c']);
    });

    test('should sort MapEntry by values', () {
      final entries = [
        MapEntry('a', 3),
        MapEntry('b', 1),
        MapEntry('c', 2),
      ];
      entries.sort(ConvertingComparator.mapEntryValues(Comparator.naturalOrder()).compare);
      expect(entries.map((e) => e.value), [1, 2, 3]);
    });

    test('should use ConversionServiceConverter', () {
      final customService = DefaultConversionService();
      customService.addConverterWithClass(Class.of<String>(), Class.of<int>(), CustomConverter()); // Registers x2 converter

      final comparator = ConvertingComparator.withConverter(
        Comparator.naturalOrder(),
        customService,
        Class.of<int>(),
      );
      final list = ['1', '5', '2']; // Will be converted to [2, 10, 4]
      list.sort(comparator.compare);
      expect(list, ['1', '2', '5']); // Sorted by converted values
    });
  });
}