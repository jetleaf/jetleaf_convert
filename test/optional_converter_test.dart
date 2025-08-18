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

void main() {
  late DefaultConversionService service;

  setUpAll(() async {
    await setupRuntime();
    service = DefaultConversionService();
    return Future<void>.value();
  });

  group('Optional Converters', () {
    test('Object to Optional', () {
      final source = 'test';
      Optional<Object>? result = service.convert(source, Class.of<Optional<String>>());
      expect(result?.isPresent(), isTrue);
      expect(result?.get() is String, isTrue);
      expect(result?.get(), 'test');
    });

    test('null to Optional', () {
      final result = service.convert(null, Class.of<Optional<String>>());
      expect(result?.isEmpty(), isTrue);
    });

    test('Optional to Object', () {
      final source = Optional.of('test');
      final result = service.convertWithClass(source, Class.of<String>());
      expect(result, 'test');
    });

    test('Empty Optional to Object should return null', () {
      final source = Optional.empty<String>();
      final result = service.convertWithClass(source, Class.of<String>());
      expect(result, isNull);
    });

    test('List to Optional (single element)', () {
      final source = ['test'];
      final result = service.convert(source, Class.of<Optional<String>>());
      expect(result?.isPresent(), isTrue);
      expect(result?.get(), 'test');
    });

    test('Empty list to Optional', () {
      final source = <String>[];
      final result = service.convert(source, Class.of<Optional<String>>());
      expect(result?.isEmpty(), isTrue);
    });
  });
}