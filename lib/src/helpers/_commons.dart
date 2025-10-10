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

import '../core/converters.dart';

/// Base class for common [Converter] implementations that operate
/// between types [S] (source) and [T] (target).
///
/// This ensures that all converters in this family share the
/// standard `PackageNames.CONVERT` namespace.
///
/// Example:
/// ```dart
/// class StringToIntConverter extends CommonConverter<String, int> {
///   @override
///   int convert(String source) => int.parse(source);
/// }
/// ```
@Generic(CommonConverter)
abstract class CommonConverter<S, T> implements Converter<S, T> {
  @override
  String getPackageName() => PackageNames.CONVERT;
}

/// Base class for paired converters (two-way converters).
///
/// A paired converter defines conversion in both directions
/// between two types.
///
/// All implementations are automatically registered under
/// `PackageNames.CONVERT`.
abstract class CommonPairedConverter implements PairedConverter {
  @override
  String getPackageName() => PackageNames.CONVERT;
}

/// Base class for paired converters with conditional conversion logic.
///
/// Unlike [CommonPairedConverter], these converters may only be
/// applicable under certain conditions (runtime checks, format
/// constraints, etc.).
///
/// Still registered under the `PackageNames.CONVERT` namespace.
abstract class CommonPairedConditionalConverter extends PairedConditionalConverter {
  @override
  String getPackageName() => PackageNames.CONVERT;
}

/// Base class for [ConverterFactory] implementations that produce
/// converters from type [S] (source) to type [R] (result).
///
/// Provides consistency by always using the `PackageNames.CONVERT`
/// namespace.
@Generic(CommonConverterFactory)
abstract class CommonConverterFactory<S, R> implements ConverterFactory<S, R> {
  @override
  String getPackageName() => PackageNames.CONVERT;
}

// ---------------------------------------------------------------------------
// Core Type References
// ---------------------------------------------------------------------------

/// Reference to the Dart core [String] type.
final STRING = Class<String>(null, PackageNames.DART);

/// Reference to the Dart core [int] type.
final INT = Class<int>(null, PackageNames.DART);

/// Reference to the Dart core [num] type.
final NUM = Class<num>(null, PackageNames.DART);

/// Reference to the Dart core [double] type.
final DOUBLE = Class<double>(null, PackageNames.DART);

/// Reference to the Dart core [bool] type.
final BOOL = Class<bool>(null, PackageNames.DART);

/// Reference to the Dart core [BigInt] type.
final BIG_INT = Class<BigInt>(null, PackageNames.DART);

/// Reference to the JetLeaf [Long] type.
final LONG = Class<Long>(null, PackageNames.LANG);

/// Reference to the JetLeaf [Integer] type.
final INTEGER = Class<Integer>(null, PackageNames.LANG);

/// Reference to the JetLeaf [BigInteger] type.
final BIG_INTEGER = Class<BigInteger>(null, PackageNames.LANG);

/// Reference to the JetLeaf [BigDecimal] type.
final BIG_DECIMAL = Class<BigDecimal>(null, PackageNames.LANG);

/// Reference to the JetLeaf [Float] type.
final FLOAT = Class<Float>(null, PackageNames.LANG);

/// Reference to the JetLeaf [Boolean] type.
final BOOLEAN = Class<Boolean>(null, PackageNames.LANG);

/// Reference to the JetLeaf [Character] type.
final CHARACTER = Class<Character>(null, PackageNames.LANG);