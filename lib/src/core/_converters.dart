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

// Fixed converters container with better lookup logic
class _Converters {
  final Set<GenericConverter> _globalConverters = <GenericConverter>{};
  final Map<ConvertiblePair, _ConvertersForPair> _converters = <ConvertiblePair, _ConvertersForPair>{};

  void add(GenericConverter converter) {
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

  void remove(Class<dynamic> sourceType, Class<dynamic> targetType) {
    _converters.remove(ConvertiblePair(sourceType, targetType));
  }

  GenericConverter? find<S, T>(Class<S> sourceType, Class<T> targetType) {
    // First try exact match
    final exactPair = ConvertiblePair(sourceType, targetType);
    final exactConverter = _getRegisteredConverter<S, T>(sourceType, targetType, exactPair);
    if (exactConverter != null) {
      return exactConverter;
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

  GenericConverter? _getRegisteredConverter<S, T>(Class<S> sourceType, Class<T> targetType, ConvertiblePair pair) {
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