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

@Generic(_NoOpConverter)
class _NoOpConverter implements GenericConverter {
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