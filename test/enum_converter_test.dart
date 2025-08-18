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

  group('Enum Converters', () {
    test('Enum to String', () {
      expect(service.convert<String>(TestEnum.value1, Class.of<String>()), 'value1');
      expect(service.convert<String>(TestEnum.value2, Class.of<String>()), 'value2');
    });

    test('Enum to int', () {
      expect(service.convert<int>(TestEnum.value1, Class.of<int>()), 0);
      expect(service.convert<int>(TestEnum.value2, Class.of<int>()), 1);
    });

    test('String to Enum (unsupported by current Class API)', () {
      expect(service.convert<TestEnum>('value1', Class.of<TestEnum>()), TestEnum.value1);
      expect(service.convert<TestEnum>('value2', Class.of<TestEnum>()), TestEnum.value2);
    });

    test('int to Enum (unsupported by current Class API)', () {
      expect(service.convert<TestEnum>(0, Class.of<TestEnum>()), TestEnum.value1);
      expect(service.convert<TestEnum>(1, Class.of<TestEnum>()), TestEnum.value2);
    });
  });
}