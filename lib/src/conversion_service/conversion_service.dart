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

import 'package:jetleaf_lang/lang.dart';

import '../converter/converter_registry.dart';

/// {@template conversion_service}
/// A strategy interface for type conversion.
///
/// Implementations of this interface are responsible for converting values between
/// different types, such as from `String` to `int`, `List<String>` to `Set<int>`, or
/// custom object mappings.
///
/// Typically used in configuration binding, message deserialization, and
/// property resolution pipelines.
///
/// ---
///
/// ### 🔧 Example Usage:
/// ```dart
/// final service = DefaultConversionService();
///
/// if (service.canConvert<String, int>(Class<String>(), Class<int>())) {
///   final value = service.convert<int>('42', Class<int>());
///   print(value + 1); // 43
/// }
/// ```
/// {@endtemplate}
abstract class ConversionService {
  /// {@template conversion_service_can_convert}
  /// Determines whether objects of [sourceType] can be converted to [targetType].
  ///
  /// This allows frameworks to optimize or validate before performing conversions.
  ///
  /// ### Example:
  /// ```dart
  /// if (conversionService.canConvert<String, DateTime>(Class<String>(), Class<DateTime>())) {
  ///   final date = conversionService.convert<DateTime>('2025-01-01', Class<DateTime>());
  /// }
  /// ```
  /// {@endtemplate}
  bool canConvert(Class? sourceType, Class targetType);

  /// {@template conversion_service_convert}
  /// Converts the given [source] object to the specified [targetType].
  ///
  /// Returns `null` if the conversion fails or if [source] is `null`.
  ///
  /// ### Example:
  /// ```dart
  /// final port = conversionService.convert<int>('8080', Class<int>());
  /// final date = conversionService.convert<DateTime>('2025-01-01', Class<DateTime>());
  /// ```
  ///
  /// The [T] type parameter represents the expected return type.
  /// {@endtemplate}
  T? convert<T>(Object? source, Class<T> targetType);

  /// Converts the [source] to [targetType] using [Class] metadata.
  ///
  /// If [source] is `null`, it attempts to infer the type and apply fallback conversion logic.
  ///
  /// ### Example:
  /// ```dart
  /// final source = ['1', '2', '3'];
  /// final targetType = Class.setOf(Class<int>());
  ///
  /// final result = service.convertWithClass(source, targetType);
  /// print(result); // => {1, 2, 3}
  /// ```
  Object? convertWithClass<T>(Object? source, Class targetType) {
    return convertTo<T>(source, source != null ? Class.forObject(source) : null, targetType);
  }

  /// Converts the [source] object from a known [sourceType] to a [targetType]
  /// using full type metadata via [Class].
  ///
  /// This method provides the most powerful form of type conversion and
  /// supports deep, generic-aware resolution.
  ///
  /// ### Example:
  /// ```dart
  /// final source = {'date': '2025-07-01'};
  ///
  /// final targetType = Class.mapOf(Class<String>(), Class<DateTime>());
  /// final result = service.convertTo(source, Class.forObject(source), targetType);
  /// ```
  Object? convertTo<T>(Object? source, Class? sourceType, Class targetType);

  /// {@template conversion_service_get_uri_validators}
  /// Returns a list of registered [UriValidator] instances.
  ///
  /// This method is used to retrieve all registered validators for URI validation.
  ///
  /// ### Example:
  /// ```dart
  /// final validators = conversionService.getUriValidators();
  /// validators.forEach((validator) {
  ///   print(validator.errorMessage);
  /// });
  /// ```
  /// {@endtemplate}
  List<UriValidator> getUriValidators();
}

/// {@template configurable_conversion_service}
/// A configurable conversion service that allows dynamic registration of converters.
///
/// This interface is typically used during application bootstrap or module initialization
/// to register additional [Converter], [ConverterFactory], or [GenericConverter] instances
/// that will be used for type conversion across the framework.
///
/// ---
///
/// ### 🔧 Example Usage:
/// ```dart
/// final service = DefaultConversionService();
///
/// service.addConverter<String, int>(StringToIntConverter());
/// service.addConverterFactory<String, Enum>(StringToEnumConverterFactory());
/// service.addGenericConverter(MyCustomGenericConverter());
/// ```
///
/// See also:
/// - [ConversionService]
/// - [Converter]
/// - [ConverterFactory]
/// - [GenericConverter]
/// {@endtemplate}
abstract class ConfigurableConversionService implements ConversionService, ConverterRegistry {}