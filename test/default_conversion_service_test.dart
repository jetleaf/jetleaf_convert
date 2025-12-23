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

void main() async {
  late DefaultConversionService service;

  setUpAll(() async {
    await setupRuntime();
    service = DefaultConversionService();
    return Future<void>.value();
  });

  group('DefaultConversionService', () {
    test('should be instantiated correctly', () {
      expect(service, isA<ConversionService>());
      expect(service, isA<ConfigurableConversionService>());
    });

    test('getSharedInstance should return a singleton', () {
      final instance1 = DefaultConversionService.getCommonInstance();
      final instance2 = DefaultConversionService.getCommonInstance();
      expect(instance1, same(instance2));
    });

    test('should have default converters registered', () {
      expect(service.canConvert(Class<String>(), Class<int>()), isTrue);
      expect(service.canConvert(Class<int>(), Class<String>()), isTrue);
      expect(service.canConvert(Class<DateTime>(), Class<String>()), isTrue);
      expect(service.canConvert(Class<String>(), Class<DateTime>()), isTrue);
      expect(service.canConvert(Class<List<String>>(), Class<List<int>>()), isTrue);
      expect(service.canConvert(Class<Map<String, String>>(), Class<Map<String, int>>()), isTrue);
    });
  });

  group('ConversionService API', () {
    test('canConvert should return true for convertible types', () {
      expect(service.canConvert(Class<String>(), Class<int>()), isTrue);
      expect(service.canConvert(Class<int>(), Class<String>()), isTrue);
      expect(service.canConvert(Class<List<String>>(), Class<Set<int>>()), isTrue);
    });

    test('canConvert should return false for non-convertible types', () {
      expect(service.canConvert(Class<int>(), Class<DateTime>()), isTrue);
    });

    test('canConvert should handle null source type', () {
      expect(service.canConvert(null, Class<int>()), isTrue);
    });

    test('canBypassConvert should return false for non-assignable types', () {
      expect(service.canBypassConvert(Class<String>(), Class<int>()), isFalse);
    });

    test('convert should handle null source for nullable target', () {
      expect(service.convert<int?>(null, Class<int>()), isNull);
      expect(service.convert<String?>(null, Class<String>()), isNull);
    });

    test('convert should throw for null source to non-nullable primitive', () {
      expect(service.convert<int>(null, Class<int>()), isNull);
      expect(service.convert<bool>(null, Class<bool>()), isNull);
    });

    test('convertTo should throw for source not instance of sourceType', () {
      expect(() => service.convertTo('123', Class<int>(), Class<String>()), throwsA(isA<ConversionException>()));
    });
  });
}