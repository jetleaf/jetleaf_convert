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

  group('DateTime Converters', () {
    test('DateTime to String', () {
      final now = DateTime(2025, 8, 15, 10, 30, 45);
      final result = service.convert<String>(now, Class.of<String>());
      expect(result, contains('2025'));
      expect(result, contains('08'));
      expect(result, contains('15'));
    });

    test('String to DateTime', () {
      final isoString = '2025-01-01T10:30:00.000Z';
      final result = service.convert<DateTime>(isoString, Class.of<DateTime>());
      expect(result?.year, 2025);
      expect(result?.month, 1);
      expect(result?.day, 1);
      expect(() => service.convert<DateTime>('invalid-date', Class.of<DateTime>()), 
          throwsA(isA<ConversionFailedException>()));
    });

    test('DateTime to epoch milliseconds', () {
      final dateTime = DateTime.utc(2025, 1, 1);
      final epochMs = service.convert<int>(dateTime, Class.of<int>());
      expect(epochMs, dateTime.millisecondsSinceEpoch);
    });

    test('Epoch milliseconds to DateTime', () {
      final epochMs = DateTime.utc(2025, 1, 1).millisecondsSinceEpoch;
      final result = service.convert<DateTime>(epochMs, Class.of<DateTime>());
      expect(result?.year, 2025);
      expect(result?.month, 1);
      expect(result?.day, 1);
    });
  });

  group('Duration Converters', () {
    test('Duration to String', () {
      final duration = Duration(hours: 1, minutes: 30, seconds: 15);
      final result = service.convert<String>(duration, Class.of<String>());
      expect(result, isNotEmpty);
    });

    test('String to Duration', () {
      expect(service.convert<Duration>('1:30:15', Class.of<Duration>()), 
          Duration(hours: 1, minutes: 30, seconds: 15));
      expect(() => service.convert<Duration>('invalid', Class.of<Duration>()), 
          throwsA(isA<ConversionFailedException>()));
    });

    test('Duration to milliseconds', () {
      final duration = Duration(seconds: 5);
      expect(service.convert<int>(duration, Class.of<int>()), 5000);
    });

    test('Milliseconds to Duration', () {
      expect(service.convert<Duration>(5000, Class.of<Duration>()), Duration(seconds: 5));
    });
  });
}