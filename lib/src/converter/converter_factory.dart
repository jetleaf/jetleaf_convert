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

/// {@template converter_factory}
/// A factory for creating [Converter] instances that convert from a source type [S]
/// to a target type [T], where [T] is a subtype of [R].
///
/// This interface is useful when conversion logic needs to support multiple
/// target types derived from a common base type [R].
///
/// ---
///
/// ### 🔧 Example Usage:
/// ```dart
/// class StringToNumberConverterFactory implements ConverterFactory<String, num> {
///   @override
///   Converter<String, T> getConverter<T extends num>() {
///     if (T == int) {
///       return (IntStringConverter() as Converter<String, T>);
///     } else if (T == double) {
///       return (DoubleStringConverter() as Converter<String, T>);
///     }
///     throw ConversionException('No converter for type $T');
///   }
/// }
/// ```
/// {@endtemplate}
@Generic(ConverterFactory)
abstract interface class ConverterFactory<S, R> {
  /// {@macro converter_factory}
  ///
  /// Returns a [Converter] from type [S] to [T], where [T] must be a subtype of [R].
  ///
  /// Throws an [ConversionException] if the factory does not support the requested target type.
  Converter<S, T>? getConverter<T>(Class<T> targetType);
}