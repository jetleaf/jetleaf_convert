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

import 'exceptions.dart';
import 'conversion_service/conversion_service.dart';
import 'converter/converters.dart';

/// {@template conversion_utils}
/// Utility class containing common operations used by conversion infrastructure.
///
/// This class provides static helper methods to:
/// - Safely invoke a [GenericConverter]
/// - Determine if element-wise conversion is possible
/// - Resolve the enum class from a type
///
/// {@endtemplate}
abstract class ConversionUtils {
  /// {@macro conversion_utils}
  ConversionUtils._();

  /// Invokes the provided [converter] with the given [source], [sourceType],
  /// and [targetType] descriptors, handling conversion failures appropriately.
  ///
  /// If a [ConversionFailedException] is thrown during conversion,
  /// it is rethrown directly. For any other [Exception], a new
  /// [ConversionFailedException] is thrown with context.
  ///
  /// ### 🔧 Example
  /// ```dart
  /// final result = ConversionUtils.invokeConverter(
  ///   myConverter,
  ///   '123',
  ///   Class.of(String),
  ///   Class.of(int),
  /// );
  /// ```
	static Object? invokeConverter<T>(GenericConverter converter, Object? source, Class sourceType, Class targetType) {
		try {
      print("Converting: $source - $sourceType - $targetType with $converter");
			return converter.convert<T>(source, sourceType, targetType);
		} on ConversionFailedException catch (_) {
			rethrow;
		} on Exception catch (ex) {
			throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: ex);
		} on Error catch (ex) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source, point: ex);
    }
	}

  /// Checks if a conversion from [source] to [target]
  /// is possible using the given [conversionService].
  ///
  /// - If [target] is `null`, conversion is considered allowed.
  /// - If [source] is `null`, conversion is potentially allowed.
  /// - Otherwise, it checks:
  ///   - If the conversion service can convert between the two descriptors.
  ///   - Or if the underlying Dart types are assignable.
  ///
  /// ### 🔧 Example
  /// ```dart
  /// bool result = ConversionUtils.canConvertElements(
  ///   Class.of(String),
  ///   Class.of(int),
  ///   myConversionService,
  /// );
  /// ```
	static bool canConvertElements(Class? source, Class? target, ConversionService conversionService) {
		if (target == null) {
			// yes
			return true;
		}
		if (source == null) {
			// maybe
			return true;
		}
		if (conversionService.canConvert(source, target)) {
			// yes
			return true;
		}
		if (source.isInstance(target)) {
			// maybe
			return true;
		}
		// no
		return false;
	}

	/// Resolves the enum class from the given [targetType].
	///
	/// - If [targetType] is an enum, returns it directly.
	/// - Otherwise, searches the superclass chain for an enum type.
	///
	/// Throws an [IllegalArgumentException] if no enum type is found.
	///
	/// ### 🔧 Example
	/// ```dart
	/// Class enumType = ConversionUtils.getEnumType(Class<MyEnum>());
	/// ```
	static Class getEnumType(Class? targetType) {
		while (targetType != null && !targetType.isEnum()) {
			targetType = targetType.getSuperClass();
		}
		assert(targetType != null, "The target type ${targetType?.getName()} does not refer to an enum");
		return targetType!;
	}
}