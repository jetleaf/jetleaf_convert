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