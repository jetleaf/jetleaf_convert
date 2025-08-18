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
import 'dart:convert';

import 'package:jetleaf_lang/lang.dart';

import '../convertible_pair.dart';
import '../exceptions.dart';
import '../conversion_service/conversion_service.dart';
import '../converter/converter_factory.dart';
import '../converter/converters.dart';

// ======================================== PRIMITIVE CONVERTERS ==========================================

/// {@template number_generic_converter}
/// A converter that transforms a [num] to a specific numeric subtype.
///
/// Supported conversions:
/// - `num` → `int`
/// - `num` → `double`
/// - `num` → `num` (identity)
/// - `num` → `String`
/// - `num` → `Integer`
/// - `num` → `Long`
/// - `num` → `Float`
/// - `num` → `BigInteger`
/// - `num` → `BigDecimal`
/// - `num` → `Character`
/// - `num` → `Short`
/// - `num` → `Double`
/// - `num` → `Boolean`
/// - `num` → `BigInt`
/// - `num` → `bool`
///
/// Example:
/// ```dart
/// final converter = NumberGenericConverter();
/// print(converter.convert(3.7)); // prints: 3
/// ```
/// {@endtemplate}
class NumberGenericConverter implements ConditionalGenericConverter {
  /// {@macro number_generic_converter}
  NumberGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(num), Class.forType(num)),
      ConvertiblePair(Class.forType(num), Class.forType(int)),
      ConvertiblePair(Class.forType(num), Class.forType(double)),
      ConvertiblePair(Class.forType(num), Class.forType(String)),
      ConvertiblePair(Class.forType(num), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(num), Class.forType(Integer)),
      ConvertiblePair(Class.forType(num), Class.forType(Long)),
      ConvertiblePair(Class.forType(num), Class.forType(Float)),
      ConvertiblePair(Class.forType(num), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(num), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(num), Class.forType(Short)),
      ConvertiblePair(Class.forType(num), Class.forType(Double)),
      ConvertiblePair(Class.forType(num), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(num), Class.forType(Character)),
      ConvertiblePair(Class.forType(num), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == num && (
    targetType.getType() == int ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == double ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final sourceNum = source as num;

    try {
      return switch(targetType.getType()) {
        const (int) => sourceNum.round(),
        const (double) => sourceNum.toDouble(),
        const (String) => sourceNum.toString(),
        const (Integer) => Integer.valueOf(sourceNum.toInt()),
        const (Long) => Long.valueOf(sourceNum.toInt()),
        const (Float) => Float.valueOf(sourceNum.toDouble()),
        const (BigInteger) => BigInteger.fromInt(sourceNum.toInt()),
        const (BigDecimal) => BigDecimal.fromInt(sourceNum.toInt()),
        const (Character) => Character.valueOf(sourceNum.toString()),
        const (Short) => Short.valueOf(sourceNum.toInt()),
        const (Double) => Double.valueOf(sourceNum.toDouble()),
        const (Boolean) => Boolean.valueOf(sourceNum.toInt() != 0),
        const (BigInt) => BigInt.from(sourceNum.toInt()),
        const (bool) => sourceNum.toInt() != 0,
        _ => sourceNum,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// =========================================== INT GENERIC CONVERTER =========================================

/// {@template int_generic_converter}
/// A converter that transforms an [int] to a specific numeric subtype.
///
/// Supported conversions:
/// - `int` → `int` (identity)
/// - `int` → `double`
/// - `int` → `num`
/// - `int` → `String`
/// - `int` → `Integer`
/// - `int` → `Long`
/// - `int` → `Float`
/// - `int` → `BigInteger`
/// - `int` → `BigDecimal`
/// - `int` → `Character`
/// - `int` → `Short`
/// - `int` → `Double`
/// - `int` → `Boolean`
/// - `int` → `BigInt`
/// - `int` → `bool`
///
/// Example:
/// ```dart
/// final converter = IntGenericConverter();
/// print(converter.convert(3)); // prints: 3
/// ```
/// {@endtemplate}
class IntGenericConverter implements ConditionalGenericConverter {
  /// {@macro int_generic_converter}
  IntGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(int), Class.forType(int)),
      ConvertiblePair(Class.forType(int), Class.forType(double)),
      ConvertiblePair(Class.forType(int), Class.forType(num)),
      ConvertiblePair(Class.forType(int), Class.forType(String)),
      ConvertiblePair(Class.forType(int), Class.forType(Integer)),
      ConvertiblePair(Class.forType(int), Class.forType(Long)),
      ConvertiblePair(Class.forType(int), Class.forType(Float)),
      ConvertiblePair(Class.forType(int), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(int), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(int), Class.forType(Character)),
      ConvertiblePair(Class.forType(int), Class.forType(Short)),
      ConvertiblePair(Class.forType(int), Class.forType(Double)),
      ConvertiblePair(Class.forType(int), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(int), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(int), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == int && (
    targetType.getType() == num ||
    targetType.getType() == int ||
    targetType.getType() == String ||
    targetType.getType() == double ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final sourceNum = source as int;

    try {
      return switch(targetType.getType()) {
        const (num) => sourceNum,
        const (double) => sourceNum.toDouble(),
        const (String) => sourceNum.toString(),
        const (Integer) => Integer.valueOf(sourceNum),
        const (Long) => Long.valueOf(sourceNum),
        const (Float) => Float.valueOf(sourceNum.toDouble()),
        const (BigInteger) => BigInteger.fromInt(sourceNum),
        const (BigDecimal) => BigDecimal.fromInt(sourceNum),
        const (Character) => Character.valueOf(sourceNum.toString()),
        const (Short) => Short.valueOf(sourceNum),
        const (Double) => Double.valueOf(sourceNum.toDouble()),
        const (Boolean) => Boolean.valueOf(sourceNum != 0),
        const (BigInt) => BigInt.from(sourceNum),
        const (bool) => sourceNum != 0,
        _ => sourceNum,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= DOUBLE GENERIC CONVERTER =========================================

/// {@template double_generic_converter}
/// A converter that transforms a [double] to a specific numeric subtype.
///
/// Supported conversions:
/// - `double` → `double` (identity)
/// - `double` → `int`
/// - `double` → `num`
/// - `double` → `String`
/// - `double` → `Integer`
/// - `double` → `Long`
/// - `double` → `Float`
/// - `double` → `BigInteger`
/// - `double` → `BigDecimal`
/// - `double` → `Character`
/// - `double` → `Short`
/// - `double` → `Double`
/// - `double` → `Boolean`
/// - `double` → `BigInt`
/// - `double` → `bool`
///
/// Example:
/// ```dart
/// final converter = DoubleGenericConverter();
/// print(converter.convert(3.7)); // prints: 3.7
/// ```
/// {@endtemplate}
class DoubleGenericConverter implements ConditionalGenericConverter {
  /// {@macro double_generic_converter}
  DoubleGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(double), Class.forType(double)),
      ConvertiblePair(Class.forType(double), Class.forType(int)),
      ConvertiblePair(Class.forType(double), Class.forType(num)),
      ConvertiblePair(Class.forType(double), Class.forType(String)),
      ConvertiblePair(Class.forType(double), Class.forType(Integer)),
      ConvertiblePair(Class.forType(double), Class.forType(Long)),
      ConvertiblePair(Class.forType(double), Class.forType(Float)),
      ConvertiblePair(Class.forType(double), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(double), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(double), Class.forType(Character)),
      ConvertiblePair(Class.forType(double), Class.forType(Short)),
      ConvertiblePair(Class.forType(double), Class.forType(Double)),
      ConvertiblePair(Class.forType(double), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(double), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(double), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == double && (
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == int ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == double ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final sourceNum = source as double;

    try {
      return switch(targetType.getType()) {
        const (num) => sourceNum.toInt(),
        const (int) => sourceNum.toInt(),
        const (String) => sourceNum.toString(),
        const (Integer) => Integer.valueOf(sourceNum.toInt()),
        const (Long) => Long.valueOf(sourceNum.toInt()),
        const (Float) => Float.valueOf(sourceNum),
        const (BigInteger) => BigInteger.fromInt(sourceNum.toInt()),
        const (BigDecimal) => BigDecimal.fromInt(sourceNum.toInt()),
        const (Character) => Character.valueOf(sourceNum.toString()),
        const (Short) => Short.valueOf(sourceNum.toInt()),
        const (Double) => Double.valueOf(sourceNum),
        const (Boolean) => Boolean.valueOf(sourceNum.toInt() != 0),
        const (BigInt) => BigInt.from(sourceNum.toInt()),
        const (bool) => sourceNum.toInt() != 0,
        _ => sourceNum,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

/// {@template string_generic_converter}
/// A converter that transforms a [String] to a specific numeric subtype.
///
/// Supported conversions:
/// - `String` → `String` (identity)
/// - `String` → `int`
/// - `String` → `double`
/// - `String` → `num`
/// - `String` → `Integer`
/// - `String` → `Long`
/// - `String` → `Float`
/// - `String` → `BigInteger`
/// - `String` → `BigDecimal`
/// - `String` → `Character`
/// - `String` → `Short`
/// - `String` → `Double`
/// - `String` → `Boolean`
/// - `String` → `BigInt`
/// - `String` → `bool`
///
/// Example:
/// ```dart
/// final converter = StringGenericConverter();
/// print(converter.convert('3.7')); // prints: 3.7
/// ```
/// {@endtemplate}
class StringGenericConverter implements ConditionalGenericConverter {
  /// {@macro string_generic_converter}
  StringGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(String), Class.forType(String)),
      ConvertiblePair(Class.forType(String), Class.forType(int)),
      ConvertiblePair(Class.forType(String), Class.forType(double)),
      ConvertiblePair(Class.forType(String), Class.forType(num)),
      ConvertiblePair(Class.forType(String), Class.forType(Integer)),
      ConvertiblePair(Class.forType(String), Class.forType(Long)),
      ConvertiblePair(Class.forType(String), Class.forType(Float)),
      ConvertiblePair(Class.forType(String), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(String), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(String), Class.forType(Short)),
      ConvertiblePair(Class.forType(String), Class.forType(Double)),
      ConvertiblePair(Class.forType(String), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(String), Class.forType(Character)),
      ConvertiblePair(Class.forType(String), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(String), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == String && (
    targetType.getType() == int ||
    targetType.getType() == num ||
    targetType.getType() == double ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == String ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final sourceString = source as String;

    Map<String, bool> booleanMapping = {
      "TRUE": true,
      "FALSE": false,
      "1": true,
      "0": false
    };

    bool toBool() {
      final result = booleanMapping[sourceString.toUpperCase()];
      if(result != null) {
        return result;
      } else {
        throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source);
      }
    }

    try {
      return switch(targetType.getType()) {
        const (int) => int.parse(sourceString),
        const (double) => double.parse(sourceString),
        const (num) => num.parse(sourceString),
        const (Integer) => Integer.valueOfString(sourceString),
        const (Long) => Long.valueOfString(sourceString),
        const (Float) => Float.valueOfString(sourceString),
        const (BigInteger) => BigInteger.fromInt(int.parse(sourceString)),
        const (BigDecimal) => BigDecimal.fromInt(int.parse(sourceString)),
        const (Character) => Character.valueOf(sourceString.toString()),
        const (Short) => Short.parseShort(sourceString),
        const (Double) => Double.valueOf(sourceString.toDouble()),
        const (Boolean) => Boolean.valueOf(sourceString.toInt() != 0),
        const (BigInt) => BigInt.from(int.parse(sourceString)),
        const (bool) => toBool(),
        _ => sourceString,
      };
    } on ConversionFailedException catch (_) {
      rethrow;
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= BOOL GENERIC CONVERTER =========================================

/// {@template bool_generic_converter}
/// A converter that transforms a [bool] to a specific numeric subtype.
///
/// Supported conversions:
/// - `bool` → `bool` (identity)
/// - `bool` → `double`
/// - `bool` → `num`
/// - `bool` → `String`
/// - `bool` → `Integer`
/// - `bool` → `Long`
/// - `bool` → `Float`
/// - `bool` → `BigInteger`
/// - `bool` → `BigDecimal`
/// - `bool` → `Character`
/// - `bool` → `Short`
/// - `bool` → `Double`
/// - `bool` → `Boolean`
/// - `bool` → `BigInt`
/// - `bool` → `int`
///
/// Example:
/// ```dart
/// final converter = BoolGenericConverter();
/// print(converter.convert(true)); // prints: true
/// ```
/// {@endtemplate}
class BoolGenericConverter implements ConditionalGenericConverter {
  /// {@macro bool_generic_converter}
  BoolGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(bool), Class.forType(bool)),
      ConvertiblePair(Class.forType(bool), Class.forType(double)),
      ConvertiblePair(Class.forType(bool), Class.forType(num)),
      ConvertiblePair(Class.forType(bool), Class.forType(String)),
      ConvertiblePair(Class.forType(bool), Class.forType(Integer)),
      ConvertiblePair(Class.forType(bool), Class.forType(Long)),
      ConvertiblePair(Class.forType(bool), Class.forType(Float)),
      ConvertiblePair(Class.forType(bool), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(bool), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(bool), Class.forType(Character)),
      ConvertiblePair(Class.forType(bool), Class.forType(Short)),
      ConvertiblePair(Class.forType(bool), Class.forType(Double)),
      ConvertiblePair(Class.forType(bool), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(bool), Class.forType(BigInt)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == bool && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final boolValue = (source as bool);

    try {
      return switch (targetType.getType()) {
        const (int) => boolValue ? 1 : 0,
        const (double) => boolValue ? 1.0 : 0.0,
        const (num) => boolValue ? 1 : 0,
        const (String) => boolValue.toString(),
        const (Integer) => Integer.valueOf(boolValue ? 1 : 0),
        const (Long) => Long.valueOf(boolValue ? 1 : 0),
        const (Float) => Float.valueOf(boolValue ? 1.0 : 0.0),
        const (BigInteger) => BigInteger.fromInt(boolValue ? 1 : 0),
        const (BigDecimal) => BigDecimal.fromInt(boolValue ? 1 : 0),
        const (Character) => Character.valueOf(boolValue ? '1' : '0'),
        const (Short) => Short.valueOf(boolValue ? 1 : 0),
        const (Double) => Double.valueOf(boolValue ? 1.0 : 0.0),
        const (Boolean) => Boolean.valueOf(boolValue),
        const (BigInt) => BigInt.from(boolValue ? 1 : 0),
        const (bool) => boolValue,
        _ => boolValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= BIGINT GENERIC CONVERTER =========================================

/// {@template bigint_generic_converter}
/// A converter that transforms a [BigInt] to a specific numeric subtype.
///
/// Supported conversions:
/// - `BigInt` → `BigInt` (identity)
/// - `BigInt` → `int`
/// - `BigInt` → `double`
/// - `BigInt` → `num`
/// - `BigInt` → `String`
/// - `BigInt` → `Integer`
/// - `BigInt` → `Long`
/// - `BigInt` → `Float`
/// - `BigInt` → `BigInteger`
/// - `BigInt` → `BigDecimal`
/// - `BigInt` → `Character`
/// - `BigInt` → `Short`
/// - `BigInt` → `Double`
/// - `BigInt` → `Boolean`
/// - `BigInt` → `bool`
///
/// Example:
/// ```dart
/// final converter = BigIntGenericConverter();
/// print(converter.convert(BigInt.from(3)))); // prints: 3
/// ```
/// {@endtemplate}
class BigIntGenericConverter implements ConditionalGenericConverter {
  /// {@macro bigint_generic_converter}
  BigIntGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(BigInt), Class.forType(int)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(double)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(num)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(String)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(Integer)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(Long)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(Float)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(Character)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(Short)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(Double)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(BigInt), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == BigInt && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final bigIntValue = source as BigInt;

    try {
      return switch (targetType.getType()) {
        const (int) => bigIntValue.toInt(),
        const (double) => bigIntValue.toDouble(),
        const (num) => bigIntValue.toInt(),
        const (String) => bigIntValue.toString(),
        const (Integer) => Integer.valueOf(bigIntValue.toInt()),
        const (Long) => Long.valueOf(bigIntValue.toInt()),
        const (Float) => Float.valueOf(bigIntValue.toDouble()),
        const (BigInteger) => BigInteger.fromInt(bigIntValue.toInt()),
        const (BigDecimal) => BigDecimal.fromInt(bigIntValue.toInt()),
        const (Character) => Character.valueOf(bigIntValue.toString()),
        const (Short) => Short.valueOf(bigIntValue.toInt()),
        const (Double) => Double.valueOf(bigIntValue.toDouble()),
        const (Boolean) => Boolean.valueOf(bigIntValue.toInt() != 0),
        const (BigInt) => bigIntValue,
        const (bool) => bigIntValue.toInt() != 0,
        _ => bigIntValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= INTEGER GENERIC CONVERTER =========================================

/// {@template integer_generic_converter}
/// A converter that transforms a [Integer] to a specific numeric subtype.
///
/// Supported conversions:
/// - `Integer` → `Integer` (identity)
/// - `Integer` → `int`
/// - `Integer` → `double`
/// - `Integer` → `num`
/// - `Integer` → `String`
/// - `Integer` → `Integer`
/// - `Integer` → `Long`
/// - `Integer` → `Float`
/// - `Integer` → `BigInteger`
/// - `Integer` → `BigDecimal`
/// - `Integer` → `Character`
/// - `Integer` → `Short`
/// - `Integer` → `Double`
/// - `Integer` → `Boolean`
/// - `Integer` → `BigInt`
/// - `Integer` → `bool`
///
/// Example:
/// ```dart
/// final converter = IntegerGenericConverter();
/// print(converter.convert(Integer.valueOf(3)))); // prints: 3
/// ```
/// {@endtemplate}
class IntegerGenericConverter implements ConditionalGenericConverter {
  /// {@macro integer_generic_converter}
  IntegerGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Integer), Class.forType(int)),
      ConvertiblePair(Class.forType(Integer), Class.forType(double)),
      ConvertiblePair(Class.forType(Integer), Class.forType(num)),
      ConvertiblePair(Class.forType(Integer), Class.forType(String)),
      ConvertiblePair(Class.forType(Integer), Class.forType(Integer)),
      ConvertiblePair(Class.forType(Integer), Class.forType(Long)),
      ConvertiblePair(Class.forType(Integer), Class.forType(Float)),
      ConvertiblePair(Class.forType(Integer), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(Integer), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(Integer), Class.forType(Character)),
      ConvertiblePair(Class.forType(Integer), Class.forType(Short)),
      ConvertiblePair(Class.forType(Integer), Class.forType(Double)),
      ConvertiblePair(Class.forType(Integer), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(Integer), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(Integer), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == Integer && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final intValue = source as Integer;

    try {
      return switch (targetType.getType()) {
        const (int) => intValue.value,
        const (double) => intValue.toDouble(),
        const (num) => intValue.value,
        const (String) => intValue.toString(),
        const (Long) => Long.valueOf(intValue.value),
        const (Float) => Float.valueOf(intValue.toDouble()),
        const (BigInteger) => BigInteger.fromInt(intValue.value),
        const (BigDecimal) => BigDecimal.fromInt(intValue.value),
        const (Character) => Character.valueOf(intValue.toString()),
        const (Short) => Short.valueOf(intValue.value),
        const (Double) => Double.valueOf(intValue.toDouble()),
        const (Boolean) => Boolean.valueOf(intValue.value != 0),
        const (BigInt) => BigInt.from(intValue.value),
        const (bool) => intValue.value != 0,
        _ => intValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= LONG GENERIC CONVERTER =========================================

/// {@template long_generic_converter}
/// A converter that transforms a [Long] to a specific numeric subtype.
///
/// Supported conversions:
/// - `Long` → `Long` (identity)
/// - `Long` → `int`
/// - `Long` → `double`
/// - `Long` → `num`
/// - `Long` → `String`
/// - `Long` → `Integer`
/// - `Long` → `Long`
/// - `Long` → `Float`
/// - `Long` → `BigInteger`
/// - `Long` → `BigDecimal`
/// - `Long` → `Character`
/// - `Long` → `Short`
/// - `Long` → `Double`
/// - `Long` → `Boolean`
/// - `Long` → `BigInt`
/// - `Long` → `bool`
///
/// Example:
/// ```dart
/// final converter = LongGenericConverter();
/// print(converter.convert(Long.valueOf(3)))); // prints: 3
/// ```
/// {@endtemplate}
class LongGenericConverter implements ConditionalGenericConverter {
  /// {@macro long_generic_converter}
  LongGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Long), Class.forType(int)),
      ConvertiblePair(Class.forType(Long), Class.forType(double)),
      ConvertiblePair(Class.forType(Long), Class.forType(num)),
      ConvertiblePair(Class.forType(Long), Class.forType(String)),
      ConvertiblePair(Class.forType(Long), Class.forType(Integer)),
      ConvertiblePair(Class.forType(Long), Class.forType(Long)),
      ConvertiblePair(Class.forType(Long), Class.forType(Float)),
      ConvertiblePair(Class.forType(Long), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(Long), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(Long), Class.forType(Character)),
      ConvertiblePair(Class.forType(Long), Class.forType(Short)),
      ConvertiblePair(Class.forType(Long), Class.forType(Double)),
      ConvertiblePair(Class.forType(Long), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(Long), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(Long), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == Long && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final longValue = source as Long;

    try {
      return switch (targetType.getType()) {
        const (int) => longValue.value,
        const (double) => longValue.toDouble(),
        const (num) => longValue.value,
        const (String) => longValue.toString(),
        const (Integer) => Integer.valueOf(longValue.value),
        const (Float) => Float.valueOf(longValue.toDouble()),
        const (BigInteger) => BigInteger.fromInt(longValue.value),
        const (BigDecimal) => BigDecimal.fromInt(longValue.value),
        const (Character) => Character.valueOf(longValue.toString()),
        const (Short) => Short.valueOf(longValue.value),
        const (Double) => Double.valueOf(longValue.toDouble()),
        const (Boolean) => Boolean.valueOf(longValue.value != 0),
        const (BigInt) => BigInt.from(longValue.value),
        const (bool) => longValue.value != 0,
        _ => longValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= FLOAT GENERIC CONVERTER =========================================

/// {@template float_generic_converter}
/// A converter that transforms a [Float] to a specific numeric subtype.
///
/// Supported conversions:
/// - `Float` → `Float` (identity)
/// - `Float` → `int`
/// - `Float` → `double`
/// - `Float` → `num`
/// - `Float` → `String`
/// - `Float` → `Integer`
/// - `Float` → `Long`
/// - `Float` → `Float`
/// - `Float` → `BigInteger`
/// - `Float` → `BigDecimal`
/// - `Float` → `Character`
/// - `Float` → `Short`
/// - `Float` → `Double`
/// - `Float` → `Boolean`
/// - `Float` → `BigInt`
/// - `Float` → `bool`
///
/// Example:
/// ```dart
/// final converter = FloatGenericConverter();
/// print(converter.convert(Float.valueOf(3)))); // prints: 3
/// ```
/// {@endtemplate}
class FloatGenericConverter implements ConditionalGenericConverter {
  /// {@macro float_generic_converter}
  FloatGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Float), Class.forType(int)),
      ConvertiblePair(Class.forType(Float), Class.forType(double)),
      ConvertiblePair(Class.forType(Float), Class.forType(num)),
      ConvertiblePair(Class.forType(Float), Class.forType(String)),
      ConvertiblePair(Class.forType(Float), Class.forType(Integer)),
      ConvertiblePair(Class.forType(Float), Class.forType(Long)),
      ConvertiblePair(Class.forType(Float), Class.forType(Float)),
      ConvertiblePair(Class.forType(Float), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(Float), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(Float), Class.forType(Character)),
      ConvertiblePair(Class.forType(Float), Class.forType(Short)),
      ConvertiblePair(Class.forType(Float), Class.forType(Double)),
      ConvertiblePair(Class.forType(Float), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(Float), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(Float), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == Float && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final floatValue = source as Float;

    try {
      return switch (targetType.getType()) {
        const (int) => floatValue.toInt(),
        const (double) => floatValue.toInt().toDouble(),
        const (num) => floatValue.toInt(),
        const (String) => floatValue.toString(),
        const (Integer) => Integer.valueOf(floatValue.toInt()),
        const (Long) => Long.valueOf(floatValue.toInt()),
        const (Float) => Float.valueOf(floatValue.toInt().toDouble()),
        const (BigInteger) => BigInteger.fromInt(floatValue.toInt()),
        const (BigDecimal) => BigDecimal.fromInt(floatValue.toInt()),
        const (Character) => Character.valueOf(floatValue.toString()),
        const (Short) => Short.valueOf(floatValue.toInt()),
        const (Double) => Double.valueOf(floatValue.toInt().toDouble()),
        const (Boolean) => Boolean.valueOf(floatValue.toInt() != 0),
        const (BigInt) => BigInt.from(floatValue.toInt()),
        const (bool) => floatValue.toInt() != 0,
        _ => floatValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= BIGINTEGER GENERIC CONVERTER =========================================

/// {@template biginteger_generic_converter}
/// A converter that transforms a [BigInteger] to a specific numeric subtype.
///
/// Supported conversions:
/// - `BigInteger` → `BigInteger` (identity)
/// - `BigInteger` → `int`
/// - `BigInteger` → `double`
/// - `BigInteger` → `num`
/// - `BigInteger` → `String`
/// - `BigInteger` → `Integer`
/// - `BigInteger` → `Long`
/// - `BigInteger` → `Float`
/// - `BigInteger` → `BigInteger`
/// - `BigInteger` → `BigDecimal`
/// - `BigInteger` → `Character`
/// - `BigInteger` → `Short`
/// - `BigInteger` → `Double`
/// - `BigInteger` → `Boolean`
/// - `BigInteger` → `BigInt`
/// - `BigInteger` → `bool`
///
/// Example:
/// ```dart
/// final converter = BigIntegerGenericConverter();
/// print(converter.convert(BigInteger.valueOf(3)))); // prints: 3
/// ```
/// {@endtemplate}
class BigIntegerGenericConverter implements ConditionalGenericConverter {
  /// {@macro biginteger_generic_converter}
  BigIntegerGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(BigInteger), Class.forType(int)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(double)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(num)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(String)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(Integer)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(Long)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(Float)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(Character)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(Short)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(Double)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(BigInteger), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == BigInteger && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final bigIntValue = source as BigInteger;

    try {
      return switch (targetType.getType()) {
        const (int) => bigIntValue.toInt(),
        const (double) => bigIntValue.toDouble(),
        const (num) => bigIntValue.toInt(),
        const (String) => bigIntValue.toString(),
        const (Integer) => Integer.valueOf(bigIntValue.toInt()),
        const (Long) => Long.valueOf(bigIntValue.toInt()),
        const (Float) => Float.valueOf(bigIntValue.toDouble()),
        const (BigDecimal) => BigDecimal.fromInt(bigIntValue.toInt()),
        const (Character) => Character.valueOf(bigIntValue.toString()),
        const (Short) => Short.valueOf(bigIntValue.toInt()),
        const (Double) => Double.valueOf(bigIntValue.toDouble()),
        const (Boolean) => Boolean.valueOf(bigIntValue.toInt() != 0),
        const (BigInt) => BigInt.from(bigIntValue.toInt()),
        const (bool) => bigIntValue.toInt() != 0,
        _ => bigIntValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= BIGDECIMAL GENERIC CONVERTER =========================================

/// {@template bigdecimal_generic_converter}
/// A converter that transforms a [BigDecimal] to a specific numeric subtype.
///
/// Supported conversions:
/// - `BigDecimal` → `BigDecimal` (identity)
/// - `BigDecimal` → `int`
/// - `BigDecimal` → `double`
/// - `BigDecimal` → `num`
/// - `BigDecimal` → `String`
/// - `BigDecimal` → `Integer`
/// - `BigDecimal` → `Long`
/// - `BigDecimal` → `Float`
/// - `BigDecimal` → `BigInteger`
/// - `BigDecimal` → `BigDecimal`
/// - `BigDecimal` → `Character`
/// - `BigDecimal` → `Short`
/// - `BigDecimal` → `Double`
/// - `BigDecimal` → `Boolean`
/// - `BigDecimal` → `BigInt`
/// - `BigDecimal` → `bool`
///
/// Example:
/// ```dart
/// final converter = BigDecimalGenericConverter();
/// print(converter.convert(BigDecimal.valueOf(3)))); // prints: 3
/// ```
/// {@endtemplate}
class BigDecimalGenericConverter implements ConditionalGenericConverter {
  /// {@macro bigdecimal_generic_converter}
  BigDecimalGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(int)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(double)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(num)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(String)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(Integer)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(Long)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(Float)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(Character)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(Short)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(Double)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(BigDecimal), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == BigDecimal && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final decimalValue = source as BigDecimal;

    try {
      return switch (targetType.getType()) {
        const (int) => decimalValue.toDouble().round(),
        const (double) => decimalValue.toDouble(),
        const (num) => decimalValue.toDouble(),
        const (String) => decimalValue.toString(),
        const (Integer) => Integer.valueOf(decimalValue.toDouble().round()),
        const (Long) => Long.valueOf(decimalValue.toDouble().round()),
        const (Float) => Float.valueOf(decimalValue.toDouble()),
        const (BigInteger) => BigInteger.fromInt(decimalValue.toDouble().round()),
        const (Character) => Character.valueOf(decimalValue.toString()),
        const (Short) => Short.valueOf(decimalValue.toDouble().round()),
        const (Double) => Double.valueOf(decimalValue.toDouble()),
        const (Boolean) => Boolean.valueOf(decimalValue.toDouble().round() != 0),
        const (BigInt) => BigInt.from(decimalValue.toDouble().round()),
        const (bool) => decimalValue.toDouble().round() != 0,
        _ => decimalValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= SHORT GENERIC CONVERTER =========================================

/// {@template short_generic_converter}
/// A converter that transforms a [Short] to a specific numeric subtype.
///
/// Supported conversions:
/// - `Short` → `Short` (identity)
/// - `Short` → `int`
/// - `Short` → `double`
/// - `Short` → `num`
/// - `Short` → `String`
/// - `Short` → `Integer`
/// - `Short` → `Long`
/// - `Short` → `Float`
/// - `Short` → `BigInteger`
/// - `Short` → `BigDecimal`
/// - `Short` → `Character`
/// - `Short` → `Short`
/// - `Short` → `Double`
/// - `Short` → `Boolean`
/// - `Short` → `BigInt`
/// - `Short` → `bool`
///
/// Example:
/// ```dart
/// final converter = ShortGenericConverter();
/// print(converter.convert(Short.valueOf(3)))); // prints: 3
/// ```
/// {@endtemplate}
class ShortGenericConverter implements ConditionalGenericConverter {
  /// {@macro short_generic_converter}
  ShortGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Short), Class.forType(int)),
      ConvertiblePair(Class.forType(Short), Class.forType(double)),
      ConvertiblePair(Class.forType(Short), Class.forType(num)),
      ConvertiblePair(Class.forType(Short), Class.forType(String)),
      ConvertiblePair(Class.forType(Short), Class.forType(Integer)),
      ConvertiblePair(Class.forType(Short), Class.forType(Long)),
      ConvertiblePair(Class.forType(Short), Class.forType(Float)),
      ConvertiblePair(Class.forType(Short), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(Short), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(Short), Class.forType(Character)),
      ConvertiblePair(Class.forType(Short), Class.forType(Short)),
      ConvertiblePair(Class.forType(Short), Class.forType(Double)),
      ConvertiblePair(Class.forType(Short), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(Short), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(Short), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == Short && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final shortValue = source as Short;

    try {
      return switch (targetType.getType()) {
        const (int) => shortValue.value,
        const (double) => shortValue.value.toDouble(),
        const (num) => shortValue.value,
        const (String) => shortValue.toString(),
        const (Integer) => Integer.valueOf(shortValue.value),
        const (Long) => Long.valueOf(shortValue.value),
        const (Float) => Float.valueOf(shortValue.value.toDouble()),
        const (BigInteger) => BigInteger.fromInt(shortValue.value),
        const (BigDecimal) => BigDecimal.fromInt(shortValue.value),
        const (Character) => Character.valueOf(shortValue.toString()),
        const (Double) => Double.valueOf(shortValue.value.toDouble()),
        const (Boolean) => Boolean.valueOf(shortValue.value != 0),
        const (BigInt) => BigInt.from(shortValue.value),
        const (bool) => shortValue.value != 0,
        _ => shortValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= DOUBLED GENERIC CONVERTER =========================================

/// {@template doubled_generic_converter}
/// A converter that transforms a [Double] to a specific numeric subtype.
///
/// Supported conversions:
/// - `Double` → `Double` (identity)
/// - `Double` → `int`
/// - `Double` → `double`
/// - `Double` → `num`
/// - `Double` → `String`
/// - `Double` → `Integer`
/// - `Double` → `Long`
/// - `Double` → `Float`
/// - `Double` → `BigInteger`
/// - `Double` → `BigDecimal`
/// - `Double` → `Character`
/// - `Double` → `Short`
/// - `Double` → `Double`
/// - `Double` → `Boolean`
/// - `Double` → `BigInt`
/// - `Double` → `bool`
///
/// Example:
/// ```dart
/// final converter = DoubleGenericConverter();
/// print(converter.convert(Double.valueOf(3)))); // prints: 3
/// ```
/// {@endtemplate}
class DoubledGenericConverter implements ConditionalGenericConverter {
  /// {@macro doubled_generic_converter}
  DoubledGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Double), Class.forType(int)),
      ConvertiblePair(Class.forType(Double), Class.forType(double)),
      ConvertiblePair(Class.forType(Double), Class.forType(num)),
      ConvertiblePair(Class.forType(Double), Class.forType(String)),
      ConvertiblePair(Class.forType(Double), Class.forType(Integer)),
      ConvertiblePair(Class.forType(Double), Class.forType(Long)),
      ConvertiblePair(Class.forType(Double), Class.forType(Float)),
      ConvertiblePair(Class.forType(Double), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(Double), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(Double), Class.forType(Character)),
      ConvertiblePair(Class.forType(Double), Class.forType(Short)),
      ConvertiblePair(Class.forType(Double), Class.forType(Double)),
      ConvertiblePair(Class.forType(Double), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(Double), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(Double), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == Double && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final doubleValue = source as Double;

    try {
      return switch (targetType.getType()) {
        const (int) => doubleValue.toInt(),
        const (double) => doubleValue,
        const (num) => doubleValue,
        const (String) => doubleValue.toString(),
        const (Integer) => Integer.valueOf(doubleValue.toInt()),
        const (Long) => Long.valueOf(doubleValue.toInt()),
        const (Float) => Float.valueOf(doubleValue.value),
        const (BigInteger) => BigInteger.fromInt(doubleValue.toInt()),
        const (BigDecimal) => BigDecimal.fromInt(doubleValue.toInt()),
        const (Character) => Character.valueOf(doubleValue.toString()),
        const (Short) => Short.valueOf(doubleValue.toInt()),
        const (Boolean) => Boolean.valueOf(doubleValue.toInt() != 0),
        const (BigInt) => BigInt.from(doubleValue.toInt()),
        const (bool) => doubleValue.toInt() != 0,
        _ => doubleValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= BOOLEAN GENERIC CONVERTER =========================================

/// {@template boolean_generic_converter}
/// A converter that transforms a [Boolean] to a specific numeric subtype.
///
/// Supported conversions:
/// - `Boolean` → `Boolean` (identity)
/// - `Boolean` → `int`
/// - `Boolean` → `double`
/// - `Boolean` → `num`
/// - `Boolean` → `String`
/// - `Boolean` → `Integer`
/// - `Boolean` → `Long`
/// - `Boolean` → `Float`
/// - `Boolean` → `BigInteger`
/// - `Boolean` → `BigDecimal`
/// - `Boolean` → `Character`
/// - `Boolean` → `Short`
/// - `Boolean` → `Double`
/// - `Boolean` → `Boolean`
/// - `Boolean` → `BigInt`
/// - `Boolean` → `bool`
///
/// Example:
/// ```dart
/// final converter = BooleanGenericConverter();
/// print(converter.convert(Boolean.valueOf(true)))); // prints: true
/// ```
/// {@endtemplate}
class BooleanGenericConverter implements ConditionalGenericConverter {
  /// {@macro boolean_generic_converter}
  BooleanGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Boolean), Class.forType(int)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(double)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(num)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(String)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(Integer)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(Long)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(Float)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(Character)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(Short)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(Double)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(Boolean), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == Boolean && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final boolValue = (source as Boolean).value;

    try {
      return switch (targetType.getType()) {
        const (int) => boolValue ? 1 : 0,
        const (double) => boolValue ? 1.0 : 0.0,
        const (num) => boolValue ? 1 : 0,
        const (String) => boolValue.toString(),
        const (Integer) => Integer.valueOf(boolValue ? 1 : 0),
        const (Long) => Long.valueOf(boolValue ? 1 : 0),
        const (Float) => Float.valueOf(boolValue ? 1.0 : 0.0),
        const (BigInteger) => BigInteger.fromInt(boolValue ? 1 : 0),
        const (BigDecimal) => BigDecimal.fromInt(boolValue ? 1 : 0),
        const (Character) => Character.valueOf(boolValue ? '1' : '0'),
        const (Short) => Short.valueOf(boolValue ? 1 : 0),
        const (Double) => Double.valueOf(boolValue ? 1.0 : 0.0),
        const (Boolean) => Boolean.valueOf(boolValue),
        const (BigInt) => BigInt.from(boolValue ? 1 : 0),
        const (bool) => boolValue,
        _ => boolValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ======================================= CHARACTER GENERIC CONVERTER =========================================

/// {@template character_generic_converter}
/// A converter that transforms a [Character] to a specific numeric subtype.
///
/// Supported conversions:
/// - `Character` → `Character` (identity)
/// - `Character` → `int`
/// - `Character` → `double`
/// - `Character` → `num`
/// - `Character` → `String`
/// - `Character` → `Integer`
/// - `Character` → `Long`
/// - `Character` → `Float`
/// - `Character` → `BigInteger`
/// - `Character` → `BigDecimal`
/// - `Character` → `Character`
/// - `Character` → `Short`
/// - `Character` → `Double`
/// - `Character` → `Boolean`
/// - `Character` → `BigInt`
/// - `Character` → `bool`
///
/// Example:
/// ```dart
/// final converter = CharacterGenericConverter();
/// print(converter.convert(Character.valueOf('A')))); // prints: A
/// ```
/// {@endtemplate}
class CharacterGenericConverter implements ConditionalGenericConverter {
  /// {@macro character_generic_converter}
  CharacterGenericConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Character), Class.forType(int)),
      ConvertiblePair(Class.forType(Character), Class.forType(double)),
      ConvertiblePair(Class.forType(Character), Class.forType(num)),
      ConvertiblePair(Class.forType(Character), Class.forType(String)),
      ConvertiblePair(Class.forType(Character), Class.forType(Integer)),
      ConvertiblePair(Class.forType(Character), Class.forType(Long)),
      ConvertiblePair(Class.forType(Character), Class.forType(Float)),
      ConvertiblePair(Class.forType(Character), Class.forType(BigInteger)),
      ConvertiblePair(Class.forType(Character), Class.forType(BigDecimal)),
      ConvertiblePair(Class.forType(Character), Class.forType(Character)),
      ConvertiblePair(Class.forType(Character), Class.forType(Short)),
      ConvertiblePair(Class.forType(Character), Class.forType(Double)),
      ConvertiblePair(Class.forType(Character), Class.forType(Boolean)),
      ConvertiblePair(Class.forType(Character), Class.forType(BigInt)),
      ConvertiblePair(Class.forType(Character), Class.forType(bool)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.getType() == Character && (
    targetType.getType() == int ||
    targetType.getType() == double ||
    targetType.getType() == num ||
    targetType.getType() == String ||
    targetType.getType() == Integer ||
    targetType.getType() == Long ||
    targetType.getType() == Float ||
    targetType.getType() == BigInteger ||
    targetType.getType() == BigDecimal ||
    targetType.getType() == Character ||
    targetType.getType() == Short ||
    targetType.getType() == Double ||
    targetType.getType() == Boolean ||
    targetType.getType() == BigInt ||
    targetType.getType() == bool
  );

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final charValue = (source as Character).toString();
    final intValue = int.tryParse(charValue) ?? (charValue.isNotEmpty ? charValue.codeUnitAt(0) : 0);

    try {
      return switch (targetType.getType()) {
        const (int) => intValue,
        const (double) => intValue.toDouble(),
        const (num) => intValue,
        const (String) => charValue,
        const (Integer) => Integer.valueOf(intValue),
        const (Long) => Long.valueOf(intValue),
        const (Float) => Float.valueOf(intValue.toDouble()),
        const (BigInteger) => BigInteger.fromInt(intValue),
        const (BigDecimal) => BigDecimal.fromInt(intValue),
        const (Character) => Character.valueOf(charValue),
        const (Short) => Short.valueOf(intValue),
        const (Double) => Double.valueOf(intValue.toDouble()),
        const (Boolean) => Boolean.valueOf(intValue != 0),
        const (BigInt) => BigInt.from(intValue),
        const (bool) => intValue != 0,
        _ => charValue,
      };
    } catch (e) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: e);
    }
  }
}

// ========================================= RUNES CONVERTER ==============================================

/// {@template string_to_runes_converter}
/// A [Converter] that converts a [String] to a [Runes].
///
/// Example:
/// ```dart
/// final converter = StringToRunesConverter();
/// print(converter.convert('hello')); // prints: Runes(104, 101, 108, 108, 111)
/// ```
/// {@endtemplate}
class StringToRunesConverter extends Converter<String, Runes> {
  /// {@macro string_to_runes_converter}
  @override
  Runes convert(String source) {
    return source.runes;
  }
}

/// {@template runes_to_string_converter}
/// A [Converter] that converts a [Runes] to a [String].
///
/// Example:
/// ```dart
/// final converter = RunesToStringConverter();
/// print(converter.convert(Runes(104, 101, 108, 108, 111))); // prints: "hello"
/// ```
/// {@endtemplate}
class RunesToStringConverter extends Converter<Runes, String> {
  /// {@macro runes_to_string_converter}
  @override
  String convert(Runes source) {
    return String.fromCharCodes(source);
  }
}

// ========================================= SYMBOL CONVERTER ==============================================

/// {@template string_to_symbol_converter}
/// A [Converter] that converts a [String] to a [Symbol].
///
/// Example:
/// ```dart
/// final converter = StringToSymbolConverter();
/// print(converter.convert('hello')); // prints: Symbol("hello")
/// ```
/// {@endtemplate}
class StringToSymbolConverter extends Converter<String, Symbol> {
  /// {@macro string_to_symbol_converter}
  @override
  Symbol convert(String source) {
    return Symbol(source);
  }
}

/// {@template symbol_to_string_converter}
/// A [Converter] that converts a [Symbol] to a [String].
///
/// Example:
/// ```dart
/// final converter = SymbolToStringConverter();
/// print(converter.convert(Symbol("hello"))); // prints: "hello"
/// ```
/// {@endtemplate}
class SymbolToStringConverter extends Converter<Symbol, String> {
  /// {@macro symbol_to_string_converter}
  @override
  String convert(Symbol source) {
    return source.toString().replaceAll('Symbol("', '').replaceAll('")', '');
  }
}

// ========================================= URI Converters =========================================

/// {@template string_to_uri_converter}
/// A [Converter] that converts a [String] to a [Uri].
///
/// Example:
/// ```dart
/// final converter = StringToUriConverter();
/// print(converter.convert('https://example.com')); // prints: Uri.parse('https://example.com')
/// ```
/// {@endtemplate}
class StringToUriConverter extends Converter<String, Uri> {
  /// List of validators for this converter
  final List<UriValidator> validators;

  /// {@macro string_to_uri_converter}
  StringToUriConverter(this.validators);

  @override
  Uri convert(String source) {
    final uri = Uri.tryParse(source);
    if (uri == null) {
      throw ConversionFailedException(
        sourceType: Class.forType(String),
        targetType: Class.forType(Uri),
        value: source,
        point: ConversionException("Invalid URI")
      );
    } else if (validators.any((validator) => !validator.isValid(uri))) {
      throw ConversionFailedException(
        sourceType: Class.forType(String),
        targetType: Class.forType(Uri),
        value: source,
        point: ConversionException(validators.where((validator) => !validator.isValid(uri)).map((validator) => validator.errorMessage).join(', '))
      );
    }

    return uri;
  }
}

/// {@template uri_to_string_converter}
/// A [Converter] that converts a [Uri] to a [String].
///
/// Example:
/// ```dart
/// final converter = UriToStringConverter();
/// print(converter.convert(Uri.parse('https://example.com'))); // prints: 'https://example.com'
/// ```
/// {@endtemplate}
class UriToStringConverter extends Converter<Uri, String> {
  /// {@macro uri_to_string_converter}
  @override
  String convert(Uri source) {
    return source.toString();
  }
}

// ============================================ RegExp Converters ==========================================

/// {@template string_to_reg_exp_converter}
/// A [Converter] that converts a [String] to a [RegExp].
///
/// Example:
/// ```dart
/// final converter = StringToRegExpConverter();
/// print(converter.convert('hello')); // prints: RegExp('hello')
/// ```
/// {@endtemplate}
class StringToRegExpConverter extends Converter<String, RegExp> {
  /// {@macro string_to_reg_exp_converter}
  @override
  RegExp convert(String source) {
    try {
      return RegExp(source);
    } catch (e) {
      throw ConversionFailedException(sourceType: Class.forType(String), targetType: Class.forType(RegExp), value: source, point: e);
    }
  }
}

/// {@template reg_exp_to_string_converter}
/// A [Converter] that converts a [RegExp] to a [String].
///
/// Example:
/// ```dart
/// final converter = RegExpToStringConverter();
/// print(converter.convert(RegExp('hello'))); // prints: 'hello'
/// ```
/// {@endtemplate}
class RegExpToStringConverter extends Converter<RegExp, String> {
  /// {@macro reg_exp_to_string_converter}
  @override
  String convert(RegExp source) {
    return source.pattern;
  }
}

/// {@template string_to_pattern_converter}
/// A [Converter] that converts a [String] to a [Pattern].
///
/// Creates a RegExp pattern from the string.
///
/// Example:
/// ```dart
/// final converter = StringToPatternConverter();
/// print(converter.convert(r'\d+')); // prints: RegExp(r'\d+')
/// ```
/// {@endtemplate}
class StringToPatternConverter extends Converter<String, Pattern> {
  /// {@macro string_to_pattern_converter}
  @override
  Pattern convert(String source) {
    return RegExp(source);
  }
}

/// {@template pattern_to_string_converter}
/// A [Converter] that converts a [Pattern] to a [String].
///
/// Example:
/// ```dart
/// final converter = PatternToStringConverter();
/// print(converter.convert(RegExp('hello'))); // prints: 'hello'
/// ```
/// {@endtemplate}
class PatternToStringConverter extends Converter<Pattern, String> {
  @override
  String convert(Pattern source) {
    return source.toString();
  }
}

/// {@template dart_stream_converter}
/// A specialized converter that handles bidirectional conversion between [Stream] and
/// various collection types ([List], [Set], [Queue], etc.).
///
/// This converter integrates with a [ConversionService] to handle element-level
/// conversions when transforming between streams and collections.
///
/// {@template stream_converter_features}
/// ## Key Features
/// - Bidirectional conversion between Stream and collection types
/// - Element-level type conversion using the provided [ConversionService]
/// - Support for all major Dart collection types
/// - Asynchronous stream processing
/// {@endtemplate}
///
/// {@template stream_converter_usage}
/// ## Usage Example
///
/// ```dart
/// final conversionService = GenericConversionService();
/// final streamConverter = DartStreamConverter(conversionService);
/// conversionService.addGenericConverter(streamConverter);
///
/// // Convert Stream to List
/// final stream = Stream.fromIterable([1, 2, 3]);
/// final list = await conversionService.convert(stream, List<int>);
///
/// // Convert List to Stream
/// final numbers = [1, 2, 3];
/// final numberStream = conversionService.convert(numbers, Stream<int>);
/// ```
/// {@endtemplate}
/// {@endtemplate}
class DartStreamConverter implements ConditionalGenericConverter {
  /// {@template stream_converter_dependencies}
  /// The conversion service used for element-level type conversions.
  /// {@endtemplate}
  final ConversionService _conversionService;

  /// {@template stream_converter_constructor}
  /// Creates a new [DartStreamConverter] with the given [ConversionService].
  ///
  /// Parameters:
  /// - [conversionService]: The service to use for element-level conversions
  ///
  /// Example:
  /// ```dart
  /// final converter = DartStreamConverter(myConversionService);
  /// ```
  /// {@endtemplate}
  /// 
  /// {@macro dart_stream_converter}
  DartStreamConverter(this._conversionService);

  /// {@template stream_type_constant}
  /// The [Class] instance representing the [Stream] type.
  /// {@endtemplate}
  static final Class STREAM_TYPE = Class.forType(Stream);

  /// {@template convertible_types}
  /// The set of type pairs this converter can handle.
  ///
  /// Includes conversions between:
  /// - [Stream] and all major collection types ([List], [Set], [Queue], etc.)
  /// - Various collection types and [Stream]
  /// {@endtemplate}
  static final Set<ConvertiblePair> CONVERTIBLE_TYPES = _createConvertibleTypes();

  static Set<ConvertiblePair> _createConvertibleTypes() {
    final convertiblePairs = HashSet<ConvertiblePair>();
    convertiblePairs.add(ConvertiblePair(Class.forType(Stream), Class.forType(List)));
    convertiblePairs.add(ConvertiblePair(Class.forType(Stream), Class.forType(Iterable)));
    convertiblePairs.add(ConvertiblePair(Class.forType(List), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(Iterable), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(Queue), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(Set), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(ArrayList), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(HashSet), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(LinkedQueue), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(LinkedList), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(LinkedStack), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(Stack), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(col.LinkedHashSet), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(col.ListBase), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(col.SetBase), Class.forType(Stream)));
    convertiblePairs.add(ConvertiblePair(Class.forType(col.Queue), Class.forType(Stream)));
    return convertiblePairs;
  }

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => CONVERTIBLE_TYPES;

  @override
  bool matches(Class sourceType, Class targetType) {
    if (sourceType.isAssignableTo(STREAM_TYPE)) {
      return matchesFromStream(sourceType.componentType(), targetType);
    }
    if (targetType.isAssignableTo(STREAM_TYPE)) {
      return matchesToStream(targetType.componentType()!, sourceType);
    }
    return false;
  }

  bool matchesFromStream(Class? sourceElementType, Class targetType) {
    if (_isCollection(targetType)) {
      return _conversionService.canConvert(sourceElementType, targetType);
    }
    return false;
  }

  bool matchesToStream(Class targetElementType, Class sourceType) {
    if (_isCollection(sourceType)) {
      return _conversionService.canConvert(sourceType.componentType(), targetElementType);
    }
    return false;
  }

  bool _isCollection(Class type) {
    return type.getType() == List ||
        type.getType() == Set ||
        type.getType() == Queue ||
        type.getType() == Iterable ||
        type.getType() == ArrayList ||
        type.getType() == HashSet ||
        type.getType() == LinkedQueue ||
        type.getType() == LinkedList ||
        type.getType() == LinkedStack ||
        type.getType() == Stack ||
        type.getType() == col.LinkedHashSet ||
        type.getType() == col.ListBase ||
        type.getType() == col.SetBase ||
        type.getType() == col.Queue;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (sourceType.isAssignableTo(STREAM_TYPE)) {
      Object? result;

      _convertFromStream(source as Stream, sourceType, targetType, result);
      return result;
    }
    if (targetType.isAssignableTo(STREAM_TYPE)) {
      return _convertToStream(source as Iterable, sourceType, targetType);
    }

    throw IllegalStateException("Unexpected source/target types: $sourceType -> $targetType");
  }

  /// {@template _convert_from_stream}
  /// Internal method to convert from a Stream to a collection type.
  ///
  /// Parameters:
  /// - [stream]: The source stream
  /// - [sourceType]: The type of the stream (including element type)
  /// - [targetType]: The target collection type
  ///
  /// Returns:
  /// - A Future that completes with the converted collection
  /// {@endtemplate}
  void _convertFromStream(Stream stream, Class sourceType, Class targetType, Object? result) async {
    final sourceElementType = _getElementType(sourceType);
    final targetElementType = _getElementType(targetType);

    final elements = <dynamic>[];
    await for (final element in stream) {
      if (targetElementType != null && sourceElementType != null) {
        final converted = _conversionService.convertTo(element, sourceElementType, targetElementType);
        elements.add(converted);
      } else {
        elements.add(element);
      }
    }

    result = _createTargetCollection(targetType, elements);
  }

  /// {@template _convert_to_stream}
  /// Internal method to convert from a collection to a Stream.
  ///
  /// Parameters:
  /// - [iterable]: The source collection
  /// - [sourceType]: The type of the collection
  /// - [targetType]: The target stream type
  ///
  /// Returns:
  /// - A new Stream emitting converted elements
  /// {@endtemplate}
  Stream _convertToStream(Iterable iterable, Class sourceType, Class targetType) async* {
    final sourceElementType = _getElementType(sourceType);
    final targetElementType = _getElementType(targetType);

    for (final element in iterable) {
      if (targetElementType != null && sourceElementType != null) {
        yield _conversionService.convertTo(element, sourceElementType, targetElementType);
      } else {
        yield element;
      }
    }
  }

  Class? _getElementType(Class collectionType) {
    return collectionType.componentType();
  }

  Object _createTargetCollection(Class targetType, List elements) {
    final dartType = targetType.getType();
    if (dartType == List) return List.from(elements);
    if (dartType == Set) return Set.from(elements);
    if (dartType == Queue) return Queue.from(elements);
    if (dartType == Iterable) return elements;
    return List.from(elements);
  }
}

// ============================================ ENUM CONVERTER ==============================================

/// {@template string_to_enum_converter_factory}
/// A [ConverterFactory] that provides converters to convert strings to enums.
///
/// This factory dynamically returns a converter that transforms
/// a [String] value to a specific enum type at runtime.
///
/// Example:
/// ```dart
/// final factory = StringToEnumConverterFactory();
/// final converter = factory.getConverter<Enum>(Class.forType(Enum));
///
/// print(converter?.convert('value')); // prints: Enum.value
/// ```
/// {@endtemplate}
class StringToEnumConverterFactory implements ConverterFactory<String, Enum> {
  /// {@macro string_to_enum_converter_factory}
  @override
  Converter<String, T>? getConverter<T>(Class<T> targetType) {
    return _StringToEnumConverter<T>(targetType);
  }
}

/// {@template string_to_enum_converter}
/// A [Converter] that converts a [String] to an [Enum].
///
/// Example:
/// ```dart
/// final converter = StringToEnumConverter();
/// print(converter.convert('value')); // prints: Enum.value
/// ```
/// {@endtemplate}
@Generic(_StringToEnumConverter)
class _StringToEnumConverter<T> extends Converter<String, T> {
  /// The target enum type to convert into.
  final Class<T> _targetType;

  /// {@macro string_to_enum_converter}
  _StringToEnumConverter(this._targetType);

  @override
  T convert(String source) {
    final result = _targetType.getEnumValues().find((e) => e.getName() == source);
    if (result != null) {
      return result.getValue() as T;
    }
    
    throw ConversionFailedException(sourceType: Class.forType(String), targetType: _targetType, value: source);
  }
}

/// {@template enum_to_string_converter}
/// A [Converter] that converts an [Enum] to a [String].
///
/// Example:
/// ```dart
/// final converter = EnumToStringConverter();
/// print(converter.convert(Enum.value)); // prints: "value"
/// ```
/// {@endtemplate}
class EnumToStringConverter extends Converter<Enum, String> {
  /// {@macro enum_to_string_converter}
  @override
  String convert(Enum source) {
    return source.name;
  }
}

/// {@template int_to_enum_converter_factory}
/// A [ConverterFactory] that provides converters to convert integers to enums.
///
/// This factory dynamically returns a converter that transforms
/// an [int] value to a specific enum type at runtime.
///
/// Example:
/// ```dart
/// final factory = IntToEnumConverterFactory();
/// final converter = factory.getConverter<Enum>(Class.forType(Enum));
///
/// print(converter?.convert(0)); // prints: Enum.value
/// ```
/// {@endtemplate}
class IntToEnumConverterFactory implements ConverterFactory<int, Enum> {
  /// {@macro int_to_enum_converter_factory}
  @override
  Converter<int, T>? getConverter<T>(Class<T> targetType) {
    return _IntToEnumConverter<T>(targetType);
  }
}

/// {@template int_to_enum_converter}
/// A [Converter] that converts an [int] to an [Enum].
///
/// Example:
/// ```dart
/// final converter = IntToEnumConverter();
/// print(converter.convert(0)); // prints: Enum.value
/// ```
/// {@endtemplate}
@Generic(_IntToEnumConverter)
class _IntToEnumConverter<T> extends Converter<int, T> {
  /// The target enum type to convert into.
  final Class<T> _targetType;

  /// {@macro int_to_enum_converter}
  _IntToEnumConverter(this._targetType);

  @override
  T convert(int source) {
    if(_targetType.isEnum()) {
      final result = _targetType.getEnumValues().find((e) => e.getPosition() == source);
      if(result != null) {
        return result.getValue() as T;
      }
    }
    throw ConversionFailedException(
      sourceType: Class.forType(int),
      targetType: _targetType,
      value: source,
      point: UnsupportedError('Direct enum conversion from int by index failed.')
    );
  }
}

/// {@template enum_to_int_converter}
/// A [Converter] that converts an [Enum] to an [int].
///
/// Example:
/// ```dart
/// final converter = EnumToIntConverter();
/// print(converter.convert(Enum.value)); // prints: 0
/// ```
/// {@endtemplate}
class EnumToIntConverter extends Converter<Enum, int> {
  /// {@macro enum_to_int_converter}
  @override
  int convert(Enum source) {
    return source.index;
  }
}