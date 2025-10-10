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
import 'package:test/test.dart';
import 'package:jetleaf_lang/lang.dart';
import 'dart:collection' as col;

import '../_dependencies.dart';

void main() {
  late DefaultConversionService service;

  setUpAll(() async {
    await setupRuntime();
    service = DefaultConversionService();
  });

  group('String to Map Converters', () {
    test('String to Map conversion - basic', () {
      final input = 'name=John,age=30,country=USA';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result, isA<Map>());
      expect(result?['name'], 'John');
      expect(result?['age'], '30');
      expect(result?['country'], 'USA');
    });

    test('String to HashMap conversion', () {
      final input = 'key1=value1,key2=value2';
      final result = service.convert<HashMap<Object, Object>>(input, Class.of<HashMap<Object, Object>>());
      
      expect(result, isA<HashMap<Object, Object>>());
      expect(result?['key1'], 'value1');
      expect(result?['key2'], 'value2');
    });

    test('String to col.HashMap conversion', () {
      final input = 'a=1,b=2,c=3';
      final result = service.convert<col.HashMap>(input, Class.of<col.HashMap>(null, PackageNames.DART));
      
      expect(result, isA<col.HashMap>());
      expect(result?['a'], '1');
      expect(result?['b'], '2');
      expect(result?['c'], '3');
    });

    test('String to Map with spaces', () {
      final input = ' name = John , age = 30 , country = USA ';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result?['name'], 'John');
      expect(result?['age'], '30');
      expect(result?['country'], 'USA');
    });

    test('String to Map with empty values', () {
      final input = 'key1=,key2=value2,key3=';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result?['key1'], '');
      expect(result?['key2'], 'value2');
      expect(result?['key3'], '');
    });

    test('String to Map with type conversion', () {
      final input = 'age=30,score=95.5,active=true';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result?['age'], '30');
      expect(result?['score'], '95.5');
      expect(result?['active'], 'true');
    });

    test('Empty string to Map conversion', () {
      final result = service.convert<Map>('', Class.of<Map>());
      expect(result, isEmpty);
    });

    test('Null input to Map conversion', () {
      final result = service.convert<Map>(null, Class.of<Map>());
      expect(result, isNull);
    });
  });

  group('Map to String Converters', () {
    test('Map to String conversion - basic', () {
      final input = {'name': 'John', 'age': 30, 'country': 'USA'};
      final result = service.convert<String>(input, Class.of<String>());
      
      expect(result, contains('name=John'));
      expect(result, contains('age=30'));
      expect(result, contains('country=USA'));
    });

    test('HashMap to String conversion', () {
      final input = HashMap();
      input.addAll({'key1': 'value1', 'key2': 'value2'});
      final result = service.convert<String>(input, Class.of<String>());
      
      expect(result, contains('key1=value1'));
      expect(result, contains('key2=value2'));
    });

    test('col.HashMap to String conversion', () {
      final input = col.HashMap.from({'a': 1, 'b': 2});
      final result = service.convert<String>(input, Class.of<String>());
      
      expect(result, contains('a=1'));
      expect(result, contains('b=2'));
    });

    test('Map to String with complex values', () {
      final input = {
        'list': [1, 2, 3],
        'nested': {'key': 'value'},
        'number': 42.5
      };
      final result = service.convert<String>(input, Class.of<String>());
      
      expect(result, contains('list=[1, 2, 3]'));
      expect(result, contains('number=42.5'));
    });

    test('Empty Map to String conversion', () {
      final result = service.convert<String>({}, Class.of<String>());
      expect(result, isEmpty);
    });

    test('Null input to String conversion', () {
      final result = service.convert<String>(null, Class.of<String>());
      expect(result, isNull);
    });
  });

  group('Map to Map Converters', () {
    test('Map to HashMap conversion', () {
      final input = {'key1': 'value1', 'key2': 'value2'};
      final result = service.convert<HashMap<Object, Object>>(input, Class.of<HashMap<Object, Object>>());
      
      expect(result, isA<HashMap<Object, Object>>());
      expect(result?['key1'], 'value1');
      expect(result?['key2'], 'value2');
    });

    test('HashMap to Map conversion', () {
      final input = HashMap();
      input.addAll({'a': 1, 'b': 2});
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result, isA<Map>());
      expect(result?['a'], 1);
      expect(result?['b'], 2);
    });

    test('Map to col.HashMap conversion', () {
      final input = {'x': 'hello', 'y': 'world'};
      final result = service.convert<col.HashMap>(input, Class.of<col.HashMap>());
      
      expect(result, isA<col.HashMap>());
      expect(result?['x'], 'hello');
      expect(result?['y'], 'world');
    });

    test('col.HashMap to HashMap conversion', () {
      final input = col.HashMap.from({'num': 42, 'text': 'test'});
      final result = service.convert<HashMap>(input, Class.of<HashMap>());
      
      expect(result, isA<HashMap>());
      expect(result?['num'], 42);
      expect(result?['text'], 'test');
    });

    test('Map to Map with type conversion', () {
      final input = {'age': '30', 'score': '95.5'};
      final result = service.convert<Map<String, num>>(input, Class.of<Map<String, num>>());
      
      expect(result?['age'], 30);
      expect(result?['score'], 95.5);
    });

    test('Map to Map with key type conversion', () {
      final input = {'1': 'one', '2': 'two'};
      final result = service.convert<Map<int, String>>(input, Class.of<Map<int, String>>());
      
      expect(result?[1], 'one');
      expect(result?[2], 'two');
    });

    test('Empty Map to Map conversion', () {
      final result = service.convert<HashMap>({}, Class.of<HashMap>());
      expect(result, isEmpty);
      expect(result, isA<HashMap>());
    });

    test('Null input to Map conversion', () {
      final result = service.convert<HashMap>(null, Class.of<HashMap>());
      expect(result, isNull);
    });
  });

  group('Integration Tests', () {
    test('String to Map to String round trip', () {
      final input = 'name=John,age=30';
      final mapResult = service.convert<Map>(input, Class.of<Map>());
      final stringResult = service.convert<String>(mapResult, Class.of<String>());
      
      expect(stringResult, contains('name=John'));
      expect(stringResult, contains('age=30'));
    });

    test('Map to String to Map round trip', () {
      final input = {'key1': 'value1', 'key2': 'value2'};
      final stringResult = service.convert<String>(input, Class.of<String>());
      final mapResult = service.convert<Map>(stringResult, Class.of<Map>());
      
      expect(mapResult?['key1'], 'value1');
      expect(mapResult?['key2'], 'value2');
    });

    test('Complex type conversion chain', () {
      // String -> Map -> HashMap -> String
      final input = 'number=42,flag=true';
      final step1 = service.convert<Map>(input, Class.of<Map>());
      final step2 = service.convert<HashMap>(step1, Class.of<HashMap>());
      final result = service.convert<String>(step2, Class.of<String>());
      
      expect(result, contains('number=42'));
      expect(result, contains('flag=true'));
    });

    test('Map with different value types conversion', () {
      final input = {
        'string': 'hello',
        'number': 42,
        'boolean': true,
        'list': [1, 2, 3]
      };
      final result = service.convert<String>(input, Class.of<String>());
      
      expect(result, contains('string=hello'));
      expect(result, contains('number=42'));
      expect(result, contains('boolean=true'));
      expect(result, contains('list=[1, 2, 3]'));
    });
  });

  group('Edge Cases', () {
    test('String with multiple equals signs', () {
      final input = 'key=value=extra,normal=test';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result?['key'], 'value=extra');
      expect(result?['normal'], 'test');
    });

    test('String with only keys', () {
      final input = 'key1,key2=value,key3';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result?['key1'], '');
      expect(result?['key2'], 'value');
      expect(result?['key3'], '');
    });

    test('String with special characters', () {
      final input = 'email=test@example.com,url=https://example.com,message=Hello%20World';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result?['email'], 'test@example.com');
      expect(result?['url'], 'https://example.com');
      expect(result?['message'], 'Hello%20World');
    });

    test('Map with null values', () {
      final input = {'key1': 'value1', 'key2': null, 'key3': 'value3'};
      final result = service.convert<String>(input, Class.of<String>());
      
      expect(result, contains('key1=value1'));
      expect(result, contains('key2=null'));
      expect(result, contains('key3=value3'));
    });

    test('Map with empty keys', () {
      final input = {'': 'empty', 'normal': 'value'};
      final result = service.convert<String>(input, Class.of<String>());
      
      expect(result, contains('=empty'));
      expect(result, contains('normal=value'));
    });

    test('Very long string to Map conversion', () {
      final longValue = 'a' * 1000;
      final input = 'key=$longValue';
      final result = service.convert<Map>(input, Class.of<Map>());
      
      expect(result?['key'], longValue);
    });
  });
}