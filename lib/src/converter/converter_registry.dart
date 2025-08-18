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

import 'converter_factory.dart';
import 'converters.dart';

/// {@template converter_registry}
/// A registry of converters and converter factories used to perform type
/// conversions at runtime.
///
/// This is a central extension point for registering:
/// - Simple [Converter] instances
/// - [ConverterFactory] instances that produce converters based on target type
/// - [GenericConverter] instances that support complex or multi-type conversion
///
/// All registered converters can later be used by a [ConversionService]
/// to perform conversions between types.
///
/// ---
///
/// ### 🔧 Example
/// ```dart
/// final registry = MyConverterRegistry();
/// registry.addConverter(StringToIntConverter());
/// registry.addConverterWithClass(Class<String>(), Class<DateTime>(), StringToDateTimeConverter());
/// registry.addConverterFactory(StringToEnumConverterFactory());
/// ```
///
/// {@endtemplate}
abstract class ConverterRegistry {
  /// {@macro converter_registry}
  const ConverterRegistry();

  /// Registers a simple [Converter] from one specific source type to one target type.
  ///
  /// ---  
  /// ### 🔧 Example
  /// ```dart
  /// registry.addConverter(StringToIntConverter());
  /// ```
  void addConverter(Converter<dynamic, dynamic> converter);

  /// Registers a [Converter] for a specific pair of source and target types.
  ///
  /// This is useful when you want to register a converter for generic or erased
  /// types where inference isn't enough.
  ///
  /// ---  
  /// ### 🔧 Example
  /// ```dart
  /// registry.addConverterWithClass(
  ///   Class<String>(),
  ///   Class<DateTime>(),
  ///   StringToDateTimeConverter(),
  /// );
  /// ```
  void addConverterWithClass<S, T>(Class<S> sourceType, Class<T> targetType, Converter<S, T> converter);

  /// Registers a [GenericConverter] capable of converting between multiple types.
  ///
  /// A [GenericConverter] typically implements a more flexible contract than [Converter].
  ///
  /// ---  
  /// ### 🔧 Example
  /// ```dart
  /// registry.addGenericConverter(MyFlexibleGenericConverter());
  /// ```
  void addGenericConverter(GenericConverter converter);

  /// Registers a [ConverterFactory] that can produce [Converter] instances for a target type.
  ///
  /// ---  
  /// ### 🔧 Example
  /// ```dart
  /// registry.addConverterFactory(StringToEnumConverterFactory());
  /// ```
  void addConverterFactory(ConverterFactory<dynamic, dynamic> converterFactory);

  /// Removes a registered converter between the specified source and target types.
  ///
  /// ---  
  /// ### 🔧 Example
  /// ```dart
  /// registry.removeConvertible(Class<String>(), Class<int>());
  /// ```
  void removeConvertible(Class<dynamic> sourceType, Class<dynamic> targetType);
}