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

import '../_dependencies.dart';

void main() {
  late DefaultConversionService service;

  setUpAll(() async {
    await setupRuntime();
    service = DefaultConversionService();
    return Future<void>.value();
  });

  group('Numeric Converters', () {
    test('num to int', () {
      expect(service.convert<int>(10.5, Class.of<int>()), 10);
      expect(service.convert<int>(10.4, Class.of<int>()), 10);
      expect(service.convert<int>(10, Class.of<int>()), 10);
      expect(service.convert<int>(-10.5, Class.of<int>()), -10);
    });

    test('num to double', () {
      expect(service.convert<double>(10, Class.of<double>()), 10.0);
      expect(service.convert<double>(10.5, Class.of<double>()), 10.5);
    });

    test('int to double', () {
      expect(service.convert<double>(42, Class.of<double>()), 42.0);
    });

    test('double to int', () {
      expect(service.convert<int>(42.7, Class.of<int>()), 42);
      expect(service.convert<int>(42.3, Class.of<int>()), 42);
    });
  });
}