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

  group('String Converters', () {
    group('String to Primitives', () {
      test('String to int', () {
        expect(service.convert<int>('123', Class.of<int>()), 123);
        expect(service.convert<int>('-456', Class.of<int>()), -456);
        expect(service.convert<int>('0', Class.of<int>()), 0);
        expect(() => service.convert<int>('abc', Class.of<int>()), 
            throwsA(isA<ConversionFailedException>()));
        expect(() => service.convert<int>('12.34', Class.of<int>()), 
            throwsA(isA<ConversionFailedException>()));
      });

      test('String to double', () {
        expect(service.convert<double>('123.45', Class.of<double>()), 123.45);
        expect(service.convert<double>('-67.89', Class.of<double>()), -67.89);
        expect(service.convert<double>('0.0', Class.of<double>()), 0.0);
        expect(service.convert<double>('123', Class.of<double>()), 123.0);
        expect(() => service.convert<double>('abc', Class.of<double>()), 
            throwsA(isA<ConversionFailedException>()));
      });

      test('String to bool', () {
        expect(service.convert<bool>('true', Class.of<bool>()), isTrue);
        expect(service.convert<bool>('TRUE', Class.of<bool>()), isTrue);
        expect(service.convert<bool>('false', Class.of<bool>()), isFalse);
        expect(service.convert<bool>('FALSE', Class.of<bool>()), isFalse);
        expect(service.convert<bool>('1', Class.of<bool>()), isTrue);
        expect(service.convert<bool>('0', Class.of<bool>()), isFalse);
        expect(() => service.convert<bool>('maybe', Class.of<bool>()), 
            throwsA(isA<ConversionFailedException>()));
      });

      test('String to num', () {
        expect(service.convert<num>('123', Class.of<num>()), 123);
        expect(service.convert<num>('123.45', Class.of<num>()), 123.45);
        expect(service.convert<num>('-67', Class.of<num>()), -67);
      });
    });

    group('Primitives to String', () {
      test('int to String', () {
        expect(service.convert<String>(123, Class.of<String>()), '123');
        expect(service.convert<String>(-456, Class.of<String>()), '-456');
        expect(service.convert<String>(0, Class.of<String>()), '0');
      });

      test('double to String', () {
        expect(service.convert<String>(123.45, Class.of<String>()), '123.45');
        expect(service.convert<String>(-67.89, Class.of<String>()), '-67.89');
        expect(service.convert<String>(0.0, Class.of<String>()), '0.0');
      });

      test('bool to String', () {
        expect(service.convert<String>(true, Class.of<String>()), 'true');
        expect(service.convert<String>(false, Class.of<String>()), 'false');
      });
    });
  });
}