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

@Generic(_ConvertersForPair)
class _ConvertersForPair {
  final LinkedQueue<GenericConverter> _converters = LinkedQueue<GenericConverter>();

  void add(GenericConverter converter) {
    _converters.addFirst(converter);
  }

  GenericConverter? getConverter<S, T>(Class<S> sourceType, Class<T> targetType) {
    for (final converter in _converters) {
      if (converter is! ConditionalGenericConverter || converter.matches(sourceType, targetType)) {
        return converter;
      }
    }

    for (final converter in _converters) {
      if (converter is _ConverterAdapter && converter.matchesFallback(sourceType, targetType)) {
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