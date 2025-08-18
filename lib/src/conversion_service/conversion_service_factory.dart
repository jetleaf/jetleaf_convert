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

import '../converter/converter_factory.dart';
import '../converter/converter_registry.dart';
import '../converter/converters.dart';

/// {@template conversion_service_factory}
/// Utility class for registering a set of converters with a [ConverterRegistry].
///
/// This is used to bulk-register multiple converter objects, whether they
/// implement [Converter], [ConverterFactory], or [GenericConverter].
///
/// All converters are matched by type and registered accordingly. If any object
/// in the provided set does not implement one of the recognized interfaces,
/// an [IllegalArgumentException] is thrown.
///
/// ---
///
/// ### 🔧 Example
/// ```dart
/// final registry = DefaultConverterRegistry();
/// ConversionServiceFactory.registerConverters({
///   StringToIntConverter(),
///   StringToDateTimeConverter(),
///   StringToEnumConverterFactory(),
///   MyGenericConverter(),
/// }, registry);
/// ```
///
/// {@endtemplate}
final class ConversionServiceFactory {
  /// Prevents instantiation of this utility class.
  ConversionServiceFactory._();

  /// {@macro conversion_service_factory}
  ///
  /// Registers each converter in [converters] with the provided [registry].
  ///
  /// - If a converter is a [GenericConverter], it will be registered using [ConverterRegistry.addGenericConverter].
  /// - If it is a [Converter], it will be registered using [ConverterRegistry.addConverter].
  /// - If it is a [ConverterFactory], it will be registered using [ConverterRegistry.addConverterFactory].
  ///
  /// Throws [IllegalArgumentException] if any object in [converters] does not implement one of these types.
  static void registerConverters(Set<dynamic>? converters, ConverterRegistry registry) {
    if (converters != null) {
      for (Object candidate in converters) {
        if (candidate is GenericConverter) {
          registry.addGenericConverter(candidate);
        } else if (candidate is Converter<dynamic, dynamic>) {
          registry.addConverter(candidate);
        } else if (candidate is ConverterFactory<dynamic, dynamic>) {
          registry.addConverterFactory(candidate);
        } else {
          throw IllegalArgumentException("Each converter object must implement one of the "
              "Converter, ConverterFactory, or GenericConverter interfaces",
          );
        }
      }
    }
  }
}