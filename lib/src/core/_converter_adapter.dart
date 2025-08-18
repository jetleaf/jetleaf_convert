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

part of 'generic_conversion_service.dart';

// Helper classes remain the same but with improved matching
@Generic(_ConverterAdapter)
class _ConverterAdapter implements ConditionalGenericConverter {
  final Converter<Object?, Object?> _converter;
  final ConvertiblePair _typeInfo;
  final Class _targetTypeClass;
  final _NullSourceConverter _convertNullSource;

  _ConverterAdapter(
    Converter<dynamic, dynamic> converter,
    Class sourceType,
    Class targetType,
    ProtectionDomain protectionDomain,
    _NullSourceConverter convertNullSource,
  )  : _converter = converter as Converter<Object?, Object?>,
        _typeInfo = ConvertiblePair(sourceType, targetType),
        _targetTypeClass = targetType,
        _convertNullSource = convertNullSource;

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {_typeInfo};
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    // Improved matching logic
    if (_typeInfo.getTargetType().getType() != targetType.getType()) {
      return false;
    }

    if (_targetTypeClass.getType() != targetType.getType() && !_targetTypeClass.isAssignableFrom(targetType)) {
      return false;
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