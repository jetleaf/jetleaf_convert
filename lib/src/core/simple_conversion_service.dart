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

import '../exceptions.dart';
import '../helpers/conversion_utils.dart';
import '../helpers/convertible_pair.dart';
import '../helpers/_commons.dart';
import 'conversion_service.dart';
import 'converters.dart';

/// Handles nullability conversion
/// 
/// This function is used to convert a null value to a non-null value.
typedef _NullSourceConverter = Object? Function(Class? sourceType, Class targetType);

/// {@template simple_conversion_service}
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
/// final conversionService = SimpleConversionService();
///
/// // Register a converter
/// conversionService.addConverter(MyConverter());
///
/// // Perform conversion
/// final result = conversionService.convert(source, targetType);
/// ```
/// {@endtemplate}
/// {@endtemplate}
class SimpleConversionService implements ConfigurableConversionService {
  /// {@template no_op_converter}
  /// Singleton instance representing a no-operation converter.
  ///
  /// Used when source and target types are the same or compatible without conversion.
  /// {@endtemplate}
  static final PairedConverter _NO_OP_CONVERTER = _NoOpConverter("NO_OP");

  /// {@template no_match_converter}
  /// Singleton instance representing no matching converter.
  ///
  /// Used as a cache marker when no converter is found.
  /// {@endtemplate}
  static final PairedConverter _NO_MATCH_CONVERTER = _NoOpConverter("NO_MATCH");

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

  /// {@template null_converters}
  /// A list of generic null converters used for converting null values.
  ///
  /// This list is used to convert null values to other types.
  /// {@endtemplate}
  final List<GenericNullConverter> _nullConverters = [];

  /// {@template converter_cache}
  /// A cache of converters used for type conversion.
  ///
  /// This cache is used to store converters for type conversion.
  /// {@endtemplate}
  final Map<_ConverterCacheKey, PairedConverter> _converterCache = <_ConverterCacheKey, PairedConverter>{};

  /// {@template protection_domain}
  /// The protection domain used for type conversion.
  ///
  /// This protection domain is used to validate types before conversion.
  /// {@endtemplate}
  final ProtectionDomain _pd;

  /// {@template simple_conversion_service_constructor}
  /// Creates a new SimpleConversionService.
  ///
  /// Parameters:
  /// - [pd]: Optional protection domain for security (defaults to current)
  ///
  /// Example:
  /// ```dart
  /// // Basic instantiation
  /// final service = SimpleConversionService();
  ///
  /// // With custom protection domain
  /// final secureService = SimpleConversionService(myProtectionDomain);
  /// ```
  /// {@endtemplate}
  /// 
  /// {@macro simple_conversion_service}
  SimpleConversionService([ProtectionDomain? pd]) : _pd = pd ?? ProtectionDomain.system() {
    _nullConverters.add(_DefaultNullConverter());
  }

  // ============================================= CONVERTERS ===============================================

  @override
  void addConverter<S, T>(Converter<S, T> converter, {Class<S>? sourceType, Class<T>? targetType}) {
    if(sourceType != null && targetType != null) {
      addPairedConverter(_PairedConverterAdapter(converter, sourceType, targetType, _pd, _convertNullableSource));
    } else if(sourceType == null && targetType == null) {
      final clazz = converter.getClass(null, converter.getPackageName());

      // We'll try to access the [Converter] class as an interface first
      List<Class> types = clazz.getDeclaredInterface<Converter>()?.getTypeParameters() ?? [];
      
      // If it fails, we'll try to access it as a superclass
      if(types.isEmpty) {
        types = clazz.getDeclaredSuperClass()?.getTypeParameters() ?? [];
      }
      
      if (types.isEmpty || types.length.isLessThan(2)) {
        throw ConversionException(
          'Unable to determine source type and target type for your '
          'Converter [${converter.runtimeType}]; does the class parameterize those types? If '
          'you are using a generic converter, make sure to explicitly specify the source '
          'and target types.'
        );
      }
      addPairedConverter(_PairedConverterAdapter(converter, types.getFirst(), types.getLast(), _pd, _convertNullableSource));
    }
  }

  @override
  void addPairedConverter(PairedConverter converter) {
    _converters.add(converter);
    _invalidateCache();
  }

  /// {@template _invalidate_cache}
  /// Invalidates the cache of converters.
  ///
  /// Clears the cache of converters.
  /// {@endtemplate}
  void _invalidateCache() {
    _converterCache.clear();
  }

  @override
  void addConverterFactory(ConverterFactory<dynamic, dynamic> factory) {
    final clazz = factory.getClass(null, factory.getPackageName());
    // We'll try to access the [ConverterFactory] class as an interface first
    List<Class> types = clazz.getDeclaredInterface<ConverterFactory>()?.getTypeParameters() ?? [];
    
    // If it fails, we'll try to access it as a superclass
    if(types.isEmpty) {
      types = clazz.getDeclaredSuperClass()?.getTypeParameters() ?? [];
    }
    
    if (types.isEmpty || types.length.isLessThan(2)) {
      throw ConversionException('Unable to determine source type and target type for your '
          'ConverterFactory [${factory.runtimeType}]; does the class parameterize those types?');
    }
    addPairedConverter(_PairedConverterFactoryAdapter(factory, ConvertiblePair(types.getFirst(), types.getLast()), _pd, _convertNullableSource));
  }

  @override
  void remove(Class sourceType, Class targetType) {
    _converters.remove(sourceType, targetType);
    _invalidateCache();
  }

  // ========================================== HANDLING CONVERSION ===========================================

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
  T? convert<T>(Object? source, Class<T> targetType, [String? qualifiedName]) {
    Class? fromQualified = qualifiedName != null ? Class.fromQualifiedName(qualifiedName) : null;
    Class? fromSource = source != null ? _getSourceType(source) : null;
    final sourceType = fromQualified ?? fromSource;
    final result = convertTo<T>(source, targetType, sourceType);

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
  Object? convertTo<T>(Object? source, Class targetType, [Class? sourceType]) {
    sourceType ??= (source != null ? _getSourceType(source) : null);
    if (sourceType == null) {
      if (source != null) {
        throw ConversionException('Source must be [null] if source type == [null]');
      }
      return _handleResult<T>(null, targetType, _convertNullableSource(null, targetType));
    }

    if (source != null && !sourceType.isInstance(source)) {
      throw ConversionException('Source to convert from must be an instance of [$sourceType]; instead it was a [${source.runtimeType}]');
    }

    final converter = _getConverter(sourceType, targetType);
    if (converter != null) {
      final result = ConversionUtils.invoke<T>(converter, source, sourceType, targetType);
      return _handleResult<T>(sourceType, targetType, result);
    }

    return _handleConverterNotFound<T>(source, sourceType, targetType);
  }

  /// {@template _get_converter}
  /// Internal method to find a converter with caching.
  ///
  /// First checks cache, then searches the converter registry.
  /// Returns null if no converter is found.
  /// {@endtemplate}
  PairedConverter? _getConverter(Class sourceType, Class targetType) {
    final key = _ConverterCacheKey(sourceType, targetType);
    PairedConverter? converter = _converterCache[key];

    if (converter != null) {
      return converter != _NO_MATCH_CONVERTER ? converter : null;
    }

    converter = _converters.find(sourceType, targetType);
    converter ??= _getDefaultConverter(sourceType, targetType);

    if (converter != null) {
      _converterCache[key] = converter;
      return converter;
    }

    _converterCache[key] = _NO_MATCH_CONVERTER;
    return null;
  }

  /// {@template _get_default_converter}
  /// Internal method to find a default converter.
  ///
  /// Returns null if no converter is found.
  /// {@endtemplate}
  PairedConverter? _getDefaultConverter(Class sourceType, Class targetType) {
    return sourceType.isAssignableTo(targetType) ? _NO_OP_CONVERTER : null;
  }

  /// {@template _convert_null_source}
  /// Converts a null source to a target type.
  ///
  /// If the target type is an Optional, returns an empty Optional.
  /// Otherwise, returns null.
  /// {@endtemplate}
  Object? _convertNullableSource(Class? sourceType, Class targetType) {
    return _genericNullConverter(sourceType, targetType).convert(sourceType, targetType);
  }

  /// {@template _generic_null_converter}
  /// Internal method to find a generic null converter.
  ///
  /// Returns a null converter if no converter is found.
  /// {@endtemplate}
  GenericNullConverter _genericNullConverter(Class? sourceType, Class targetType) {
    // 1. Check user-registered null converters
    final converter = _nullConverters.find((c) => c.matches(sourceType ?? Class<Object>(null, PackageNames.DART), targetType));

    // 2. Default fallback
    return converter ?? _DefaultNullConverter();
  }

  /// {@template _handle_converter_not_found}
  /// Handles cases when no converter is found.
  ///
  /// Either returns the source directly (if types are compatible)
  /// or throws a ConverterNotFoundException.
  /// {@endtemplate}
  Object? _handleConverterNotFound<T>(Object? source, Class? sourceType, Class targetType) {
    if (source == null) {
      _assertNotAPrimitiveTargetType(sourceType, targetType);
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
      _assertNotAPrimitiveTargetType(sourceType, targetType);
    }
    return result;
  }

  /// {@template _assert_not_primitive_target_type}
  /// Asserts that the target type is not primitive.
  ///
  /// Throws a ConversionFailedException if the target type is primitive.
  /// {@endtemplate}
  void _assertNotAPrimitiveTargetType(Class? sourceType, Class targetType) {
    if (targetType.isPrimitive()) {
      throw ConversionFailedException(
        sourceType: sourceType,
        targetType: targetType,
        value: null,
        point: ConversionException('A null value cannot be assigned to a primitive type')
      );
    }
  }

  // ======================================= NULL SOURCE CONVERTER ========================================

  @override
  void addNullSourceConverter(GenericNullConverter converter) {
    _nullConverters.add(converter);
  }

  @override
  void removeNullSourceConverter(GenericNullConverter converter) {
    _nullConverters.remove(converter);
  }

  // =========================================== URI VALIDATOR ==================================================

  @override
  List<UriValidator> getUriValidators() => _uriValidators;

  @override
  void addUriValidator(UriValidator validator) {
    _uriValidators.add(validator);
  }

  @override
  void removeUriValidator(UriValidator validator) {
    _uriValidators.remove(validator);
    _uriValidators.removeWhere((v) => v.errorMessage == validator.errorMessage);
  }

  @override
  String toString() => "$runtimeType(${_converters.toString()})";
}

/// {@template converter_cache_key}
/// A key used to cache converter lookups.
/// 
/// ---
/// 
/// ### 🔧 Example:
/// ```dart
/// final key = _ConverterCacheKey(Class.of<String>(), Class.of<int>());
/// ```
/// {@endtemplate}
@Generic(_ConverterCacheKey)
class _ConverterCacheKey implements Comparable<_ConverterCacheKey> {
  final Class sourceType;
  final Class targetType;

  _ConverterCacheKey(this.sourceType, this.targetType);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _ConverterCacheKey &&
            sourceType == other.sourceType &&
            targetType == other.targetType);
  }

  @override
  int get hashCode => sourceType.hashCode * 29 + targetType.hashCode;

  @override
  String toString() {
    return 'ConverterCacheKey [sourceType = $sourceType, targetType = $targetType]';
  }

  @override
  int compareTo(_ConverterCacheKey other) {
    int result = sourceType.getName().compareTo(other.sourceType.getName());
    if (result == 0) {
      result = targetType.getName().compareTo(other.targetType.getName());
    }
    return result;
  }
}

/// {@template converters_for_pair}
/// A container for converters that can be used to convert between two types.
/// 
/// ---
/// 
/// ### 🔧 Example:
/// ```dart
/// final converters = _ConvertersForPair();
/// converters.add(PairedConverter());
/// ```
/// {@endtemplate}
@Generic(_ConvertersForPair)
class _ConvertersForPair {
  final LinkedQueue<PairedConverter> _converters = LinkedQueue<PairedConverter>();

  void add(PairedConverter converter) {
    _converters.addFirst(converter);
  }

  PairedConverter? getConverter<S, T>(Class<S> sourceType, Class<T> targetType) {
    for (final converter in _converters) {
      if (converter is! PairedConditionalConverter || converter.matches(sourceType, targetType)) {
        return converter;
      }
    }

    for (final converter in _converters) {
      if (converter is _PairedConverterAdapter && converter.matchesFallback(sourceType, targetType)) {
        return converter;
      }
    }

    return null;
  }

  @override
  String toString() {
    return _converters.join(', ');
  }
}

/// {@template converters}
/// A container for converters that can be used to convert between two types.
/// 
/// ---
/// 
/// ### 🔧 Example:
/// ```dart
/// final converters = _Converters();
/// converters.add(PairedConverter());
/// ```
/// {@endtemplate}
class _Converters {
  final Set<PairedConverter> _globalConverters = <PairedConverter>{};
  final Map<ConvertiblePair, _ConvertersForPair> _converters = <ConvertiblePair, _ConvertersForPair>{};

  void add(PairedConverter converter) {
    final convertibleTypes = converter.getConvertibleTypes();
    if (convertibleTypes == null) {
      if (converter is! ConditionalConverter) {
        throw IllegalStateException('Only conditional converters may return null convertible types');
      }
      _globalConverters.add(converter);
    } else {
      for (final pair in convertibleTypes) {
        _getMatchableConverters(pair).add(converter);
      }
    }
  }

  _ConvertersForPair _getMatchableConverters(ConvertiblePair pair) {
    return _converters.putIfAbsent(pair, () => _ConvertersForPair());
  }

  void remove(Class sourceType, Class targetType) {
    _converters.remove(ConvertiblePair(sourceType, targetType));
  }

  PairedConverter? find<S, T>(Class<S> sourceType, Class<T> targetType) {
    // First try exact match
    final pair = ConvertiblePair(sourceType, targetType);
    final converter = _getRegisteredConverter<S, T>(sourceType, targetType, pair);
    if (converter != null) {
      return converter;
    }

    // Then try class hierarchy
    final sourceCandidates = ClassUtils.getClassHierarchy(sourceType);
    final targetCandidates = ClassUtils.getClassHierarchy(targetType);

    for (final sourceCandidate in sourceCandidates) {
      for (final targetCandidate in targetCandidates) {
        final pair = ConvertiblePair(sourceCandidate, targetCandidate);
        final converter = _getRegisteredConverter<S, T>(sourceType, targetType, pair);
        if (converter != null) {
          return converter;
        }
      }
    }

    return null;
  }

  PairedConverter? _getRegisteredConverter<S, T>(Class<S> sourceType, Class<T> targetType, ConvertiblePair pair) {
    // Check specifically registered converters
    final convertersForPair = _converters[pair];
    if (convertersForPair != null) {
      final converter = convertersForPair.getConverter<S, T>(sourceType, targetType);
      if (converter != null) {
        return converter;
      }
    }

    // Check ConditionalConverters for a dynamic match
    for (final globalConverter in _globalConverters) {
      if ((globalConverter as ConditionalConverter).matches(sourceType, targetType)) {
        return globalConverter;
      }
    }

    return null;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('ConversionService converters =');
    for (final converterString in _getConverterStrings()) {
      buffer.write('\t');
      buffer.write(converterString);
      buffer.writeln();
    }
    return buffer.toString();
  }

  List<String> _getConverterStrings() {
    final converterStrings = <String>[];
    for (final convertersForPair in _converters.values) {
      converterStrings.add(convertersForPair.toString());
    }
    converterStrings.sort();
    return converterStrings;
  }
}

/// {@template no_op_converter}
/// A converter that does nothing.
/// 
/// ---
/// 
/// ### 🔧 Example:
/// ```dart
/// final converter = _NoOpConverter('no_op_converter');
/// ```
/// {@endtemplate}
@Generic(_NoOpConverter)
class _NoOpConverter extends CommonPairedConverter {
  final String name;

  _NoOpConverter(this.name);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return null;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    return source;
  }

  @override
  String toString() {
    return name;
  }
}

/// {@template paired_converter_adapter}
/// A converter adapter that adapts a converter to a paired converter.
/// 
/// ---
/// 
/// ### 🔧 Example:
/// ```dart
/// final converter = _PairedConverterAdapter(converter, sourceType, targetType, domain, convertNullSource);
/// ```
/// {@endtemplate}
@Generic(_PairedConverterAdapter)
class _PairedConverterAdapter extends CommonPairedConditionalConverter {
  final Converter _converter;
  final ConvertiblePair _typeInfo;
  final _NullSourceConverter _convertNullSource;

  _PairedConverterAdapter(
    Converter converter,
    Class sourceType,
    Class targetType,
    ProtectionDomain domain,
    _NullSourceConverter convertNullSource,
  )  : _converter = converter, _typeInfo = ConvertiblePair(sourceType, targetType), _convertNullSource = convertNullSource;

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {_typeInfo};

  @override
  bool matches(Class sourceType, Class targetType) {
    final target = _typeInfo.getTargetType();
    final source = _typeInfo.getSourceType();

    bool canApplyToSource = source.getType() == sourceType.getType() || source.isAssignableFrom(sourceType);
    bool canApplyToTarget = target.getType() == targetType.getType() || target.isAssignableFrom(targetType);

    if(canApplyToSource && canApplyToTarget) {
      return true;
    }
    
    // Improved matching logic
    if (target.getType() != targetType.getType()) {
      return false;
    }

    if (target.getType() != targetType.getType() && !target.isAssignableFrom(targetType)) {
      return false;
    }

    if(ConvertiblePair(source, target) == ConvertiblePair(sourceType, targetType)) {
      return true;
    }

    return _converter is! ConditionalConverter || (_converter as ConditionalConverter).matches(sourceType, targetType);
  }

  bool matchesFallback(Class sourceType, Class targetType) {
    return _typeInfo.getTargetType().getType() == targetType.getType() &&
        (_converter is! ConditionalConverter ||
            (_converter as ConditionalConverter).matches(sourceType, targetType));
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) {
      return _convertNullSource(sourceType, targetType);
    }
    return _converter.convert(source);
  }

  @override
  String toString() {
    return '$_typeInfo : $_converter';
  }
}

/// {@template paired_converter_factory_adapter}
/// A converter factory adapter that adapts a converter factory to a paired converter.
/// 
/// ---
/// 
/// ### 🔧 Example:
/// ```dart
/// final converter = _PairedConverterFactoryAdapter(converterFactory, typeInfo, domain, convertNullSource);
/// ```
/// {@endtemplate}
@Generic(_PairedConverterFactoryAdapter)
class _PairedConverterFactoryAdapter extends CommonPairedConditionalConverter {
  final ConverterFactory<dynamic, dynamic> _converterFactory;
  final ConvertiblePair _typeInfo;
  final ProtectionDomain domain;
  final _NullSourceConverter _convertNullSource;

  _PairedConverterFactoryAdapter(this._converterFactory, this._typeInfo, this.domain, this._convertNullSource);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {_typeInfo};
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    bool matches = true;
    if (_converterFactory is ConditionalConverter) {
      matches = (_converterFactory as ConditionalConverter).matches(sourceType, targetType);
    }

    if (matches) {
      final converter = _converterFactory.getConverter(targetType);
      if (converter is ConditionalConverter) {
        matches = (converter as ConditionalConverter).matches(sourceType, targetType);
      }
    }

    return matches;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) {
      return _convertNullSource(sourceType, targetType);
    }

    final converter = _converterFactory.getConverter(targetType);
    return converter?.convert(source);
  }

  @override
  String toString() {
    return '$_typeInfo : $_converterFactory';
  }
}

/// {@template default_null_converter}
/// A default null converter that converts null to an empty optional.
/// 
/// ---
/// 
/// ### 🔧 Example:
/// ```dart
/// final converter = _DefaultNullConverter();
/// ```
/// {@endtemplate}
class _DefaultNullConverter implements GenericNullConverter {
  @override
  Object? convert(Class? sourceType, Class targetType) {
    return null;
  }

  @override
  bool matches(Class sourceType, Class targetType) => true;
}