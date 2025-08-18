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

import 'dart:convert';
import 'dart:typed_data';

import 'package:jetleaf_lang/lang.dart';

import '../exceptions.dart';
import '../conversion_service/conversion_service.dart';
import '../conversion_utils.dart';
import '../converter/converters.dart';
import '../convertible_pair.dart';

// ========================================== OPTIONAL CONVERTER ===========================================

/// {@template object_to_optional_converter}
/// A converter that transforms any [Object] into an [Optional].
///
/// This class supports conversion from:
/// - Any type → `Optional<T>`
///
/// The converter handles both single elements and lists, wrapping them
/// appropriately in Optional containers.
///
/// Example:
/// ```dart
/// final service = ConversionService(); // Your implementation
/// final converter = ObjectToOptionalConverter(service);
/// 
/// final input = "Hello";
/// final result = converter.convert(
///   input,
///   Class.forType(String),
///   Class.forType(Optional),
/// );
///
/// print(result.get()); // "Hello"
/// ```
/// {@endtemplate}
class ObjectToOptionalConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro object_to_optional_converter}
  ObjectToOptionalConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Object), Class.forType(Optional)),
      ConvertiblePair(Class.forType(List), Class.forType(Optional)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    if(targetType.hasGenerics()) {
      return _conversionService.canConvert(sourceType, targetType.componentType()!);
    }

    return true;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) {
      return Optional.empty();
    }

    if (source is Optional) {
			return source;
		}

    if(targetType.hasGenerics()) {
      Object? target = _conversionService.convert(source, targetType.componentType()!);
      if (target == null || (Class.forObject(target).isArray() && (target as List).isEmpty)) {
        return Optional.empty();
      } else {
        return Optional.of(target);
      }
    } else {
      return Optional.of(source);
    }
  }
}

/// {@template optional_to_object_converter}
/// A converter that transforms an [Optional] into its contained type.
///
/// This class supports conversion from:
/// - `Optional<T>` → T
/// - `Optional<List<T>>` → `List<T>`
///
/// The converter handles both single elements and lists, unwrapping them
/// from Optional containers and converting to target types as needed.
///
/// Example:
/// ```dart
/// final service = ConversionService(); // Your implementation
/// final converter = OptionalToObjectConverter(service);
/// 
/// final input = Optional.of("Hello");
/// final result = converter.convert(
///   input,
///   Class.forType(Optional),
///   Class.forType(String),
/// );
///
/// print(result); // "Hello"
/// ```
/// {@endtemplate}
class OptionalToObjectConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro optional_to_object_converter}
  OptionalToObjectConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(Optional), Class.forType(Object)),
      ConvertiblePair(Class.forType(Optional), Class.forType(List)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    if(sourceType.hasGenerics()) {
      return ConversionUtils.canConvertElements(sourceType.componentType()!, targetType, _conversionService);
    }

    return true;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final optional = source as Optional;
    
    Object unwrappedSource = optional.orElse(null);
    return _conversionService.convertTo(unwrappedSource, Class.forObject(unwrappedSource), targetType);
  }
}

// =========================================== STREAM CONVERTER =============================================

/// {@template stream_converter}
/// A converter that transforms between Dart `Stream`-like types and other collection types,
/// such as `List` or `Iterable`, and vice versa.
///
/// This converter supports:
/// - Converting from `BaseStream` → `List` / `Iterable`
/// - Converting from `List` / `Iterable` → `BaseStream`
///
/// It uses a [ConversionService] to handle type-safe element conversion when needed.
///
/// ### How it works
/// 1. If the source type is a `Stream`, `_convertFromStream` collects its elements
///    into a list, then converts them into the target type.
/// 2. If the target type is a `Stream`, `_convertToStream` converts the source into
///    a list and then wraps it in a stream.
///
/// ### Example:
/// ```dart
/// final service = ConversionService(); // your implementation
/// final converter = StreamConverter(service);
///
/// // From List to Stream
/// final stream = converter.convert(
///   [1, 2, 3],
///   Class.forType(List),
///   Class.forType(BaseStream),
/// );
///
/// // From Stream to List
/// final list = converter.convert(
///   someBaseStream,
///   Class.forType(BaseStream),
///   Class.forType(List),
/// );
/// ```
/// {@endtemplate}
class StreamConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro stream_converter}
  StreamConverter(this._conversionService);

  /// The Dart type representation for `Stream`.
  static final Class STREAM_TYPE = Class.forType(Stream);

  /// The set of supported source-target convertible type pairs.
  static final Set<ConvertiblePair> CONVERTIBLE_TYPES = _createConvertibleTypes();

  /// {@template stream_converter_create_convertible_types}
  /// Creates a set of convertible type pairs supported by this converter.
  ///
  /// This method declares that conversions are possible between:
  /// - `BaseStream` → `List`
  /// - `BaseStream` → `Iterable`
  /// - `List` → `BaseStream`
  /// - `Iterable` → `BaseStream`
  ///
  /// ### Example:
  /// ```dart
  /// final types = StreamConverter._createConvertibleTypes();
  /// print(types.length); // 4
  /// ```
  /// {@endtemplate}
  static Set<ConvertiblePair> _createConvertibleTypes() {
		Set<ConvertiblePair> convertiblePairs = HashSet();
		convertiblePairs.add(ConvertiblePair(Class.forType(BaseStream), Class.forType(List)));
		convertiblePairs.add(ConvertiblePair(Class.forType(BaseStream), Class.forType(Iterable)));
		convertiblePairs.add(ConvertiblePair(Class.forType(List), Class.forType(BaseStream)));
		convertiblePairs.add(ConvertiblePair(Class.forType(Iterable), Class.forType(BaseStream)));
		return convertiblePairs;
	}

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (sourceType.isAssignableTo(STREAM_TYPE)) {
			return _convertFromStream(source as BaseStream, sourceType, targetType);
		}
		if (targetType.isAssignableTo(STREAM_TYPE)) {
			return _convertToStream(source, sourceType, targetType);
		}

		throw IllegalStateException("Unexpected source/target types");
  }

  /// {@template stream_converter_convert_from_stream}
  /// Converts a `BaseStream` into a target collection type (e.g., `List`, `Iterable`).
  ///
  /// This method:
  /// - Collects all stream elements into a list.
  /// - Resolves the element type from the target type.
  /// - Delegates conversion of the collected list to the [ConversionService].
  ///
  /// If the source stream is `null`, an empty list is used.
  ///
  /// ### Example:
  /// ```dart
  /// final result = converter._convertFromStream(
  ///   myStream,
  ///   Class.forType(BaseStream),
  ///   Class.forType(List),
  /// );
  /// ```
  /// {@endtemplate}
  Object? _convertFromStream(BaseStream? source, Class streamType, Class targetType) {
		List<Object> content = (source != null ? source.collect() as List<Object> : <Object>[]);
		ResolvableType element = ResolvableType.forArrayComponent(ResolvableType.forClass(targetType.getType()));
		return _conversionService.convertTo(content, element.resolve(), targetType);
	}

  /// {@template stream_converter_convert_to_stream}
  /// Converts a source collection (e.g., `List`, `Iterable`) into a `BaseStream`.
  ///
  /// This method:
  /// - Resolves the target collection type from the stream type.
  /// - Converts the source object into a list using the [ConversionService].
  /// - Returns the resulting list as a stream.
  ///
  /// If the conversion yields `null`, an empty list is used.
  ///
  /// ### Example:
  /// ```dart
  /// final stream = converter._convertToStream(
  ///   [1, 2, 3],
  ///   Class.forType(List),
  ///   Class.forType(BaseStream),
  /// );
  /// ```
  /// {@endtemplate}
	Object? _convertToStream(Object? source, Class sourceType, Class streamType) {
		ResolvableType targetCollection = ResolvableType.forArrayComponent(ResolvableType.forClass(streamType.getType()));
		List<dynamic>? target = targetCollection.resolve() != null ? _conversionService.convertTo(source, sourceType, targetCollection.resolve()!) as List<dynamic> : null;
		target ??= <Object>[];
		return target.stream();
	}

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => CONVERTIBLE_TYPES;

  @override
  bool matches(Class sourceType, Class targetType) {
    if (sourceType.isAssignableTo(STREAM_TYPE)) {
			return matchesFromStream(sourceType.componentType(), targetType);
		}
		if (targetType.isAssignableTo(STREAM_TYPE)) {
			return matchesToStream(targetType.componentType(), sourceType);
		}
		return false;
  }

  /// {@template stream_converter_matches_from_stream}
  /// Checks if the converter can convert from a `BaseStream` to a target type.
  ///
  /// This method:
  /// - Resolves the element type from the source type.
  /// - Checks if the [ConversionService] can convert the element type to the target type.
  ///
  /// ### Example:
  /// ```dart
  /// final canConvert = converter.matchesFromStream(
  ///   Class.forType(BaseStream),
  ///   Class.forType(List),
  /// );
  /// ```
  /// {@endtemplate}
  bool matchesFromStream(Class? elementType, Class targetType) {
		ResolvableType? element = elementType != null ? ResolvableType.forArrayComponent(ResolvableType.forClass(elementType.getType())) : null;
		return _conversionService.canConvert(element?.resolve(), targetType);
	}

  /// {@template stream_converter_matches_to_stream}
  /// Checks if the converter can convert from a source type to a `BaseStream`.
  ///
  /// This method:
  /// - Resolves the target collection type from the stream type.
  /// - Checks if the [ConversionService] can convert the source type to the target collection type.
  ///
  /// ### Example:
  /// ```dart
  /// final canConvert = converter.matchesToStream(
  ///   Class.forType(List),
  ///   Class.forType(BaseStream),
  /// );
  /// ```
  /// {@endtemplate}
  bool matchesToStream(Class? elementType, Class targetType) {
		ResolvableType element = ResolvableType.forArrayComponent(ResolvableType.forClass(targetType.getType()));
		return _conversionService.canConvert(element.resolve(), targetType);
	}
}

// ============================================= UUID CONVERTER ============================================

/// {@template string_to_uuid_converter}
/// A [Converter] that converts a [String] to a [Uuid].
///
/// Supports standard UUID string formats with or without hyphens.
/// Parsing is case-insensitive and validates UUID format compliance.
///
/// Example:
/// ```dart
/// final converter = StringToUuidConverter();
/// print(converter.convert('550e8400-e29b-41d4-a716-446655440000'));
/// print(converter.convert('550e8400e29b41d4a716446655440000'));
/// print(converter.convert('550E8400-E29B-41D4-A716-446655440000'));
/// ```
/// {@endtemplate}
class StringToUuidConverter extends Converter<String, Uuid> {
  /// {@macro string_to_uuid_converter}
  @override
  Uuid convert(String source) {
    try {
      return Uuid.fromString(source);
    } catch (e) {
      throw ConversionFailedException(sourceType: Class.forType(String), targetType: Class.forType(Uuid), value: source);
    }
  }
}

/// {@template uuid_to_string_converter}
/// A [Converter] that converts a [Uuid] to a [String].
///
/// Example:
/// ```dart
/// final converter = UuidToStringConverter();
/// print(converter.convert(Uuid())); // prints: "550e8400-e29b-41d4-a716-446655440000"
/// ```
/// {@endtemplate}
class UuidToStringConverter extends Converter<Uuid, String> {
  /// {@macro uuid_to_string_converter}
  @override
  String convert(Uuid source) {
    return source.toString();
  }
}

/// {@template byte_multi_converter}
/// A [Converter] that converts between [Byte], [String], [List], and [Uint8List].
///
/// Supports the following conversions:
/// - `Byte` ↔ `String`
/// - `Byte` ↔ `List<int>`
/// - `Byte` ↔ `Uint8List`
/// - `String` ↔ `Byte`
/// - `List<int>` ↔ `Byte`
/// - `Uint8List` ↔ `Byte`
///
/// Example:
/// ```dart
/// final converter = ByteMultiConverter();
/// print(converter.convert(Byte.fromString('Hello'), Class.forType(Byte), Class.forType(String))); // "Hello"
/// print(converter.convert('Hello', Class.forType(String), Class.forType(Byte)).toString()); // "Hello"
/// ```
/// {@endtemplate}
class ByteMultiConverter implements ConditionalGenericConverter {
  static final Class BYTE_TYPE      = Class.forType(Byte);
  static final Class STRING_TYPE    = Class.forType(String);
  static final Class LIST_TYPE      = Class.forType(List);
  static final Class UINT8LIST_TYPE = Class.forType(Uint8List);

  static final Set<ConvertiblePair> CONVERTIBLE_TYPES = {
    ConvertiblePair(BYTE_TYPE, STRING_TYPE),
    ConvertiblePair(STRING_TYPE, BYTE_TYPE),

    ConvertiblePair(BYTE_TYPE, LIST_TYPE),
    ConvertiblePair(LIST_TYPE, BYTE_TYPE),

    ConvertiblePair(BYTE_TYPE, UINT8LIST_TYPE),
    ConvertiblePair(UINT8LIST_TYPE, BYTE_TYPE),
  };

  ByteMultiConverter();

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => CONVERTIBLE_TYPES;

  @override
  bool matches(Class sourceType, Class targetType) {
    // Byte ↔ String
    if (sourceType.isAssignableTo(BYTE_TYPE) && targetType.isAssignableTo(STRING_TYPE)) return true;
    if (sourceType.isAssignableTo(STRING_TYPE) && targetType.isAssignableTo(BYTE_TYPE)) return true;

    // Byte ↔ List<int>
    if (sourceType.isAssignableTo(BYTE_TYPE) && targetType.isAssignableTo(LIST_TYPE)) return true;
    if (sourceType.isAssignableTo(LIST_TYPE) && targetType.isAssignableTo(BYTE_TYPE)) return true;

    // Byte ↔ Uint8List
    if (sourceType.isAssignableTo(BYTE_TYPE) && targetType.isAssignableTo(UINT8LIST_TYPE)) return true;
    if (sourceType.isAssignableTo(UINT8LIST_TYPE) && targetType.isAssignableTo(BYTE_TYPE)) return true;

    return false;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    // Byte → String
    if (sourceType.isAssignableTo(BYTE_TYPE) && targetType.isAssignableTo(STRING_TYPE)) {
      return (source as Byte).toString();
    }

    // String → Byte
    if (sourceType.isAssignableTo(STRING_TYPE) && targetType.isAssignableTo(BYTE_TYPE)) {
      return Byte.fromString(source as String);
    }

    // Byte → List<int>
    if (sourceType.isAssignableTo(BYTE_TYPE) && targetType.isAssignableTo(LIST_TYPE)) {
      return (source as Byte).toList();
    }

    // List<int> → Byte
    if (sourceType.isAssignableTo(LIST_TYPE) && targetType.isAssignableTo(BYTE_TYPE)) {
      final list = source as List;
      if (list.isEmpty) return Byte.empty();
      return Byte.fromList(list.cast<int>());
    }

    // Byte → Uint8List
    if (sourceType.isAssignableTo(BYTE_TYPE) && targetType.isAssignableTo(UINT8LIST_TYPE)) {
      return (source as Byte).toUint8List();
    }

    // Uint8List → Byte
    if (sourceType.isAssignableTo(UINT8LIST_TYPE) && targetType.isAssignableTo(BYTE_TYPE)) {
      return Byte.fromUint8List(source as Uint8List);
    }

    throw IllegalStateException("Unsupported conversion: $sourceType -> $targetType");
  }
}

// ========================================= LOCALE CONVERTER =============================================

/// {@template string_to_locale_converter}
/// A [Converter] that converts a [String] to a [Locale].
///
/// Supports standard locale formats like "en", "en_US", "en-US".
///
/// Example:
/// ```dart
/// final converter = StringToLocaleConverter();
/// print(converter.convert('en_US')); // prints: Locale('en', 'US')
/// ```
/// {@endtemplate}
class StringToLocaleConverter extends Converter<String, Locale> {
  /// {@macro string_to_locale_converter}
  StringToLocaleConverter();

  @override
  Locale convert(String source) {
    final parts = source.replaceAll('-', '_').split('_');
    
    if (parts.length == 1) {
      return Locale(parts[0]);
    } else if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else {
      return Locale.parse(source);
    }
  }
}

class LocaleToStringConverter extends Converter<Locale, String> {
  /// {@macro locale_to_string_converter}
  LocaleToStringConverter();

  @override
  String convert(Locale source) {
    return source.toString();
  }
}

// ========================================= CURRENCY CONVERTER ============================================

/// {@template string_to_currency_converter}
/// A [Converter] that converts a [String] to a [Currency].
///
/// Accepts ISO 4217 currency codes.
///
/// Example:
/// ```dart
/// final converter = StringToCurrencyConverter();
/// print(converter.convert('USD')); // prints: Currency('USD')
/// ```
/// {@endtemplate}
class StringToCurrencyConverter extends Converter<String, Currency> {
  /// {@macro string_to_currency_converter}
  @override
  Currency convert(String source) {
    try {
      return Currency.getInstance(source.toUpperCase());
    } on IllegalArgumentException catch (_) {
      try {
        return Currency.getInstanceFromLocale(Locale(source.toUpperCase()));
      } catch (e) {
        throw ConversionFailedException(sourceType: Class.forType(String), targetType: Class.forType(Currency), value: source);
      }
    } 
  }
}

/// {@template currency_to_string_converter}
/// A [Converter] that converts a [Currency] to a [String].
///
/// Example:
/// ```dart
/// final converter = CurrencyToStringConverter();
/// print(converter.convert(Currency.getInstance('USD'))); // prints: 'USD'
/// ```
/// {@endtemplate}
class CurrencyToStringConverter extends Converter<Currency, String> {
  /// {@macro currency_to_string_converter}
  CurrencyToStringConverter();

  @override
  String convert(Currency source) {
    return source.currencyCode;
  }
}