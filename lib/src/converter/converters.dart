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

import 'package:jetleaf_lang/lang.dart';

import '../convertible_pair.dart';

/// {@template conditional_converter}
/// A contract for a converter that only matches under certain conditions.
///
/// This is useful in frameworks where type conversion should occur only
/// if some custom logic (e.g., annotations, context, runtime checks) validates it.
///
/// You can implement this interface when you want to provide more
/// granular control over when a converter should be applied.
///
/// ---
///
/// ### 🔧 Example:
/// ```dart
/// class MyConditionalConverter implements ConditionalConverter {
///   @override
///   bool matches(Class sourceType, Class targetType) {
///     return sourceType.getType() == String && targetType.getType() == Uri;
///   }
/// }
/// ```
/// {@endtemplate}
abstract interface class ConditionalConverter {
  /// {@macro conditional_converter}
  ///
  /// Determines if the converter should apply for the given [sourceType] and [targetType].
  bool matches(Class sourceType, Class targetType);
}

/// {@template generic_converter}
/// A general-purpose converter that can convert between multiple source–target type pairs.
///
/// This interface allows conversion logic to be shared across multiple type mappings,
/// and optionally exposes the set of convertible type pairs.
///
/// ---
///
/// ### 🔧 Example:
/// ```dart
/// class MyConverter implements GenericConverter {
///   @override
///   Set<ConvertiblePair> getConvertibleTypes() => {
///     ConvertiblePair(Class<String>(), Class<int>())
///   };
///
///   @override
///   Object? convert(Object? source, Class sourceType, Class targetType) {
///     if (source is String && targetType.getType() == int) {
///       return int.tryParse(source);
///     }
///     return null;
///   }
/// }
/// ```
/// {@endtemplate}
abstract interface class GenericConverter {
  /// {@macro generic_converter}
  ///
  /// Returns the set of source–target type pairs that this converter supports.
  /// Can be `null` if the converter is conditional or uses runtime logic instead.
  Set<ConvertiblePair>? getConvertibleTypes();

  /// {@macro generic_converter}
  ///
  /// Converts the [source] object from [sourceType] to [targetType].
  ///
  /// Returns the converted value or `null` if the conversion fails or is unsupported.
  Object? convert<T>(Object? source, Class sourceType, Class targetType);

  @override
  String toString() => 'GenericConverter(${getConvertibleTypes()?.map((c) => c)})';
}

/// {@template conditional_generic_converter}
/// A bridge interface combining [GenericConverter] and [ConditionalConverter].
///
/// Use this when writing a generic converter that should only match under specific conditions.
///
/// ---
///
/// ### 🔧 Example:
/// ```dart
/// class ConditionalUriConverter extends ConditionalGenericConverter {
///   @override
///   Set<ConvertiblePair> getConvertibleTypes() => {
///     ConvertiblePair(Class<String>(), Class<Uri>())
///   };
///
///   @override
///   bool matches(TypeDescriptor sourceType, TypeDescriptor targetType) {
///     return sourceType.type == String && targetType.type == Uri;
///   }
///
///   @override
///   Object? convert(Object? source, TypeDescriptor sourceType, TypeDescriptor targetType) {
///     return Uri.tryParse(source as String);
///   }
/// }
/// ```
/// {@endtemplate}
abstract class ConditionalGenericConverter extends GenericConverter implements ConditionalConverter {}