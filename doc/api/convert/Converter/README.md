# Converter Interfaces

## Overview
This document describes the core converter interfaces in the JetLeaf Convert library. These interfaces define the contract for type conversion operations.

## Core Interfaces

### `Converter<S, T>`

A simple converter interface for converting from type `S` to type `T`.

**Methods:**
- `T convert(S source)`: Converts the source object to the target type

**Example:**
```dart
class StringToIntConverter implements Converter<String, int> {
  @override
  int convert(String source) => int.parse(source);
}
```

### `GenericConverter`

A more flexible converter that can handle multiple source-target type pairs.

**Methods:**
- `Set<ConvertiblePair> getConvertibleTypes()`: Returns the set of convertible type pairs
- `Object? convert(Object? source, Class sourceType, Class targetType)`: Performs the conversion

**Example:**
```dart
class StringToNumberConverter implements GenericConverter {
  @override
  Set<ConvertiblePair> getConvertibleTypes() => {
    ConvertiblePair(Class<String>(), Class<int>()),
    ConvertiblePair(Class<String>(), Class<double>())
  };

  @override
  Object? convert(Object? source, Class sourceType, Class targetType) {
    if (source is String) {
      if (targetType.getType() == int) return int.tryParse(source);
      if (targetType.getType() == double) return double.tryParse(source);
    }
    return null;
  }
}
```

### `ConditionalConverter`

A converter that only applies under certain conditions.

**Methods:**
- `bool matches(Class sourceType, Class targetType)`: Determines if the converter should be used

**Example:**
```dart
class ConditionalUriConverter implements ConditionalConverter {
  @override
  bool matches(Class sourceType, Class targetType) {
    return sourceType.getType() == String && targetType.getType() == Uri;
  }
}
```

### `ConditionalGenericConverter`

Combines `GenericConverter` and `ConditionalConverter` for maximum flexibility.

**Example:**
```dart
class ConditionalUriConverter implements ConditionalGenericConverter {
  @override
  Set<ConvertiblePair> getConvertibleTypes() => {
    ConvertiblePair(Class<String>(), Class<Uri>())
  };

  @override
  bool matches(Class sourceType, Class targetType) {
    return sourceType.getType() == String && targetType.getType() == Uri;
  }

  @override
  Object? convert(Object? source, Class sourceType, Class targetType) {
    return source != null ? Uri.tryParse(source as String) : null;
  }
}
```

## Best Practices

1. **Specific Over Generic**: Prefer specific converters over generic ones when possible for better performance.
2. **Null Safety**: Always handle null values appropriately in your converters.
3. **Immutability**: Converters should be immutable and thread-safe.
4. **Error Handling**: Provide clear error messages when conversion fails.
5. **Documentation**: Document the supported types and any special behavior.

## Common Patterns

### Factory Pattern for Converters

```dart
abstract class ConverterFactory<S, T> {
  Converter<S, T> getConverter(Class sourceType, Class targetType);
}

class StringToNumberConverterFactory implements ConverterFactory<String, num> {
  @override
  Converter<String, num> getConverter(Class sourceType, Class targetType) {
    if (targetType.getType() == int) return StringToIntConverter();
    if (targetType.getType() == double) return StringToDoubleConverter();
    throw UnsupportedError('Unsupported target type: $targetType');
  }
}
```

### Composite Converter

```dart
class CompositeConverter<T> implements Converter<Object?, T> {
  final List<Converter<Object?, T>> _converters;
  
  CompositeConverter(this._converters);
  
  @override
  T convert(Object? source) {
    for (final converter in _converters) {
      try {
        return converter.convert(source);
      } catch (_) {
        // Try next converter
      }
    }
    throw Exception('No converter could handle the conversion');
  }
}
```

## See Also
- [ConversionService](ConversionService/README.md) - For using converters in an application
- [ConverterRegistry](ConverterRegistry/README.md) - For managing a collection of converters
- [ConverterFactory](ConverterFactory/README.md) - For creating converters dynamically
