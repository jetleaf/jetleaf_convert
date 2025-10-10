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
import 'package:jetleaf_convert/src/helpers/_commons.dart';
import 'package:jetleaf_lang/lang.dart';
import 'package:test/test.dart';

import '_dependencies.dart';
import '_test_models.dart';

void main() async {
  late DefaultConversionService service;

  setUpAll(() async {
    await setupRuntime();
    service = DefaultConversionService();
    return Future<void>.value();
  });

  group('ConversionUtils', () {
    test('invokeConverter should wrap other exceptions in ConversionFailedException', () {
      final converter = _ThrowingConverter();
      expect(() => ConversionUtils.invoke(converter, 'data', Class.of<String>(), Class.of<int>()),
          throwsA(isA<ConversionFailedException>().having((e) => e.point, 'point', isA<StateError>())));
    });

    test('canConvertElements should return true for convertible elements', () {
      expect(ConversionUtils.canConvert(Class.of<String>(), Class.of<int>(), service), isTrue);
      expect(ConversionUtils.canConvert(Class.of<int>(), Class.of<num>(), service), isTrue);
    });

    test('canConvertElements should return false for non-convertible elements', () {
      expect(ConversionUtils.canConvert(Class.of<int>(), Class.of<DateTime>(), service), isFalse);
    });

    test('canConvertElements should handle null targetElementType', () {
      expect(ConversionUtils.canConvert(Class.of<String>(), null, service), isTrue);
    });

    test('canConvertElements should handle null sourceElementType', () {
      expect(ConversionUtils.canConvert(null, Class.of<String>(), service), isTrue);
    });

    test('getEnumType should return enum Class for enum type', () {
      final enumClass = ConversionUtils.getEnumType(Class.of<TestEnum>());
      expect(enumClass.getType(), TestEnum);
      expect(enumClass.isEnum(), isTrue);
    });

    test('getEnumType should throw for non-enum type', () {
      expect(() => ConversionUtils.getEnumType(Class.of<String>()), throwsA(isA<AssertionError>()));
      expect(() => ConversionUtils.getEnumType(Class.of<MyClass>()), throwsA(isA<AssertionError>()));
    });
  });
}

class _ThrowingConverter extends CommonPairedConverter {
  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {
    ConvertiblePair(Class.of<String>(), Class.of<int>()),
  };

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    throw StateError('Simulated conversion error');
  }
}