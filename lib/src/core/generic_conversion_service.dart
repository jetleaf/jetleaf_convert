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

import '../exceptions.dart';
import '../conversion_utils.dart';
import '../converter/converter_factory.dart';
import '../converter/converters.dart';
import '../convertible_pair.dart';
import '../conversion_service/conversion_service.dart';

part '_converter_adapter.dart';
part '_converter_cache_key.dart';
part '_converter_factory_adapter.dart';
part '_converters_for_pair.dart';
part '_converters.dart';
part '_no_op_converter.dart';

/// Handles nullability conversion
typedef _NullSourceConverter = Object? Function(Class? sourceType, Class targetType);

/// {@template generic_conversion_service}
/// A comprehensive type conversion service that handles conversion between different types.
///
/// This service provides:
/// - Registration of converters and converter factories
/// - Type conversion with null safety
/// - Caching for improved performance
/// - Support for primitive type conversions
/// - Optional type handling
///
/// {@template conversion_service_features}
/// ## Key Features
/// - Converter registration and management
/// - Type hierarchy-aware conversion
/// - Null safety and primitive type handling
/// - Converter caching for performance
/// - Optional type support
/// {@endtemplate}
///
/// {@template conversion_service_usage}
/// ## Basic Usage
///
/// ```dart
/// final conversionService = GenericConversionService();
///
/// // Register a converter
/// conversionService.addConverter(MyConverter());
///
/// // Perform conversion
/// final result = conversionService.convert(source, targetType);
/// ```
/// {@endtemplate}
/// {@endtemplate}
class GenericConversionService implements ConfigurableConversionService {
  /// {@template no_op_converter}
  /// Singleton instance representing a no-operation converter.
  ///
  /// Used when source and target types are the same or compatible without conversion.
  /// {@endtemplate}
  static final GenericConverter _NO_OP_CONVERTER = _NoOpConverter("NO_OP");

  /// {@template no_match_converter}
  /// Singleton instance representing no matching converter.
  ///
  /// Used as a cache marker when no converter is found.
  /// {@endtemplate}
  static final GenericConverter _NO_MATCH = _NoOpConverter("NO_MATCH");

  /// {@template converters}
  /// A collection of registered converters and converter factories.
  ///
  /// This collection is used to find and cache converters for type conversion.
  /// {@endtemplate}
  final _Converters _converters = _Converters();

  /// {@template uri_validators}
  /// A list of URI validators used for validating URIs.
  ///
  /// This list is used to validate URIs before conversion.
  /// {@endtemplate}
  final List<UriValidator> _uriValidators = [];

  /// {@template converter_cache}
  /// A cache of converters used for type conversion.
  ///
  /// This cache is used to store converters for type conversion.
  /// {@endtemplate}
  final Map<_ConverterCacheKey, GenericConverter> _converterCache = <_ConverterCacheKey, GenericConverter>{};

  /// {@template protection_domain}
  /// The protection domain used for type conversion.
  ///
  /// This protection domain is used to validate types before conversion.
  /// {@endtemplate}
  final ProtectionDomain _protectionDomain;

  /// {@template generic_conversion_service_constructor}
  /// Creates a new GenericConversionService.
  ///
  /// Parameters:
  /// - [protectionDomain]: Optional protection domain for security (defaults to current)
  ///
  /// Example:
  /// ```dart
  /// // Basic instantiation
  /// final service = GenericConversionService();
  ///
  /// // With custom protection domain
  /// final secureService = GenericConversionService(myProtectionDomain);
  /// ```
  /// {@endtemplate}
  /// 
  /// {@macro generic_conversion_service}
  GenericConversionService([ProtectionDomain? protectionDomain])
      : _protectionDomain = protectionDomain ?? ProtectionDomain.current();

  @override
  void addConverter(Converter<dynamic, dynamic> converter) {
    final types = converter.getClass().getDeclaredSuperClass()?.getTypeParameters() ?? [];
    if (types.isEmpty || types.length.isLessThan(2)) {
      throw ConversionException('Unable to determine source type and target type for your '
          'Converter [${converter.runtimeType}]; does the class parameterize those types?');
    }
    addGenericConverter(_ConverterAdapter(converter, types.getFirst(), types.getLast(), _protectionDomain, _convertNullSource));
  }

  @override
  void addConverterWithClass<S, T>(Class<S> sourceType, Class<T> targetType, Converter<S, T> converter) {
    addGenericConverter(_ConverterAdapter(converter, sourceType, targetType, _protectionDomain, _convertNullSource));
  }

  @override
  void addGenericConverter(GenericConverter converter) {
    _converters.add(converter);
    _invalidateCache();
  }

  @override
  void addConverterFactory(ConverterFactory<dynamic, dynamic> factory) {
    final types = factory.getClass().getDeclaredInterfaceArguments<ConverterFactory>();
    if (types.isEmpty || types.length.isLessThan(2)) {
      throw ConversionException('Unable to determine source type and target type for your '
          'ConverterFactory [${factory.runtimeType}]; does the class parameterize those types?');
    }
    addGenericConverter(_ConverterFactoryAdapter(factory, ConvertiblePair(types.getFirst(), types.getLast()), _protectionDomain, _convertNullSource));
  }

  @override
  void removeConvertible(Class<dynamic> sourceType, Class<dynamic> targetType) {
    _converters.remove(sourceType, targetType);
    _invalidateCache();
  }

  @override
  bool canConvert(Class? sourceType, Class targetType) {
    if (sourceType == null) return true;
    return _getConverter(sourceType, targetType) != null;
  }

  /// Return whether conversion between the source type and the target type can be bypassed.
  /// More precisely, this method will return true if objects of sourceType can be
  /// converted to the target type by returning the source object unchanged.
  /// 
  /// -- Parameters --
  /// @param sourceType context about the source type to convert from
  /// @param targetType context about the target type to convert to (required)
  /// 
  /// -- Returns --
  /// @return true if conversion can be bypassed; false otherwise
  bool canBypassConvert(Class? sourceType, Class targetType) {
    if (sourceType == null) return true;
    return _getConverter(sourceType, targetType) == _NO_OP_CONVERTER;
  }

  @override
  T? convert<T>(Object? source, Class<T> targetType) {
    final sourceType = source != null ? _getSourceType(source) : null;
    final result = convertTo<T>(source, sourceType, targetType);

    if(result != null) {
      return result as T;
    } else {
      return result as T?;
    }
  }

  Class _getSourceType(Object source) {
    if(source is Class) {
      return source;
    } else {
      return source.getClass();
    }
  }

  @override
  Object? convertTo<T>(Object? source, Class? sourceType, Class targetType) {
    if (sourceType == null) {
      if (source != null) {
        throw ConversionException('Source must be [null] if source type == [null]');
      }
      return _handleResult<T>(null, targetType, _convertNullSource(null, targetType));
    }

    if (source != null && !sourceType.isInstance(source)) {
      throw ConversionException('Source to convert from must be an instance of [$sourceType]; instead it was a [${source.runtimeType}]');
    }

    final converter = _getConverter(sourceType, targetType);
    if (converter != null) {
      final result = ConversionUtils.invokeConverter<T>(converter, source, sourceType, targetType);
      return _handleResult<T>(sourceType, targetType, result);
    }

    return _handleConverterNotFound<T>(source, sourceType, targetType);
  }

  @override
  Object? convertWithClass<T>(Object? source, Class targetType) {
    return convertTo<T>(source, source != null ? _getSourceType(source) : null, targetType);
  }

  @override
  String toString() => _converters.toString();

  /// {@template _get_converter}
  /// Internal method to find a converter with caching.
  ///
  /// First checks cache, then searches the converter registry.
  /// Returns null if no converter is found.
  /// {@endtemplate}
  GenericConverter? _getConverter(Class sourceType, Class targetType) {
    final key = _ConverterCacheKey(sourceType, targetType);
    GenericConverter? converter = _converterCache[key];

    if (converter != null) {
      return converter != _NO_MATCH ? converter : null;
    }

    converter = _converters.find(sourceType, targetType);
    converter ??= _getDefaultConverter(sourceType, targetType);

    if (converter != null) {
      _converterCache[key] = converter;
      return converter;
    }

    _converterCache[key] = _NO_MATCH;
    return null;
  }

  /// {@template _get_default_converter}
  /// Internal method to find a default converter.
  ///
  /// Returns null if no converter is found.
  /// {@endtemplate}
  GenericConverter? _getDefaultConverter(Class sourceType, Class targetType) {
    return sourceType.isAssignableTo(targetType) ? _NO_OP_CONVERTER : null;
  }

  /// {@template _convert_null_source}
  /// Converts a null source to a target type.
  ///
  /// If the target type is an Optional, returns an empty Optional.
  /// Otherwise, returns null.
  /// {@endtemplate}
  Object? _convertNullSource(Class? sourceType, Class targetType) {
    if (targetType.getName().startsWith('Optional<') || targetType.getType() == Optional) {
      return Optional.empty();
    }

    return null;
  }

  /// {@template _invalidate_cache}
  /// Invalidates the cache of converters.
  ///
  /// Clears the cache of converters.
  /// {@endtemplate}
  void _invalidateCache() {
    _converterCache.clear();
  }

  /// {@template _handle_converter_not_found}
  /// Handles cases when no converter is found.
  ///
  /// Either returns the source directly (if types are compatible)
  /// or throws a ConverterNotFoundException.
  /// {@endtemplate}
  Object? _handleConverterNotFound<T>(Object? source, Class? sourceType, Class targetType) {
    if (source == null) {
      _assertNotPrimitiveTargetType(sourceType, targetType);
      return null;
    }

    if ((sourceType == null || targetType.isAssignableFrom(sourceType)) && targetType.isInstance(source)) {
      return source;
    }

    throw ConverterNotFoundException(sourceType: sourceType, targetType: targetType);
  }

  /// {@template _handle_result}
  /// Handles the result of a conversion.
  ///
  /// Asserts that the result is not null for primitive target types.
  /// {@endtemplate}
  Object? _handleResult<T>(Class? sourceType, Class targetType, Object? result) {
    if (result == null) {
      _assertNotPrimitiveTargetType(sourceType, targetType);
    }
    return result;
  }

  /// {@template _assert_not_primitive_target_type}
  /// Asserts that the target type is not primitive.
  ///
  /// Throws a ConversionFailedException if the target type is primitive.
  /// {@endtemplate}
  void _assertNotPrimitiveTargetType(Class? sourceType, Class targetType) {
    if (targetType.isPrimitive()) {
      throw ConversionFailedException(
        sourceType: sourceType,
        targetType: targetType,
        value: null,
        point: ConversionException('A null value cannot be assigned to a primitive type')
      );
    }
  }

  @override
  List<UriValidator> getUriValidators() => _uriValidators;
}