# ConverterRegistry

## Overview
`ConverterRegistry` is a central interface for managing and registering type converters in the JetLeaf Convert library. It serves as a container for `Converter`, `ConverterFactory`, and `GenericConverter` instances, enabling dynamic type conversion capabilities in your application.

## Key Features

- **Converter Management**: Register and manage different types of converters
- **Type Safety**: Ensures type safety during converter registration
- **Flexible Registration**: Supports various ways to register converters
- **Hierarchical Lookup**: Handles type hierarchies and inheritance

## Core Methods

### `addConverter<T>(Converter<T, dynamic> converter)`

Registers a generic converter that can convert from type `T` to any other type.

**Parameters:**
- `converter`: The converter to register

**Example:**
```dart
registry.addConverter(StringToIntConverter());
```

### `addConverterWithClass<S, T>(Class<S> sourceType, Class<T> targetType, Converter<S, T> converter)`

Registers a converter for specific source and target types.

**Type Parameters:**
- `S`: Source type
- `T`: Target type

**Parameters:**
- `sourceType`: The source type class
- `targetType`: The target type class
- `converter`: The converter to register

**Example:**
```dart
registry.addConverterWithClass(
  Class<String>(), 
  Class<int>(), 
  StringToIntConverter()
);
```

### `addConverterFactory(ConverterFactory<Object?, Object?> factory)`

Registers a converter factory that can create converters at runtime.

**Parameters:**
- `factory`: The converter factory to register

**Example:**
```dart
registry.addConverterFactory(StringToNumberConverterFactory());
```

### `addGenericConverter(GenericConverter converter)`

Registers a generic converter that can handle multiple type conversions.

**Parameters:**
- `converter`: The generic converter to register

**Example:**
```dart
registry.addGenericConverter(MyGenericConverter());
```

### `removeConvertible(Class<dynamic> sourceType, Class<dynamic> targetType)`

Removes a converter for the specified source and target types.

**Parameters:**
- `sourceType`: The source type
- `targetType`: The target type

**Returns:** `bool` - true if a converter was removed, false otherwise

**Example:**
```dart
registry.removeConvertible(Class<String>(), Class<int>());
```

## Usage Examples

### Basic Registration

```dart
import 'package:jetleaf_convert/jetleaf_convert.dart';
import 'package:jetleaf_lang/lang.dart';

void main() {
  // Create a registry (typically obtained from a ConversionService)
  final registry = DefaultConverterRegistry();
  
  // Register a simple converter
  registry.addConverter(StringToIntConverter());
  
  // Register a converter for specific types
  registry.addConverterWithClass(
    Class<String>(), 
    Class<DateTime>(), 
    StringToDateTimeConverter()
  );
  
  // Register a converter factory
  registry.addConverterFactory(StringToEnumConverterFactory());
}
```

### Working with Generic Types

```dart
// Register a converter for List<String> to List<int>
registry.addConverterWithClass(
  Class<List<String>>(),
  Class<List<int>>(),
  StringListToIntListConverter()
);

// Register a generic Set converter
registry.addGenericConverter(GenericSetConverter());
```

## Best Practices

1. **Centralized Registration**: Register all converters during application startup
2. **Use Specific Converters**: Prefer specific converters over generic ones when possible
3. **Handle Dependencies**: Be aware of converter dependencies and register them in the correct order
4. **Test Registration**: Test your converter registration to ensure all required converters are available
5. **Document Converters**: Document the purpose and behavior of custom converters

## Implementation Notes

- The `ConverterRegistry` is typically used internally by `ConversionService` implementations
- Converters are looked up by both exact type and assignability
- The registry maintains a cache of converter lookups for better performance
- Changes to the registry (add/remove) invalidate the cache

## See Also

- [ConversionService](ConversionService/README.md) - For using the registered converters
- [Converter](Converter/README.md) - Base interface for converters
- [ConverterFactory](ConverterFactory/README.md) - For creating converters dynamically
- [GenericConverter](GenericConverter/README.md) - For advanced conversion scenarios
