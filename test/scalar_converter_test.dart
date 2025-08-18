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

  group('Scalar Converters', () {
    test('String to int', () {
      expect(service.convert<int>('123', Class.of<int>()), 123);
      expect(() => service.convert<int>('abc', Class.of<int>()), throwsA(isA<ConversionFailedException>()));
    });

    test('int to String', () {
      expect(service.convert<String>(123, Class.of<String>()), '123');
    });

    test('String to double', () {
      expect(service.convert<double>('123.45', Class.of<double>()), 123.45);
      expect(() => service.convert<double>('abc', Class.of<double>()), throwsA(isA<ConversionFailedException>()));
    });

    test('double to String', () {
      expect(service.convert<String>(123.45, Class.of<String>()), '123.45');
    });

    test('String to bool', () {
      expect(service.convert<bool>('true', Class.of<bool>()), isTrue);
      expect(service.convert<bool>('FALSE', Class.of<bool>()), isFalse);
      expect(service.convert<bool>('1', Class.of<bool>()), isTrue);
      expect(service.convert<bool>('0', Class.of<bool>()), isFalse);
      expect(() => service.convert<bool>('maybe', Class.of<bool>()), throwsA(isA<ConversionFailedException>()));
    });

    test('bool to String', () {
      expect(service.convert<String>(true, Class.of<String>()), 'true');
      expect(service.convert<String>(false, Class.of<String>()), 'false');
    });

    test('DateTime to String', () {
      final now = DateTime.now();
      expect(service.convert<String>(now, Class.of<String>()), now.toIso8601String());
    });

    test('String to DateTime', () {
      final isoString = '2025-01-01T10:30:00.000Z';
      expect(service.convert<DateTime>(isoString, Class.of<DateTime>()), DateTime.parse(isoString));
      expect(() => service.convert<DateTime>('invalid-date', Class.of<DateTime>()), throwsA(isA<ConversionFailedException>()));
    });

    test('Duration to String', () {
      final duration = Duration(hours: 1, minutes: 30, seconds: 15);
      expect(service.convert<String>(duration, Class.of<String>()), "1:30:15");
    });

    test('String to Duration', () {
      expect(service.convert<Duration>('1:30:15', Class.of<Duration>()), Duration(hours: 1, minutes: 30, seconds: 15));
      expect(() => service.convert<Duration>('invalid', Class.of<Duration>()), throwsA(isA<ConversionFailedException>()));
    });

    test('String to Uri', () {
      final uriString = 'https://example.com/path?query=1';
      expect(service.convert<Uri>(uriString, Class.of<Uri>()), Uri.parse(uriString));
    });

    test('Uri to String', () {
      final uri = Uri.parse('https://example.com');
      expect(service.convert<String>(uri, Class.of<String>()), uri.toString());
    });

    test('String to RegExp', () {
      final pattern = r'^\d+$';
      expect(service.convert<RegExp>(pattern, Class.of<RegExp>())?.pattern, pattern);
      expect(() => service.convert<RegExp>('[', Class.of<RegExp>()), throwsA(isA<ConversionFailedException>()));
    });

    test('RegExp to String', () {
      final regex = RegExp(r'abc');
      expect(service.convert<String>(regex, Class.of<String>()), regex.pattern);
    });

    test('num to int', () {
      expect(service.convert<int>(10.5, Class.of<int>()), 10);
      expect(service.convert<int>(10, Class.of<int>()), 10);
    });

    test('num to double', () {
      expect(service.convert<double>(10, Class.of<double>()), 10.0);
      expect(service.convert<double>(10.5, Class.of<double>()), 10.5);
    });
  });
}