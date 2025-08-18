# ConvertiblePair

## Overview
`ConvertiblePair` is an immutable value class that represents a source and target type pair for type conversion. It's a fundamental building block in the JetLeaf Convert library, used to define and look up type conversion mappings.

## Key Features

- **Immutable**: Thread-safe by design
- **Type Safety**: Enforces type safety through the `Class` type system
- **Value Semantics**: Implements `==`, `hashCode`, and `toString()`
- **Serialization Ready**: Can be easily serialized/deserialized

## Core API

### Constructors

#### `ConvertiblePair(Class sourceType, Class targetType)`

Creates a new `ConvertiblePair` with the given source and target types.

**Parameters:**
- `sourceType`: The source type of the conversion
- `targetType`: The target type of the conversion

**Example:**
```dart
final pair = ConvertiblePair(Class<String>(), Class<int>());
```

### Properties

#### `sourceType`

The source type of the conversion.

**Type:** `Class`

**Example:**
```dart
final pair = ConvertiblePair(Class<String>(), Class<int>());
print(pair.sourceType); // Class<String>
```

#### `targetType`

The target type of the conversion.

**Type:** `Class`

**Example:**
```dart
final pair = ConvertiblePair(Class<String>(), Class<int>());
print(pair.targetType); // Class<int>
```

### Methods

#### `Class getSourceType()`

Returns the source type of this pair.

**Returns:** `Class` - The source type

**Example:**
```dart
final sourceType = pair.getSourceType();
```

#### `Class getTargetType()`

Returns the target type of this pair.

**Returns:** `Class` - The target type

**Example:**
```dart
final targetType = pair.getTargetType();
```

#### `String toString()`

Returns a string representation of this pair in the format `sourceType -> targetType`.

**Returns:** `String` - The string representation

**Example:**
```dart
print(ConvertiblePair(Class<String>(), Class<int>()));
// Output: java.lang.String -> int
```

## Usage Examples

### Basic Usage

```dart
import 'package:jetleaf_convert/convertible_pair.dart';
import 'package:jetleaf_lang/lang.dart';

void main() {
  // Create a pair for String to int conversion
  final pair = ConvertiblePair(Class<String>(), Class<int>());
  
  // Access the types
  print('Source: ${pair.sourceType}'); // Source: Class<String>
  print('Target: ${pair.targetType}'); // Target: Class<int>
  
  // String representation
  print(pair); // java.lang.String -> int
}
```

### Using in Converter Implementations

```dart
class StringToIntConverter implements GenericConverter {
  @override
  Set<ConvertiblePair> getConvertibleTypes() => {
    ConvertiblePair(Class<String>(), Class<int>())
  };

  @override
  Object? convert(Object? source, Class sourceType, Class targetType) {
    if (source is String) {
      return int.tryParse(source);
    }
    return null;
  }
}
```

### Comparing Pairs

```dart
final pair1 = ConvertiblePair(Class<String>(), Class<int>());
final pair2 = ConvertiblePair(Class<String>(), Class<int>());

print(pair1 == pair2); // true
print(pair1.hashCode == pair2.hashCode); // true
```

## Best Practices

1. **Immutability**: Treat `ConvertiblePair` as immutable
2. **Caching**: Consider caching frequently used pairs
3. **Type Safety**: Always use proper `Class` instances for types
4. **Equality**: Rely on value semantics for comparison

## Performance Considerations

- `ConvertiblePair` is a lightweight value type
- Hash code is cached after first computation
- Consider reusing instances for better performance

## See Also

- [ConversionService](ConversionService/README.md) - Uses `ConvertiblePair` for converter lookup
- [GenericConverter](GenericConverter/README.md) - Returns a set of `ConvertiblePair`s it can handle
- [ConverterRegistry](ConverterRegistry/README.md) - Manages converters keyed by `ConvertiblePair`
