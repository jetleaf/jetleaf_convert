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

import 'dart:collection' as col;

import 'package:jetleaf_lang/lang.dart';

import '../conversion_service/conversion_service.dart';
import '../conversion_utils.dart';
import '../converter/converters.dart';
import '../convertible_pair.dart';


/// {@template string_to_map_generic_converter}
/// A converter that transforms a [String] into different types of [Map] implementations.
///
/// This class supports conversion from:
/// - `String` → `Map`
/// - `String` → `HashMap`
/// - `String` → `col.HashMap`
///
/// The expected string format is a comma-separated list of key-value pairs,
/// where each pair is separated by an equals sign (`=`).
///
/// Example:
/// ```dart
/// final service = ConversionService(); // Your implementation
/// final converter = StringToMapGenericConverter(service);
/// 
/// final input = "name=John, age=30, country=USA";
/// final result = converter.convert(
///   input,
///   Class.forType(String),
///   Class.forType(Map),
/// );
///
/// print(result); // {name: John, age: 30, country: USA}
/// ```
///
/// ### Key & Value Type Conversion
/// If the target map specifies key and value types, they will be converted
/// using the provided [ConversionService].
/// {@endtemplate}
class StringToMapGenericConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro string_to_map_generic_converter}
  StringToMapGenericConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(String), Class.forType(Map)),
      ConvertiblePair(Class.forType(String), Class.forType(HashMap)),
      ConvertiblePair(Class.forType(String), Class.forType(col.HashMap)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    return sourceType.getType() == String &&
        (targetType.getType() == Map ||
         targetType.getType() == HashMap ||
         targetType.getType() == col.HashMap);
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final str = source as String;
    final pairs = str.split(RegExp(r'\s*,\s*')); // split by comma
    final targetMap = _createTargetMap(targetType);

    final keyType = targetType.keyType();
    final valueType = targetType.componentType();

    for (final pair in pairs) {
      if (pair.trim().isEmpty) continue;
      final kv = pair.split('=');
      final rawKey = kv.isNotEmpty ? kv[0] : '';
      final rawValue = kv.length > 1 ? kv[1] : '';

      final key = (keyType != null)
          ? _conversionService.convertTo(rawKey, Class.forType(String), keyType)
          : rawKey;

      final value = (valueType != null)
          ? _conversionService.convertTo(rawValue, Class.forType(String), valueType)
          : rawValue;

      targetMap[key] = value;
    }

    return targetMap;
  }

  /// {@template string_to_map_create_target_map}
  /// Creates the appropriate map instance based on the given [targetType].
  ///
  /// - If `targetType` is `Map`, returns a standard `{}`.
  /// - If `targetType` is `HashMap`, returns a `HashMap()`.
  /// - If `targetType` is `col.HashMap`, returns a `col.HashMap()`.
  ///
  /// Example:
  /// ```dart
  /// final map = _createTargetMap(Class.forType(HashMap));
  /// print(map.runtimeType); // HashMap<dynamic, dynamic>
  /// ```
  /// {@endtemplate}
  Map _createTargetMap(Class targetType) {
    final dartType = targetType.getType();
    if (dartType == Map) return {};
    if (dartType == HashMap) return HashMap();
    if (dartType == col.HashMap) return col.HashMap();
    return {};
  }
}

/// {@template map_to_string_generic_converter}
/// A converter that transforms different types of [Map] into a [String].
///
/// This class supports conversion from:
/// - `Map` → `String`
/// - `HashMap` → `String`
/// - `col.HashMap` → `String`
///
/// The resulting string is a comma-separated list of key-value pairs
/// where each pair is joined by an equals sign (`=`).
///
/// Example:
/// ```dart
/// final service = ConversionService(); // Your implementation
/// final converter = MapToStringGenericConverter(service);
///
/// final input = {"name": "John", "age": 30, "country": "USA"};
/// final result = converter.convert(
///   input,
///   Class.forType(Map),
///   Class.forType(String),
/// );
///
/// print(result); // name=John, age=30, country=USA
/// ```
///
/// ### Key & Value Conversion
/// If the source map specifies key and value types, they will be converted
/// to `String` using the provided [ConversionService].
/// {@endtemplate}
class MapToStringGenericConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro map_to_string_generic_converter}
  MapToStringGenericConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Map), Class.forType(String)),
      ConvertiblePair(Class.forType(HashMap), Class.forType(String)),
      ConvertiblePair(Class.forType(col.HashMap), Class.forType(String)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    return (sourceType.getType() == Map ||
            sourceType.getType() == HashMap ||
            sourceType.getType() == col.HashMap) &&
           targetType.getType() == String;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final map = source as Map;
    final sourceKeyType = sourceType.keyType();
    final sourceValueType = sourceType.componentType();

    final parts = <String>[];
    map.forEach((key, value) {
      final keyStr = (sourceKeyType != null)
          ? _conversionService.convertTo(key, sourceKeyType, Class.forType(String))
          : key.toString();

      final valueStr = (sourceValueType != null)
          ? _conversionService.convertTo(value, sourceValueType, Class.forType(String))
          : value.toString();

      parts.add('$keyStr=$valueStr');
    });

    return parts.join(', ');
  }
}

/// {@template map_to_map_generic_converter}
/// A converter that transforms a [Map] (or any map-like type) into another
/// [Map] type, optionally converting keys and values.
///
/// This class supports conversions between:
/// - `Map`, `HashMap`, `col.HashMap` → Any of the above
///
/// ### Example
/// ```dart
/// final service = ConversionService(); // Your implementation
/// final converter = MapToMapGenericConverter(service);
///
/// final input = {"name": "John", "age": "30"};
/// final result = converter.convert(
///   input,
///   Class.forType(Map),
///   Class.forType(HashMap),
/// );
///
/// print(result.runtimeType); // HashMap<dynamic, dynamic>
/// ```
///
/// ### Key & Value Conversion
/// If the source and target maps specify types for keys and values,
/// this converter will use the [ConversionService] to transform them.
/// {@endtemplate}
class MapToMapGenericConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro map_to_map_generic_converter}
  MapToMapGenericConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Map), Class.forType(Map)),
      ConvertiblePair(Class.forType(Map), Class.forType(HashMap)),
      ConvertiblePair(Class.forType(Map), Class.forType(col.HashMap)),
      ConvertiblePair(Class.forType(HashMap), Class.forType(Map)),
      ConvertiblePair(Class.forType(HashMap), Class.forType(HashMap)),
      ConvertiblePair(Class.forType(HashMap), Class.forType(col.HashMap)),
      ConvertiblePair(Class.forType(col.HashMap), Class.forType(Map)),
      ConvertiblePair(Class.forType(col.HashMap), Class.forType(HashMap)),
      ConvertiblePair(Class.forType(col.HashMap), Class.forType(col.HashMap)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    if (!_isMapLike(sourceType) || !_isMapLike(targetType)) {
      return false;
    }

    final sourceKeyType = sourceType.keyType();
    final sourceValueType = sourceType.componentType();
    final targetKeyType = targetType.keyType();
    final targetValueType = targetType.componentType();
    
    if (sourceKeyType == null || sourceValueType == null || targetKeyType == null || targetValueType == null) {
      return true;
    }
    
    return ConversionUtils.canConvertElements(sourceKeyType, targetKeyType, _conversionService) 
      && ConversionUtils.canConvertElements(sourceValueType, targetValueType, _conversionService);
  }

  bool _isMapLike(Class type) {
    final t = type.getType();
    return t == Map || t == HashMap || t == col.HashMap;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final sourceMap = source as Map;
    final targetMap = _createTargetMap(targetType);

    final keyType = targetType.keyType();
    final valueType = targetType.componentType();
    final sourceKeyType = sourceType.keyType();
    final sourceValueType = sourceType.componentType();

    sourceMap.forEach((k, v) {
      final newKey = (keyType != null && sourceKeyType != null)
          ? _conversionService.convertTo(k, sourceKeyType, keyType)
          : k;

      final newValue = (valueType != null && sourceValueType != null)
          ? _conversionService.convertTo(v, sourceValueType, valueType)
          : v;

      targetMap[newKey] = newValue;
    });

    return targetMap;
  }

  /// {@macro string_to_map_create_target_map}
  Map _createTargetMap(Class targetType) {
    final dartType = targetType.getType();
    if (dartType == Map) return {};
    if (dartType == HashMap) return HashMap();
    if (dartType == col.HashMap) return col.HashMap();
    return {};
  }
}