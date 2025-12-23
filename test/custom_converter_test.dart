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
  late DefaultConversionService service;

  setUpAll(() async {
    await setupRuntime();
    service = DefaultConversionService();
    return Future<void>.value();
  });

  group('ConverterRegistry and Custom Converters', () {
    test('addConverter should register a custom Converter', () {
      service.addConverter(CustomConverter());
      expect(service.canConvert(Class<String>(), Class<int>()), isTrue); // Default String to int is still there
      expect(service.convert<int>('10', Class<int>()), 20); // Default converter takes precedence or is chosen
    });

    test('addConverterWithClass should register a custom Converter with specific types', () {
      service.addConverter(sourceType: Class<String>(), targetType: Class<int>(), CustomConverter());
      expect(service.canConvert(Class<String>(), Class<int>()), isTrue);
      expect(service.convert<int>('10', Class<int>()), 20); // CustomConverter should now be used
    });

    test('addGenericConverter should register a custom GenericConverter', () {
      service.addPairedConverter(CustomGenericConverter());
      expect(service.canConvert(Class<String>(), Class<bool>()), isTrue);
      expect(service.convert<bool>('yes', Class<bool>()), isTrue);
      expect(service.convert<bool>('no', Class<bool>()), isFalse);
    });

    test('addConverterFactory should register a custom ConverterFactory', () {
      service.addConverterFactory(CustomConverterFactory());
      expect(service.canConvert(Class<String>(), Class<int>()), isTrue);
      expect(service.canConvert(Class<String>(), Class<double>()), isTrue);
      expect(service.convert<int>('100', Class<int>()), 200);
      expect(service.convert<double>('100.5', Class<double>()), 100.5);
    });

    test('removeConvertible should remove a registered converter', () {
      service.addConverter(sourceType: Class<String>(), targetType: Class<int>(), CustomConverter());
      expect(service.convert<int>('5', Class<int>()), 10); // Custom converter is active

      service.remove(Class<String>(), Class<int>());
      // After removal, it should fall back to default or no converter
      expect(service.convert<int>('5', Class<int>()), 5); // Should revert to default
    });

    test('convertTo should throw for no converter found', () {
      expect(() => service.convertTo(MyClass('test', 1), Class<MyClass>(), Class<DateTime>()), throwsA(isA<ConverterNotFoundException>()));
    });
  });

  group('Fallback Converters', () {
    test('Object to Object (via constructor)', () {
      final sourceMap = {'name': 'Alice', 'age': 30};
      final targetType = Class<MyClass>();
      final result = service.convertTo(sourceMap, targetType);
      expect(result, MyClass('Alice', 30));
    });

    test('Object to String (using toString())', () {
      final source = MyClass('Bob', 25);
      expect(service.convert<String>(source, Class<String>()), 'MyClass(name: Bob, age: 25)');
    });
  });
}