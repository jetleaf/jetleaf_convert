# ConvertingComparator

## Overview
`ConvertingComparator` is a utility class that combines type conversion with comparison logic. It allows you to compare objects of one type by first converting them to another type and then applying a comparator to the converted values.

This is particularly useful when you need to sort or compare objects based on a derived property or when you need to normalize values before comparison.

## Key Features

- **Type Conversion**: Converts values before comparison
- **Flexible**: Works with any types that can be converted
- **Composable**: Can be combined with other comparators
- **MapEntry Support**: Built-in support for comparing `MapEntry` keys and values

## Core API

### Constructors

#### `ConvertingComparator(Comparator<T> comparator, Converter<S, T> converter)`

Creates a new `ConvertingComparator` with the specified comparator and converter.

**Parameters:**
- `comparator`: The comparator to use on the converted values
- `converter`: The converter to transform source values before comparison

**Example:**
```dart
final comparator = ConvertingComparator<String, int>(
  (a, b) => a.compareTo(b),  // Compare as integers
  (s) => int.parse(s)        // Convert string to int
);
```

#### `ConvertingComparator.withConverter(Comparator<T> comparator, ConversionService conversionService, Class<T> targetType)`

Creates a new `ConvertingComparator` that uses a `ConversionService` for type conversion.

**Parameters:**
- `comparator`: The comparator to use on the converted values
- `conversionService`: The conversion service to use for type conversion
- `targetType`: The target type to convert to before comparison

**Example:**
```dart
final service = DefaultConversionService();
final comparator = ConvertingComparator.withConverter<String, int>(
  (a, b) => a.compareTo(b),
  service,
  Class<int>()
);
```

### Factory Methods

#### `ConvertingComparator.mapEntryKeys<K, V>(Comparator<K> comparator)`

Creates a comparator that compares `MapEntry` objects by their keys.

**Type Parameters:**
- `K`: The key type
- `V`: The value type

**Parameters:**
- `comparator`: The comparator to use for comparing keys

**Example:**
```dart
final entries = [
  MapEntry('c', 1),
  MapEntry('a', 3),
  MapEntry('b', 2),
];
entries.sort(ConvertingComparator.mapEntryKeys((a, b) => a.compareTo(b)));
// Sorted by key: a, b, c
```

#### `ConvertingComparator.mapEntryValues<K, V>(Comparator<V> comparator)`

Creates a comparator that compares `MapEntry` objects by their values.

**Type Parameters:**
- `K`: The key type
- `V`: The value type

**Parameters:**
- `comparator`: The comparator to use for comparing values

**Example:**
```dart
final entries = [
  MapEntry('a', 3),
  MapEntry('b', 1),
  MapEntry('c', 2),
];
entries.sort(ConvertingComparator.mapEntryValues((a, b) => a.compareTo(b)));
// Sorted by value: 1, 2, 3
```

### Methods

#### `int compare(S a, S b)`

Compares its two arguments for order.

**Parameters:**
- `a`: The first object to be compared
- `b`: The second object to be compared

**Returns:**
- A negative integer if `a` is less than `b`
- Zero if `a` is equal to `b`
- A positive integer if `a` is greater than `b`

## Usage Examples

### Basic Usage

```dart
import 'package:jetleaf_convert/converting_comparator.dart';

void main() {
  // Sort strings by their numeric values
  final comparator = ConvertingComparator<String, int>(
    (a, b) => a.compareTo(b),
    (s) => int.parse(s)
  );

  final strings = ['100', '2', '30'];
  strings.sort(comparator);
  print(strings); // ['2', '30', '100']
}
```

### Using with Complex Objects

```dart
class Person {
  final String name;
  final int age;
  
  Person(this.name, this.age);
  
  @override
  String toString() => '$name ($age)';
}

void main() {
  final people = [
    Person('Alice', 30),
    Person('Bob', 25),
    Person('Charlie', 35),
  ];
  
  // Sort by age
  final ageComparator = ConvertingComparator<Person, int>(
    (a, b) => a.compareTo(b),
    (person) => person.age
  );
  
  people.sort(ageComparator);
  print(people); // [Bob (25), Alice (30), Charlie (35)]
  
  // Sort by name length
  final nameLengthComparator = ConvertingComparator<Person, int>(
    (a, b) => a.compareTo(b),
    (person) => person.name.length
  );
  
  people.sort(nameLengthComparator);
  print(people); // [Bob (25), Alice (30), Charlie (35)]
}
```

### Chaining with Other Comparators

```dart
import 'package:collection/collection.dart';

void main() {
  final people = [
    Person('Alice', 30),
    Person('Bob', 25),
    Person('Charlie', 30),  // Same age as Alice
  ];
  
  // Sort by age, then by name
  final ageComparator = ConvertingComparator<Person, int>(
    (a, b) => a.compareTo(b),
    (person) => person.age
  );
  
  final nameComparator = ConvertingComparator<Person, String>(
    (a, b) => a.compareTo(b),
    (person) => person.name
  );
  
  // Combine comparators
  final combined = ageComparator.then(nameComparator);
  
  people.sort(combined);
  print(people); // [Bob (25), Alice (30), Charlie (30)]
}
```

## Best Practices

1. **Reuse Comparators**: Create comparators once and reuse them
2. **Null Safety**: Handle null values appropriately in your comparators
3. **Performance**: Be mindful of conversion costs in performance-critical code
4. **Immutability**: Prefer immutable comparators
5. **Documentation**: Document custom comparators with examples

## Performance Considerations

- Conversion happens on each comparison, which may impact performance for large collections
- Consider caching converted values if the same objects are compared multiple times
- For complex comparisons, pre-compute derived values if possible

## See Also

- [ConversionService](ConversionService/README.md) - For type conversion
- [Comparator](https://api.dart.dev/stable/dart-core/Comparator.html) - The Dart standard comparator interface
- [Comparable](https://api.dart.dev/stable/dart-core/Comparable-class.html) - For defining natural ordering of objects
