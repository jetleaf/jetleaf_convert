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

  group('Byte Converters', () {
    test('Byte to String', () {
      final byte = Byte(65);
      expect(service.convert<String>(byte, Class.of<String>()), '65');
    });

    test('String to Byte', () {
      final result = service.convert<Byte>('65', Class.of<Byte>());
      expect(result?.value, 65);
    });

    test('Byte to int', () {
      final byte = Byte(42);
      expect(service.convert<int>(byte, Class.of<int>()), 42);
    });

    test('int to Byte', () {
      final result = service.convert<Byte>(42, Class.of<Byte>());
      expect(result?.value, 42);
    });

    test('Byte to List<int>', () {
      final byte = Byte(255);
      final result = service.convertWithClass(byte, Class.of<List<int>>());
      expect(result, [255]);
    });

    test('List<int> to Byte (single element)', () {
      final source = [128];
      final result = service.convertWithClass(source, Class.of<Byte>());
      expect(result is Byte, isTrue);
      expect((result as Byte).value, 128);
    });
  });
}