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

/// {@template type_adapter}
/// A Jetleaf-specific adapter that lifts generic conversion results
/// into strongly-typed values.
///
/// Jetleaf's conversion service always returns results as `Object`
/// (e.g., `Map<Object, Object>` instead of `Map<int, String>`).
/// This design avoids runtime type conflicts but requires a way
/// to *adapt* those values into the precise type expected by the user.
///
/// The [TypeAdapter] abstraction provides that bridge.  
/// It allows both Jetleaf internals and user code to declare how
/// a raw `Object` from the conversion service should be transformed
/// into a fully typed value.
///
/// ### Why?
/// - Jetleaf avoids committing to a Dart type at the conversion layer.
/// - Dart’s type system is strict, so generic `Object` results need
///   adaptation to their concrete forms.
/// - Adapters guarantee that values are raised into the
///   expected type at the call site.
///
/// ### Example: Adapting to a typed map
/// ```dart
/// class StringIntMapAdapter extends TypeAdapter<Map<String, int>> {
///   @override
///   Map<String, int> adapt(Object? source) {
///     if (source is Map<Object, Object>) {
///       return source.map((k, v) => MapEntry(k as String, v as int));
///     }
///     throw ArgumentError('Cannot adapt $source to Map<String, int>');
///   }
/// }
///
/// final raw = <Object, Object>{'a': 1, 'b': 2};
/// final adapter = StringIntMapAdapter();
/// final typed = adapter.adapt(raw); // -> Map<String, int>
/// ```
///
/// ### Example: Adapting to a domain type
/// ```dart
/// class User {
///   final String name;
///   final int age;
///   User(this.name, this.age);
/// }
///
/// class UserAdapter extends TypeAdapter<User> {
///   @override
///   User adapt(Object? source) {
///     if (source is Map<Object, Object>) {
///       return User(source['name'] as String, source['age'] as int);
///     }
///     throw ArgumentError('Cannot adapt $source to User');
///   }
/// }
/// ```
///
/// Jetleaf itself uses adapters internally to ensure that results
/// from its conversion service are raised to the exact type
/// requested by the user.
/// {@endtemplate}
@Generic(TypeAdapter)
abstract interface class TypeAdapter<T> {
  /// {@macro type_adapter}
  T adapt(Object? source);
}