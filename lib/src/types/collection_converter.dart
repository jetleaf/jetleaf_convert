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

import 'dart:collection' as col;

import 'package:jetleaf_lang/lang.dart';

import '../conversion_service/conversion_service.dart';
import '../conversion_utils.dart';
import '../converter/converters.dart';
import '../convertible_pair.dart';

/// {@template collection_to_collection_converter}
/// An abstract base class for converting between different types of Dart collections,
/// with optional element type conversion.
///
/// This converter works by:
/// 1. Checking if the source type matches the expected `_sourceDartType`.
/// 2. Verifying that the target type is a supported collection type.
/// 3. Converting each element if type information is available.
///
/// ### Supported target types include:
/// - `List`, `Set`, `Iterable`, `Queue`
/// - `ArrayList`, `HashSet`, `LinkedQueue`, `LinkedList`, `LinkedStack`, `Stack`
/// - `col.LinkedHashSet`, `col.ListBase`, `col.SetBase`, `col.Queue`
///
/// ### Example:
/// ```dart
/// final service = ConversionService(); // Your implementation
/// final converter = ListToCollectionConverter(service);
///
/// final source = [1, 2, 3];
/// final result = converter.convert(
///   source,
///   Class.forType(List),
///   Class.forType(Set),
/// );
///
/// print(result.runtimeType); // Set<int>
/// ```
///
/// Subclasses specify the exact source type (e.g., `List`, `Set`) via `_sourceDartType`.
/// {@endtemplate}
abstract class CollectionToCollectionConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;
  final Type _sourceDartType;

  /// {@macro collection_to_collection_converter}
  CollectionToCollectionConverter(this._conversionService, this._sourceDartType);

  @override
  bool matches(Class sourceType, Class targetType) {
    if (sourceType.getType() != _sourceDartType || !_isSupportedTarget(targetType.getType())) {
      return false;
    }

    final sourceElementType = sourceType.componentType();
    final targetElementType = targetType.componentType();

    if (sourceElementType == null || targetElementType == null) {
      // Allow if we can't determine element types — rely on runtime conversion
      return true;
    }

    return ConversionUtils.canConvertElements(sourceElementType, targetElementType, _conversionService);
  }

  /// {@template collection_to_collection_is_supported_target}
  /// Checks if the given Dart type is a supported collection type.
  ///
  /// ### Example:
  /// ```dart
  /// final isSupported = _isSupportedTarget(List);
  /// print(isSupported); // true
  /// ```
  /// {@endtemplate}
  bool _isSupportedTarget(Type dartType) {
    return dartType == List ||
        dartType == Set ||
        dartType == Iterable ||
        dartType == Queue ||
        dartType == ArrayList ||
        dartType == HashSet ||
        dartType == LinkedQueue ||
        dartType == LinkedList ||
        dartType == LinkedStack ||
        dartType == Stack ||
        dartType == col.LinkedHashSet ||
        dartType == col.ListBase ||
        dartType == col.SetBase ||
        dartType == col.Queue;
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final Iterable sourceCollection = source as Iterable;

    // Shortcut if possible...
    bool copyRequired = !targetType.isInstance(source);
    if (!copyRequired && sourceCollection.isEmpty) {
			return source;
		}

    final targetElementType = _getElementType(targetType);
    if (targetElementType == null && !copyRequired) {
			return source;
		}

    final sourceElementType = _getElementType(sourceType);

    final target = <dynamic>[];

    if (targetElementType == null) {
			target.addAll(sourceCollection);
		} else {
      for (final element in sourceCollection) {
        Object? result = _conversionService.convertTo(element, sourceElementType, targetElementType);
        target.add(result);
        
        if (element != result) {
					copyRequired = true;
				}
      }
    }
    return _createTargetCollection(targetType, target);
  }

  /// {@template collection_to_collection_get_element_type}
  /// Retrieves the element type of the given collection type.
  ///
  /// If the collection type is a [Class], returns its component type.
  /// Otherwise, returns `null`.
  ///
  /// ### Example:
  /// ```dart
  /// final elementType = _getElementType(Class.forType(List));
  /// print(elementType); // int
  /// ```
  /// {@endtemplate}
  Class? _getElementType(Class collectionType) => collectionType.componentType();

  /// {@template collection_to_collection_create_target_collection}
  /// Creates a new instance of the desired target collection type and populates it
  /// with the given `elements`.
  ///
  /// The mapping from type to collection is as follows:
  /// - `List`, `col.ListBase` → `List.from(elements)`
  /// - `Set`, `HashSet`, `col.SetBase` → `Set.from(elements)`
  /// - `col.LinkedHashSet` → `col.LinkedHashSet.from(elements)`
  /// - `Queue`, `col.Queue` → `Queue.from(elements)`
  /// - `LinkedQueue` → `LinkedQueue.from(elements)`
  /// - `LinkedList` → new `LinkedList()` with elements added
  /// - `LinkedStack`, `Stack` → new stack with elements pushed
  /// - `ArrayList` → `ArrayList.from(elements)`
  ///
  /// ### Example:
  /// ```dart
  /// final created = _createTargetCollection(Class.forType(Set), [1, 2, 3]);
  /// print(created.runtimeType); // Set<int>
  /// ```
  /// {@endtemplate}
  Object _createTargetCollection(Class targetType, List elements) {
    final dartType = targetType.getType();

    if (dartType == List || dartType == col.ListBase) {
      return List.from(elements);
    } else if (dartType == Set || dartType == HashSet || dartType == col.SetBase) {
      return Set.from(elements);
    } else if (dartType == col.LinkedHashSet) {
      return col.LinkedHashSet.from(elements);
    } else if (dartType == Queue || dartType == col.Queue) {
      return Queue.from(elements);
    } else if (dartType == LinkedQueue) {
      return LinkedQueue.from(elements);
    } else if (dartType == LinkedList) {
      final list = LinkedList();
      for (var e in elements) {
        list.add(e);
      }
      return list;
    } else if (dartType == LinkedStack) {
      final stack = LinkedStack();
      for (var e in elements) {
        stack.push(e);
      }
      return stack;
    } else if (dartType == Stack) {
      final stack = Stack();
      for (var e in elements) {
        stack.push(e);
      }
      return stack;
    } else if (dartType == ArrayList) {
      return ArrayList.from(elements);
    }
    return List.from(elements);
  }

  Set<ConvertiblePair> _buildConvertiblePairs(Type source) {
    return {
      ConvertiblePair(Class.forType(source), Class.forType(List)),
      ConvertiblePair(Class.forType(source), Class.forType(Set)),
      ConvertiblePair(Class.forType(source), Class.forType(Queue)),
      ConvertiblePair(Class.forType(source), Class.forType(Iterable)),
      ConvertiblePair(Class.forType(source), Class.forType(ArrayList)),
      ConvertiblePair(Class.forType(source), Class.forType(HashSet)),
      ConvertiblePair(Class.forType(source), Class.forType(LinkedQueue)),
      ConvertiblePair(Class.forType(source), Class.forType(LinkedList)),
      ConvertiblePair(Class.forType(source), Class.forType(LinkedStack)),
      ConvertiblePair(Class.forType(source), Class.forType(Stack)),
      ConvertiblePair(Class.forType(source), Class.forType(col.LinkedHashSet)),
      ConvertiblePair(Class.forType(source), Class.forType(col.ListBase)),
      ConvertiblePair(Class.forType(source), Class.forType(col.SetBase)),
      ConvertiblePair(Class.forType(source), Class.forType(col.Queue)),
    };
  }
}

/// {@template list_to_collection_converter}
/// A converter that transforms a [List] to a specific collection subtype.
///
/// Supported conversions:
/// - `List` → `List`
/// - `List` → `Set`
/// - `List` → `Queue`
/// - `List` → `Iterable`
/// - `List` → `ArrayList`
/// - `List` → `HashSet`
/// - `List` → `LinkedQueue`
/// - `List` → `LinkedList`
/// - `List` → `LinkedStack`
/// - `List` → `Stack`
/// - `List` → `col.LinkedHashSet`
/// - `List` → `col.ListBase`
/// - `List` → `col.SetBase`
/// - `List` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = ListToCollectionConverter();
/// print(converter.convert([1, 2, 3], Class.forType(List), Class.forType(Set))); // prints: {1, 2, 3}
/// ```
/// {@endtemplate}
class ListToCollectionConverter extends CollectionToCollectionConverter {
  /// {@macro list_to_collection_converter}
  ListToCollectionConverter(ConversionService cs) : super(cs, List);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(List);
}

/// {@template set_to_collection_converter}
/// A converter that transforms a [Set] to a specific collection subtype.
///
/// Supported conversions:
/// - `Set` → `Set`
/// - `Set` → `List`
/// - `Set` → `Queue`
/// - `Set` → `Iterable`
/// - `Set` → `ArrayList`
/// - `Set` → `HashSet`
/// - `Set` → `LinkedQueue`
/// - `Set` → `LinkedList`
/// - `Set` → `LinkedStack`
/// - `Set` → `Stack`
/// - `Set` → `col.LinkedHashSet`
/// - `Set` → `col.ListBase`
/// - `Set` → `col.SetBase`
/// - `Set` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = SetToCollectionConverter();
/// print(converter.convert({1, 2, 3}, Class.forType(Set), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class SetToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro set_to_collection_converter}
  SetToCollectionGenericConverter(ConversionService cs) : super(cs, Set);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(Set);
}

/// {@template queue_to_collection_converter}
/// A converter that transforms a [Queue] to a specific collection subtype.
///
/// Supported conversions:
/// - `Queue` → `Queue`
/// - `Queue` → `List`
/// - `Queue` → `Set`
/// - `Queue` → `Iterable`
/// - `Queue` → `ArrayList`
/// - `Queue` → `HashSet`
/// - `Queue` → `LinkedQueue`
/// - `Queue` → `LinkedList`
/// - `Queue` → `LinkedStack`
/// - `Queue` → `Stack`
/// - `Queue` → `col.LinkedHashSet`
/// - `Queue` → `col.ListBase`
/// - `Queue` → `col.SetBase`
/// - `Queue` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = QueueToCollectionConverter();
/// print(converter.convert(Queue.from([1, 2, 3]), Class.forType(Queue), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class QueueToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro queue_to_collection_converter}
  QueueToCollectionGenericConverter(ConversionService cs) : super(cs, Queue);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(Queue);
}

/// {@template iterable_to_collection_converter}
/// A converter that transforms an [Iterable] to a specific collection subtype.
///
/// Supported conversions:
/// - `Iterable` → `Iterable`
/// - `Iterable` → `List`
/// - `Iterable` → `Set`
/// - `Iterable` → `Queue`
/// - `Iterable` → `ArrayList`
/// - `Iterable` → `HashSet`
/// - `Iterable` → `LinkedQueue`
/// - `Iterable` → `LinkedList`
/// - `Iterable` → `LinkedStack`
/// - `Iterable` → `Stack`
/// - `Iterable` → `col.LinkedHashSet`
/// - `Iterable` → `col.ListBase`
/// - `Iterable` → `col.SetBase`
/// - `Iterable` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = IterableToCollectionConverter();
/// print(converter.convert([1, 2, 3], Class.forType(Iterable), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class IterableToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro iterable_to_collection_converter}
  IterableToCollectionGenericConverter(ConversionService cs) : super(cs, Iterable);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(Iterable);
}

/// {@template array_list_to_collection_converter}
/// A converter that transforms an [ArrayList] to a specific collection subtype.
///
/// Supported conversions:
/// - `ArrayList` → `ArrayList`
/// - `ArrayList` → `List`
/// - `ArrayList` → `Set`
/// - `ArrayList` → `Queue`
/// - `ArrayList` → `Iterable`
/// - `ArrayList` → `HashSet`
/// - `ArrayList` → `LinkedQueue`
/// - `ArrayList` → `LinkedList`
/// - `ArrayList` → `LinkedStack`
/// - `ArrayList` → `Stack`
/// - `ArrayList` → `col.LinkedHashSet`
/// - `ArrayList` → `col.ListBase`
/// - `ArrayList` → `col.SetBase`
/// - `ArrayList` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = ArrayListToCollectionConverter();
/// print(converter.convert(ArrayList.from([1, 2, 3]), Class.forType(ArrayList), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class ArrayListToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro array_list_to_collection_converter}
  ArrayListToCollectionGenericConverter(ConversionService cs) : super(cs, ArrayList);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(ArrayList);
}

/// {@template set_base_to_collection_converter}
/// A converter that transforms a [col.SetBase] to a specific collection subtype.
///
/// Supported conversions:
/// - `col.SetBase` → `col.SetBase`
/// - `col.SetBase` → `Set`
/// - `col.SetBase` → `List`
/// - `col.SetBase` → `Queue`
/// - `col.SetBase` → `Iterable`
/// - `col.SetBase` → `HashSet`
/// - `col.SetBase` → `LinkedQueue`
/// - `col.SetBase` → `LinkedList`
/// - `col.SetBase` → `LinkedStack`
/// - `col.SetBase` → `Stack`
/// - `col.SetBase` → `col.LinkedHashSet`
/// - `col.SetBase` → `col.ListBase`
/// - `col.SetBase` → `col.SetBase`
/// - `col.SetBase` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = SetBaseToCollectionConverter();
/// print(converter.convert(SetBase.from([1, 2, 3]), Class.forType(SetBase), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class SetBaseToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro set_base_to_collection_converter}
  SetBaseToCollectionGenericConverter(ConversionService cs) : super(cs, col.SetBase);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(col.SetBase);
}

/// {@template list_base_to_collection_converter}
/// A converter that transforms a [col.ListBase] to a specific collection subtype.
///
/// Supported conversions:
/// - `col.ListBase` → `col.ListBase`
/// - `col.ListBase` → `List`
/// - `col.ListBase` → `Set`
/// - `col.ListBase` → `Queue`
/// - `col.ListBase` → `Iterable`
/// - `col.ListBase` → `HashSet`
/// - `col.ListBase` → `LinkedQueue`
/// - `col.ListBase` → `LinkedList`
/// - `col.ListBase` → `LinkedStack`
/// - `col.ListBase` → `Stack`
/// - `col.ListBase` → `col.LinkedHashSet`
/// - `col.ListBase` → `col.ListBase`
/// - `col.ListBase` → `col.SetBase`
/// - `col.ListBase` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = ListBaseToCollectionConverter();
/// print(converter.convert(ListBase.from([1, 2, 3]), Class.forType(ListBase), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class ListBaseToCollectionConverter extends CollectionToCollectionConverter {
  /// {@macro list_base_to_collection_converter}
  ListBaseToCollectionConverter(ConversionService cs) : super(cs, col.ListBase);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(col.ListBase);
}

/// {@template linked_queue_to_collection_converter}
/// A converter that transforms a [LinkedQueue] to a specific collection subtype.
///
/// Supported conversions:
/// - `LinkedQueue` → `LinkedQueue`
/// - `LinkedQueue` → `Queue`
/// - `LinkedQueue` → `List`
/// - `LinkedQueue` → `Set`
/// - `LinkedQueue` → `Iterable`
/// - `LinkedQueue` → `HashSet`
/// - `LinkedQueue` → `LinkedQueue`
/// - `LinkedQueue` → `LinkedList`
/// - `LinkedQueue` → `LinkedStack`
/// - `LinkedQueue` → `Stack`
/// - `LinkedQueue` → `col.LinkedHashSet`
/// - `LinkedQueue` → `col.ListBase`
/// - `LinkedQueue` → `col.SetBase`
/// - `LinkedQueue` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = LinkedQueueToCollectionConverter();
/// print(converter.convert(LinkedQueue.from([1, 2, 3]), Class.forType(LinkedQueue), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class LinkedQueueToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro linked_queue_to_collection_converter}
  LinkedQueueToCollectionGenericConverter(ConversionService cs) : super(cs, LinkedQueue);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(LinkedQueue);
}

/// {@template linked_list_to_collection_converter}
/// A converter that transforms a [LinkedList] to a specific collection subtype.
///
/// Supported conversions:
/// - `LinkedList` → `LinkedList`
/// - `LinkedList` → `Queue`
/// - `LinkedList` → `List`
/// - `LinkedList` → `Set`
/// - `LinkedList` → `Iterable`
/// - `LinkedList` → `HashSet`
/// - `LinkedList` → `LinkedQueue`
/// - `LinkedList` → `LinkedStack`
/// - `LinkedList` → `Stack`
/// - `LinkedList` → `col.LinkedHashSet`
/// - `LinkedList` → `col.ListBase`
/// - `LinkedList` → `col.SetBase`
/// - `LinkedList` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = LinkedListToCollectionConverter();
/// print(converter.convert(LinkedList.from([1, 2, 3]), Class.forType(LinkedList), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class LinkedListToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro linked_list_to_collection_converter}
  LinkedListToCollectionGenericConverter(ConversionService cs) : super(cs, LinkedList);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(LinkedList);
}

/// {@template linked_hash_set_to_collection_converter}
/// A converter that transforms a [col.LinkedHashSet] to a specific collection subtype.
///
/// Supported conversions:
/// - `col.LinkedHashSet` → `col.LinkedHashSet`
/// - `col.LinkedHashSet` → `Set`
/// - `col.LinkedHashSet` → `List`
/// - `col.LinkedHashSet` → `Queue`
/// - `col.LinkedHashSet` → `Iterable`
/// - `col.LinkedHashSet` → `HashSet`
/// - `col.LinkedHashSet` → `LinkedQueue`
/// - `col.LinkedHashSet` → `LinkedStack`
/// - `col.LinkedHashSet` → `Stack`
/// - `col.LinkedHashSet` → `col.LinkedHashSet`
/// - `col.LinkedHashSet` → `col.ListBase`
/// - `col.LinkedHashSet` → `col.SetBase`
/// - `col.LinkedHashSet` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = LinkedHashSetToCollectionConverter();
/// print(converter.convert(LinkedHashSet.from([1, 2, 3]), Class.forType(LinkedHashSet), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class LinkedHashSetToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro linked_hash_set_to_collection_converter}
  LinkedHashSetToCollectionGenericConverter(ConversionService cs) : super(cs, col.LinkedHashSet);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(col.LinkedHashSet);
}

/// {@template hash_set_to_collection_converter}
/// A converter that transforms a [HashSet] to a specific collection subtype.
///
/// Supported conversions:
/// - `HashSet` → `HashSet`
/// - `HashSet` → `Set`
/// - `HashSet` → `List`
/// - `HashSet` → `Queue`
/// - `HashSet` → `Iterable`
/// - `HashSet` → `LinkedHashSet`
/// - `HashSet` → `LinkedQueue`
/// - `HashSet` → `LinkedStack`
/// - `HashSet` → `Stack`
/// - `HashSet` → `col.LinkedHashSet`
/// - `HashSet` → `col.ListBase`
/// - `HashSet` → `col.SetBase`
/// - `HashSet` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = HashSetToCollectionConverter();
/// print(converter.convert(HashSet.from([1, 2, 3]), Class.forType(HashSet), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class HashSetToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro hash_set_to_collection_converter}
  HashSetToCollectionGenericConverter(ConversionService cs) : super(cs, HashSet);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(HashSet);
}

/// {@template stack_to_collection_converter}
/// A converter that transforms a [Stack] to a specific collection subtype.
///
/// Supported conversions:
/// - `Stack` → `Stack`
/// - `Stack` → `Queue`
/// - `Stack` → `List`
/// - `Stack` → `Set`
/// - `Stack` → `Iterable`
/// - `Stack` → `LinkedQueue`
/// - `Stack` → `LinkedStack`
/// - `Stack` → `col.LinkedHashSet`
/// - `Stack` → `col.ListBase`
/// - `Stack` → `col.SetBase`
/// - `Stack` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = StackToCollectionConverter();
/// print(converter.convert(Stack.from([1, 2, 3]), Class.forType(Stack), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class StackToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro stack_to_collection_converter}
  StackToCollectionGenericConverter(ConversionService cs) : super(cs, Stack);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(Stack);
}

/// {@template linked_stack_to_collection_converter}
/// A converter that transforms a [LinkedStack] to a specific collection subtype.
///
/// Supported conversions:
/// - `LinkedStack` → `LinkedStack`
/// - `LinkedStack` → `Queue`
/// - `LinkedStack` → `List`
/// - `LinkedStack` → `Set`
/// - `LinkedStack` → `Iterable`
/// - `LinkedStack` → `LinkedQueue`
/// - `LinkedStack` → `LinkedStack`
/// - `LinkedStack` → `col.LinkedHashSet`
/// - `LinkedStack` → `col.ListBase`
/// - `LinkedStack` → `col.SetBase`
/// - `LinkedStack` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = LinkedStackToCollectionConverter();
/// print(converter.convert(LinkedStack.from([1, 2, 3]), Class.forType(LinkedStack), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class LinkedStackToCollectionGenericConverter extends CollectionToCollectionConverter {
  /// {@macro linked_stack_to_collection_converter}
  LinkedStackToCollectionGenericConverter(ConversionService cs) : super(cs, LinkedStack);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => _buildConvertiblePairs(LinkedStack);
}

/// {@template string_to_collection_converter}
/// A converter that transforms a [String] to a specific collection subtype.
///
/// Supported conversions:
/// - `String` → `List`
/// - `String` → `Set`
/// - `String` → `Queue`
/// - `String` → `Iterable`
/// - `String` → `ArrayList`
/// - `String` → `HashSet`
/// - `String` → `LinkedQueue`
/// - `String` → `LinkedStack`
/// - `String` → `Stack`
/// - `String` → `col.LinkedHashSet`
/// - `String` → `col.ListBase`
/// - `String` → `col.SetBase`
/// - `String` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = StringToCollectionConverter();
/// print(converter.convert('1,2,3', Class.forType(String), Class.forType(List))); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class StringToCollectionGenericConverter extends CollectionToCollectionConverter {
  final String delimiter;

  StringToCollectionGenericConverter(
    ConversionService cs, {
    this.delimiter = ',',
  }) : super(cs, String);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(String), Class.forType(List)),
      ConvertiblePair(Class.forType(String), Class.forType(Set)),
      ConvertiblePair(Class.forType(String), Class.forType(Queue)),
      ConvertiblePair(Class.forType(String), Class.forType(Iterable)),
      ConvertiblePair(Class.forType(String), Class.forType(ArrayList)),
      ConvertiblePair(Class.forType(String), Class.forType(HashSet)),
      ConvertiblePair(Class.forType(String), Class.forType(LinkedQueue)),
      ConvertiblePair(Class.forType(String), Class.forType(LinkedList)),
      ConvertiblePair(Class.forType(String), Class.forType(LinkedStack)),
      ConvertiblePair(Class.forType(String), Class.forType(Stack)),
      ConvertiblePair(Class.forType(String), Class.forType(col.LinkedHashSet)),
      ConvertiblePair(Class.forType(String), Class.forType(col.ListBase)),
      ConvertiblePair(Class.forType(String), Class.forType(col.SetBase)),
      ConvertiblePair(Class.forType(String), Class.forType(col.Queue)),
    };
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;
    final str = source as String;

    List<String> rawParts;
    if (str.contains(delimiter)) {
      rawParts = str
          .split(delimiter)
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      // fallback to character-by-character
      rawParts = str.split('');
    }

    final targetElementType = _getElementType(targetType);
    final convertedElements = <dynamic>[];

    for (final raw in rawParts) {
      if (targetElementType != null) {
        convertedElements.add(_conversionService.convertTo(raw, Class.forType(String), targetElementType));
      } else {
        convertedElements.add(raw);
      }
    }

    return _createTargetCollection(targetType, convertedElements);
  }
}

/// {@template collection_to_string_converter}
/// A converter that transforms a collection to a [String].
///
/// Supported conversions:
/// - `List` → `String`
/// - `Set` → `String`
/// - `Queue` → `String`
/// - `Iterable` → `String`
/// - `ArrayList` → `String`
/// - `HashSet` → `String`
/// - `LinkedQueue` → `String`
/// - `LinkedList` → `String`
/// - `LinkedStack` → `String`
/// - `Stack` → `String`
/// - `col.LinkedHashSet` → `String`
/// - `col.ListBase` → `String`
/// - `col.SetBase` → `String`
/// - `col.Queue` → `String`
///
/// Example:
/// ```dart
/// final converter = CollectionToStringConverter();
/// print(converter.convert([1, 2, 3], Class.forType(List), Class.forType(String))); // prints: "1,2,3"
/// ```
/// {@endtemplate}
class CollectionToStringGenericConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;
  final String delimiter;

  /// {@macro collection_to_string_converter}
  CollectionToStringGenericConverter(
    this._conversionService, {
    this.delimiter = ',',
  });

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(List), Class.forType(String)),
      ConvertiblePair(Class.forType(Set), Class.forType(String)),
      ConvertiblePair(Class.forType(Queue), Class.forType(String)),
      ConvertiblePair(Class.forType(Iterable), Class.forType(String)),
      ConvertiblePair(Class.forType(ArrayList), Class.forType(String)),
      ConvertiblePair(Class.forType(HashSet), Class.forType(String)),
      ConvertiblePair(Class.forType(LinkedQueue), Class.forType(String)),
      ConvertiblePair(Class.forType(LinkedList), Class.forType(String)),
      ConvertiblePair(Class.forType(LinkedStack), Class.forType(String)),
      ConvertiblePair(Class.forType(Stack), Class.forType(String)),
      ConvertiblePair(Class.forType(col.LinkedHashSet), Class.forType(String)),
      ConvertiblePair(Class.forType(col.ListBase), Class.forType(String)),
      ConvertiblePair(Class.forType(col.SetBase), Class.forType(String)),
      ConvertiblePair(Class.forType(col.Queue), Class.forType(String)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    final type = sourceType.getType();
    if (!(type == List ||
          type == Set ||
          type == Queue ||
          type == Iterable ||
          type == ArrayList ||
          type == HashSet ||
          type == LinkedQueue ||
          type == LinkedList ||
          type == LinkedStack ||
          type == Stack ||
          type == col.LinkedHashSet ||
          type == col.ListBase ||
          type == col.SetBase ||
          type == col.Queue)) {
      return false;
    }

    if (targetType.getType() != String) return false;

    final sourceElementType = sourceType.componentType();
    final targetElementType = Class.forType(String); // always string target

    if (sourceElementType == null) return true;

    return ConversionUtils.canConvertElements(
      sourceElementType,
      targetElementType,
      _conversionService,
    );
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final collection = source as Iterable;
    final elementType = _getElementType(sourceType);
    final convertedStrings = collection.map((e) {
      if (elementType != null && e != null) {
        final converted = _conversionService.convertTo(e, elementType, Class.forType(String));
        return converted?.toString() ?? '';
      }
      return e?.toString() ?? '';
    }).toList();

    return convertedStrings.join(delimiter);
  }

  /// Returns the element type of the collection.
  Class? _getElementType(Class collectionType) {
    return collectionType.componentType();
  }
}

/// {@template int_to_collection_converter}
/// A converter that transforms an [int] to a specific collection subtype.
///
/// Supported conversions:
/// - `int` → `List`
/// - `int` → `Set`
/// - `int` → `Queue`
/// - `int` → `Iterable`
/// - `int` → `ArrayList`
/// - `int` → `HashSet`
/// - `int` → `LinkedQueue`
/// - `int` → `LinkedStack`
/// - `int` → `Stack`
/// - `int` → `col.LinkedHashSet`
/// - `int` → `col.ListBase`
/// - `int` → `col.SetBase`
/// - `int` → `col.Queue`
///
/// Example:
/// ```dart
/// final converter = IntToCollectionConverter();
/// print(converter.convert(1, Class.forType(int), Class.forType(List))); // prints: [1]
/// ```
/// {@endtemplate}
class IntToCollectionGenericConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro int_to_collection_converter}
  IntToCollectionGenericConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(int), Class.forType(List)),
      ConvertiblePair(Class.forType(int), Class.forType(Set)),
      ConvertiblePair(Class.forType(int), Class.forType(Queue)),
      ConvertiblePair(Class.forType(int), Class.forType(Iterable)),
      ConvertiblePair(Class.forType(int), Class.forType(ArrayList)),
      ConvertiblePair(Class.forType(int), Class.forType(HashSet)),
      ConvertiblePair(Class.forType(int), Class.forType(LinkedQueue)),
      ConvertiblePair(Class.forType(int), Class.forType(LinkedList)),
      ConvertiblePair(Class.forType(int), Class.forType(LinkedStack)),
      ConvertiblePair(Class.forType(int), Class.forType(Stack)),
      ConvertiblePair(Class.forType(int), Class.forType(col.LinkedHashSet)),
      ConvertiblePair(Class.forType(int), Class.forType(col.ListBase)),
      ConvertiblePair(Class.forType(int), Class.forType(col.SetBase)),
      ConvertiblePair(Class.forType(int), Class.forType(col.Queue)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    return sourceType.getType() == int &&
        (targetType.getType() == List ||
         targetType.getType() == Set ||
         targetType.getType() == Iterable ||
         targetType.getType() == Queue ||
         targetType.getType() == ArrayList ||
         targetType.getType() == HashSet ||
         targetType.getType() == LinkedQueue ||
         targetType.getType() == LinkedList ||
         targetType.getType() == LinkedStack ||
         targetType.getType() == Stack ||
         targetType.getType() == col.LinkedHashSet ||
         targetType.getType() == col.ListBase ||
         targetType.getType() == col.SetBase ||
         targetType.getType() == col.Queue);
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final targetElementType = _getElementType(targetType);
    final convertedElements = <dynamic>[];

    if (targetElementType != null) {
      final converted = _conversionService.convertTo(source, Class.forType(int), targetElementType);
      convertedElements.add(converted);
    } else {
      convertedElements.add(source);
    }

    return _createTargetCollection(targetType, convertedElements);
  }

  /// Returns the element type of the collection.
  Class? _getElementType(Class collectionType) {
    return collectionType.componentType();
  }

  /// Creates a new instance of the desired target collection type and populates it
  /// with the given `elements`.
  Object _createTargetCollection(Class targetType, List elements) {
    final dartType = targetType.getType();

    if (dartType == List || dartType == col.ListBase) {
      return List.from(elements);
    } else if (dartType == Set || dartType == HashSet || dartType == col.SetBase) {
      return Set.from(elements);
    } else if (dartType == col.LinkedHashSet) {
      return col.LinkedHashSet.from(elements);
    } else if (dartType == Queue || dartType == col.Queue) {
      return Queue.from(elements);
    } else if (dartType == LinkedQueue) {
      return LinkedQueue.from(elements);
    } else if (dartType == LinkedList) {
      final list = LinkedList();
      for (var e in elements) {
        list.add(e);
      }
      return list;
    } else if (dartType == LinkedStack) {
      final stack = LinkedStack();
      for (var e in elements) {
        stack.push(e);
      }
      return stack;
    } else if (dartType == Stack) {
      final stack = Stack();
      for (var e in elements) {
        stack.push(e);
      }
      return stack;
    } else if (dartType == ArrayList) {
      return ArrayList.from(elements);
    }
    return List.from(elements);
  }
}

/// {@template collection_to_int_converter}
/// A converter that transforms a specific collection subtype to an [int].
///
/// Supported conversions:
/// - `List` → `int`
/// - `Set` → `int`
/// - `Queue` → `int`
/// - `Iterable` → `int`
/// - `ArrayList` → `int`
/// - `HashSet` → `int`
/// - `LinkedQueue` → `int`
/// - `LinkedList` → `int`
/// - `LinkedStack` → `int`
/// - `Stack` → `int`
/// - `col.LinkedHashSet` → `int`
/// - `col.ListBase` → `int`
/// - `col.SetBase` → `int`
/// - `col.Queue` → `int`
///
/// Example:
/// ```dart
/// final converter = CollectionToIntConverter();
/// print(converter.convert([1, 2, 3], Class.forType(List), Class.forType(int))); // prints: 6
/// ```
/// {@endtemplate}
class CollectionToIntGenericConverter implements ConditionalGenericConverter {
  final ConversionService _conversionService;

  /// {@macro collection_to_int_converter}
  CollectionToIntGenericConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() {
    return {
      ConvertiblePair(Class.forType(List), Class.forType(int)),
      ConvertiblePair(Class.forType(Set), Class.forType(int)),
      ConvertiblePair(Class.forType(Queue), Class.forType(int)),
      ConvertiblePair(Class.forType(Iterable), Class.forType(int)),
      ConvertiblePair(Class.forType(ArrayList), Class.forType(int)),
      ConvertiblePair(Class.forType(HashSet), Class.forType(int)),
      ConvertiblePair(Class.forType(LinkedQueue), Class.forType(int)),
      ConvertiblePair(Class.forType(LinkedList), Class.forType(int)),
      ConvertiblePair(Class.forType(LinkedStack), Class.forType(int)),
      ConvertiblePair(Class.forType(Stack), Class.forType(int)),
      ConvertiblePair(Class.forType(col.LinkedHashSet), Class.forType(int)),
      ConvertiblePair(Class.forType(col.ListBase), Class.forType(int)),
      ConvertiblePair(Class.forType(col.SetBase), Class.forType(int)),
      ConvertiblePair(Class.forType(col.Queue), Class.forType(int)),
    };
  }

  @override
  bool matches(Class sourceType, Class targetType) {
    if (sourceType.getType() != int ||
        !(targetType.getType() == List ||
          targetType.getType() == Set ||
          targetType.getType() == Iterable ||
          targetType.getType() == Queue ||
          targetType.getType() == ArrayList ||
          targetType.getType() == HashSet ||
          targetType.getType() == LinkedQueue ||
          targetType.getType() == LinkedList ||
          targetType.getType() == LinkedStack ||
          targetType.getType() == Stack ||
          targetType.getType() == col.LinkedHashSet ||
          targetType.getType() == col.ListBase ||
          targetType.getType() == col.SetBase ||
          targetType.getType() == col.Queue)) {
      return false;
    }

    final sourceElementType = Class.forType(int);
    final targetElementType = targetType.componentType();

    if (targetElementType == null) return true;

    return ConversionUtils.canConvertElements(
      sourceElementType,
      targetElementType,
      _conversionService,
    );
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;
    final iterable = source as Iterable;
    if (iterable.isEmpty) return null;

    final firstElement = iterable.first;
    final elementType = _getElementType(sourceType);
    if (elementType != null) {
      return _conversionService.convertTo(firstElement, elementType, Class.forType(int));
    }
    return firstElement is int ? firstElement : int.tryParse(firstElement.toString());
  }

  Class? _getElementType(Class collectionType) {
    return collectionType.componentType();
  }
}