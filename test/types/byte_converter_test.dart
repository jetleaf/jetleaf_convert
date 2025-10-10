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

import 'dart:typed_data';

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

  group('ByteMultiConverter', () {
    test('Byte to String', () {
      final byte = Byte.fromString('Hello');
      final result = service.convert<String>(byte, Class.of<String>());
      expect(result, 'Hello');
    });

    test('String to Byte', () {
      final result = service.convert<Byte>('Hello', Class.of<Byte>());
      expect(result.toString(), 'Hello');
    });

    test('Byte to List<int>', () {
      final byte = Byte.fromString('A'); // ASCII = 65
      final result = service.convert<List<int>>(byte, Class.of<List<int>>());
      expect(result, [65]);
    });

    test('List<int> to Byte (single element)', () {
      final source = [65];
      final result = service.convert<Byte>(source, Class.of<Byte>());
      expect(result.toString(), 'A');
    });

    test('Byte to Uint8List', () {
      final byte = Byte.fromString('B'); // ASCII = 66
      final result = service.convert<Uint8List>(byte, Class.of<Uint8List>());
      expect(result, Uint8List.fromList([66]));
    });

    test('Uint8List to Byte', () {
      final source = Uint8List.fromList([67]); // ASCII = 'C'
      final result = service.convert<Byte>(source, Class.of<Byte>());
      expect(result.toString(), 'C');
    });
  });
}