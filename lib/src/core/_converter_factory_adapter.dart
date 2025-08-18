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

@Generic(_ConverterFactoryAdapter)
class _ConverterFactoryAdapter implements ConditionalGenericConverter {
  final ConverterFactory<dynamic, dynamic> _converterFactory;
  final ConvertiblePair _typeInfo;
  final ProtectionDomain protectionDomain;
  final _NullSourceConverter _convertNullSource;

  _ConverterFactoryAdapter(this._converterFactory, this._typeInfo, this.protectionDomain, this._convertNullSource);

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