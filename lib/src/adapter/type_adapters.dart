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
import 'type_adapter.dart';

/// {@template list_adapter}
/// A `TypeAdapter` that adapts a raw [Object] into a strongly typed [List] of
/// type [E].
///
/// Jetleaf’s conversion service may return values like `Iterable<Object>`,
/// `List<Object>`, or `ArrayList`, which may represent a sequence of values.
/// This adapter ensures that the raw input is converted into a Dart `List<E>`.
///
/// - If [source] is `null`, an empty list is returned.
/// - If [source] is a `List`, it is directly converted using `List<E>.from`.
/// - If [source] is an `ArrayList`, each element is cast and added to a new list.
/// - Otherwise, an [IllegalArgumentException] is thrown.
///
/// ## Example
/// ```dart
/// final adapter = ListAdapter<int>();
/// final list = adapter.adapt([1, 2, 3]); // [1, 2, 3]
///
/// final rawArrayList = ArrayList()..addAll([10, 20, 30]);
/// final adapted = adapter.adapt(rawArrayList); // [10, 20, 30]
///
/// final empty = adapter.adapt(null); // []
/// ```
/// {@endtemplate}
@Generic(ListAdapter)
class ListAdapter<E> implements TypeAdapter<List<E>> {
  @override
  List<E> adapt(Object? source) {
    if (source == null) return <E>[];

    if (source is List) {
      return List<E>.from(source);
    }

    if (source is ArrayList) {
      final list = ArrayList<E>();
      for (var e in source) {
        list.add(e as E);
      }
      return list;
    }

    throw IllegalArgumentException('Cannot adapt $source to List<$E>');
  }
}

/// {@template map_adapter}
/// A `TypeAdapter` that adapts a raw [Object] into a strongly typed [Map] of
/// type [K, V].
///
/// Jetleaf’s conversion service may return `Map<Object, Object>` or `HashMap`,
/// which may represent key-value pairs. This adapter ensures that the raw input
/// is converted into a Dart `Map<K, V>`.
///
/// - If [source] is `null`, an empty map is returned.
/// - If [source] is a `Map`, it is directly converted using `Map<K, V>.from`.
/// - If [source] is a `HashMap`, entries are iterated and retyped.
/// - Otherwise, an [IllegalArgumentException] is thrown.
///
/// ## Example
/// ```dart
/// final adapter = MapAdapter<String, int>();
/// final map = adapter.adapt({'a': 1, 'b': 2}); // {a: 1, b: 2}
///
/// final rawHashMap = HashMap()
///   ..['x'] = 10
///   ..['y'] = 20;
/// final adapted = adapter.adapt(rawHashMap); // {x: 10, y: 20}
///
/// final empty = adapter.adapt(null); // {}
/// ```
/// {@endtemplate}
@Generic(MapAdapter)
class MapAdapter<K, V> implements TypeAdapter<Map<K, V>> {
  @override
  Map<K, V> adapt(Object? source) {
    if (source == null) return <K, V>{};

    if (source is Map) {
      return Map<K, V>.from(source);
    }

    if (source is HashMap) {
      final map = HashMap<K, V>();
      for (var e in source.entries) {
        map[e.key as K] = e.value as V;
      }
      return map;
    }

    throw IllegalArgumentException('Cannot adapt $source to Map<$K, $V>');
  }
}

/// {@template set_adapter}
/// A `TypeAdapter` that adapts a raw [Object] into a strongly typed [Set] of
/// type [E].
///
/// Jetleaf’s conversion service may return `Iterable<Object>`, `Set<Object>`,
/// or `HashSet`. This adapter ensures that the raw input is converted into a
/// Dart `Set<E>`.
///
/// - If [source] is `null`, an empty set is returned.
/// - If [source] is a `Set`, it is directly converted using `Set<E>.from`.
/// - If [source] is a `HashSet`, elements are cast and added to a new set.
/// - Otherwise, an [IllegalArgumentException] is thrown.
///
/// ## Example
/// ```dart
/// final adapter = SetAdapter<int>();
/// final set = adapter.adapt({1, 2, 3}); // {1, 2, 3}
///
/// final rawHashSet = HashSet()..addAll([5, 6, 7]);
/// final adapted = adapter.adapt(rawHashSet); // {5, 6, 7}
///
/// final empty = adapter.adapt(null); // {}
/// ```
/// {@endtemplate}
@Generic(SetAdapter)
class SetAdapter<E> implements TypeAdapter<Set<E>> {
  @override
  Set<E> adapt(Object? source) {
    if (source == null) return <E>{};

    if (source is Set) {
      return Set<E>.from(source);
    }

    if (source is HashSet) {
      final set = HashSet<E>();
      for (var e in source) {
        set.add(e as E);
      }
      return set;
    }

    throw IllegalArgumentException('Cannot adapt $source to Set<$E>');
  }
}

/// {@template type_adapter_extension}
/// Extension methods that simplify adapting `Object?` values into strongly
/// typed collections or custom types using Jetleaf's [TypeAdapter] system.
///
/// These helpers provide a convenient way to "upcast" raw dynamic data into
/// proper Dart types.
///
/// ## Example
/// ```dart
/// Object? rawList = [1, 2, 3];
/// final list = rawList.upcastToList<int>(); // [1, 2, 3]
///
/// Object? rawMap = {'a': 1, 'b': 2};
/// final map = rawMap.upcastToMap<String, int>(); // {a: 1, b: 2}
///
/// Object? rawSet = {10, 20, 30};
/// final set = rawSet.upcastToSet<int>(); // {10, 20, 30}
///
/// Object? value = 'hello';
/// final upper = value.upcast<String>((src) => src.toString().toUpperCase());
/// // "HELLO"
/// ```
/// {@endtemplate}
extension TypeAdapterExtension on Object? {
  /// {@macro type_adapter_extension}
  T? upcast<T>(T Function(Object? source) supplier) {
    if (this == null) return null;
    return supplier(this);
  }

  /// {@macro list_adapter}
  List<E> upcastToList<E>() => ListAdapter<E>().adapt(this);

  /// {@macro map_adapter}
  Map<K, V> upcastToMap<K, V>() => MapAdapter<K, V>().adapt(this);

  /// {@macro set_adapter}
  Set<E> upcastToSet<E>() => SetAdapter<E>().adapt(this);
}