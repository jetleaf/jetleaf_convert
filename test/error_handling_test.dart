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

void main() {
  late DefaultConversionService service;

  setUpAll(() async {
    await setupRuntime();
    service = DefaultConversionService();
    return Future<void>.value();
  });

  group('Null Handling', () {
    test('null conversions', () {
      expect(service.convert<int?>(null, Class.of<int>()), isNull);
      expect(service.convert<String?>(null, Class.of<String>()), isNull);
      expect(service.convert<bool?>(null, Class.of<bool>()), isNull);
    });

    test('canConvert with null source type', () {
      expect(service.canConvert(null, Class.of<int>()), isTrue);
      expect(service.canConvert(null, Class.of<String>()), isTrue);
    });
  });

  group('Error Handling', () {
    test('conversion failures should throw ConversionFailedException', () {
      expect(() => service.convert<int>('abc', Class.of<int>()), 
          throwsA(isA<ConversionFailedException>()));
      expect(() => service.convert<DateTime>('invalid-date', Class.of<DateTime>()), 
          throwsA(isA<ConversionFailedException>()));
    });

    test('unsupported conversions should throw ConverterNotFoundException', () {
      expect(() => service.convertTo(MyClass('test', 1), Class.of<MyClass>(), Class.of<DateTime>()), 
          throwsA(isA<ConverterNotFoundException>()));
    });

    test('type mismatch should throw ConversionException', () {
      expect(() => service.convertTo('123', Class.of<int>(), Class.of<String>()), 
          throwsA(isA<ConversionException>()));
    });
  });

  group('Performance and Edge Cases', () {
    test('large collections', () {
      final largeList = List.generate(10000, (i) => i.toString());
      final result = service.convertTo(largeList, Class.of<List<int>>());
      expect(result is List, isTrue);
      expect((result as List).length, 10000);
      expect(result.first, 0);
      expect(result.last, 9999);
    });

    test('deeply nested collections', () {
      final nested = [['1', '2'], ['3', '4']];
      final result = service.convertTo(nested, Class.of<List<List<int>>>());
      expect(result, [[1, 2], [3, 4]]);
    });

    test('circular reference handling', () {
      // This would require more sophisticated handling in a real implementation
      final map1 = <String, dynamic>{'name': 'map1'};
      final map2 = <String, dynamic>{'name': 'map2', 'ref': map1};
      map1['ref'] = map2;
      
      // Should not cause infinite recursion
      expect(() => service.convert<String>(map1, Class.of<String>()), returnsNormally);
    });
  });
}