# GenericConversionService

## Overview
`GenericConversionService` is a comprehensive base implementation of the [ConversionService](ConversionService/README.md) interface that provides a complete type conversion system. It serves as the foundation for more specialized conversion services like [DefaultConversionService](DefaultConversionService/README.md).

## Key Features

- **Converter Management**: Register and manage converters and converter factories
- **Type Hierarchy Support**: Handles inheritance and interface implementations
- **Null Safety**: Built-in null handling and conversion
- **Performance Optimized**: Caches converter lookups for better performance
- **Primitive Type Handling**: Special handling for Dart primitive types
- **Optional Type Support**: Built-in support for `Optional` types

## Core Concepts

### Converters
Converters are responsible for converting between specific source and target types. They implement either the `Converter<S, T>` interface or the more flexible `GenericConverter` interface.

### Converter Factories
Converter factories can create converters for specific source and target types at runtime, allowing for more dynamic conversion scenarios.

### Type Descriptors
Type information is represented using `Class` objects from the `jetleaf_lang` package, which provide rich type information including generics.

## Usage

### Basic Usage

```dart
import 'package:jetleaf_convert/jetleaf_convert.dart';
import 'package:jetleaf_lang/lang.dart';

void main() {
  // Create a new instance
  final service = GenericConversionService();
  
  // Register a converter
  service.addConverter(StringToIntConverter());
  
  // Perform conversion
  final result = service.convert('42', Class<int>());
  print(result); // 42
}
```

### Registering Converters

```dart
// Simple converter
class StringToIntConverter implements Converter<String, int> {
  @override
  int convert(String source) => int.parse(source);
}

// Generic converter
class StringToEnumConverter<T extends Enum> implements Converter<String, T> {
  final List<T> values;
  
  StringToEnumConverter(this.values);
  
  @override
  T convert(String source) => values.firstWhere(
    (e) => e.name == source,
    orElse: () => throw ArgumentError('No enum value for $source')
  );
}

void main() {
  final service = GenericConversionService();
  
  // Register simple converter
  service.addConverter(StringToIntConverter());
  
  // Register generic converter
  service.addConverterFactory(ConverterFactory.from(
    (sourceType, targetType) {
      if (targetType.isEnum) {
        final enumValues = targetType.enumValues as List<Enum>;
        return StringToEnumConverter(enumValues);
      }
      return null;
    }
  ));
}
```

## Key Methods

### Converter Management

- `addConverter(Converter converter)`: Register a converter
- `addConverterWithClass(Class sourceType, Class targetType, Converter converter)`: Register a converter for specific types
- `addGenericConverter(GenericConverter converter)`: Register a generic converter
- `addConverterFactory(ConverterFactory factory)`: Register a converter factory
- `removeConvertible(Class sourceType, Class targetType)`: Remove a converter

### Conversion Methods

- `convert(Object? source, Class<T> targetType)`: Convert source to target type
- `convertTo(Object? source, Class? sourceType, Class targetType)`: Convert with explicit source type
- `convertWithClass(Object? source, Class targetType)`: Convert using type information from Class object
- `canConvert(Class? sourceType, Class targetType)`: Check if conversion is possible

## Advanced Features

### Type Conversion Cache

`GenericConversionService` maintains a cache of converter lookups to improve performance. The cache is automatically invalidated when converters are added or removed.

### Null Handling

The service properly handles null values according to these rules:
- If the source is null and the target type is not primitive, returns null
- If the source is null and the target type is primitive, throws `ConversionFailedException`
- If the target type is `Optional`, returns an empty `Optional` for null sources

### Primitive Type Conversion

Special handling is provided for Dart primitive types (`int`, `double`, `bool`, etc.) to ensure consistent behavior and proper null handling.

## Best Practices

1. **Reuse Instances**: `GenericConversionService` is designed to be thread-safe and reusable.
2. **Register Converters Early**: Add all converters before performing conversions.
3. **Use Specific Converters**: Prefer specific converters over generic ones when possible for better performance.
4. **Handle Exceptions**: Always handle potential `ConversionException`s.
5. **Consider Performance**: For performance-critical code, check `canConvert()` before attempting conversion.

## Extension Points

### Custom Converters

Implement the `Converter<S, T>` interface for simple conversions or `GenericConverter` for more complex scenarios.

### Converter Factories

Use `ConverterFactory` to create converters dynamically based on the source and target types.

## See Also

- [ConversionService](ConversionService/README.md) - The base interface
- [DefaultConversionService](DefaultConversionService/README.md) - Pre-configured implementation
- [Converter](Converter/README.md) - For creating custom converters
- [ConverterFactory](ConverterFactory/README.md) - For dynamic converter creation
