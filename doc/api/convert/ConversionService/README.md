# ConversionService

## Overview
`ConversionService` is the core interface for type conversion in the JetLeaf Convert library. It provides methods to check if a conversion is possible and to perform the actual conversion between different types.

## Methods

### `canConvert(Class? sourceType, Class targetType)`

Checks if conversion between the given source and target types is possible.

**Parameters:**
- `sourceType`: The source type to convert from (can be null for dynamic conversion)
- `targetType`: The target type to convert to

**Returns:** `bool` - true if conversion is possible, false otherwise

### `convert<T>(Object? source, Class<T> targetType)`

Converts the given source object to the specified target type.

**Type Parameters:**
- `T`: The target type to convert to

**Parameters:**
- `source`: The source object to convert (can be null)
- `targetType`: The target type class object

**Returns:** `T` - The converted object

**Throws:**
- `ConversionException` if conversion fails

### `convertWithClass(Object? source, Class targetType)`

Converts the source to the specified target type using Class metadata.

**Parameters:**
- `source`: The source object to convert (can be null)
- `targetType`: The target type class object

**Returns:** `Object?` - The converted object

### `convertTo(Object? source, Class? sourceType, Class targetType)`

Converts the source from sourceType to targetType.

**Parameters:**
- `source`: The source object to convert (can be null)
- `sourceType`: The source type (can be null for dynamic conversion)
- `targetType`: The target type

**Returns:** `Object?` - The converted object

## Usage Example

```dart
import 'package:jetleaf_convert/jetleaf_convert.dart';
import 'package:jetleaf_lang/lang.dart';

void main() {
  final service = DefaultConversionService();
  
  // Check if conversion is possible
  if (service.canConvert(Class<String>(), Class<int>())) {
    // Perform the conversion
    final result = service.convert<int>('42', Class<int>());
    print(result); // 42
  }
  
  // Convert collections
  final list = ['1', '2', '3'];
  final set = service.convertWithClass(
    list, 
    Class.setOf(Class<int>())
  ) as Set<int>;
  
  print(set); // {1, 2, 3}
}
```

## Implementing a Custom ConversionService

You can create a custom implementation of `ConversionService` by implementing the interface:

```dart
class CustomConversionService implements ConversionService {
  @override
  bool canConvert(Class? sourceType, Class targetType) {
    // Custom implementation
  }
  
  @override
  T convert<T>(Object? source, Class<T> targetType) {
    // Custom implementation
  }
  
  // Implement other required methods
}
```

## Best Practices

1. **Reuse Instances**: `ConversionService` implementations are typically thread-safe and should be reused.
2. **Check Before Convert**: Always use `canConvert()` before attempting conversion to avoid exceptions.
3. **Handle Nulls**: Be prepared to handle null source values appropriately.
4. **Provide Meaningful Errors**: When implementing custom converters, provide clear error messages for failed conversions.

## See Also
- [DefaultConversionService](DefaultConversionService/README.md) - The default implementation of ConversionService
- [ConfigurableConversionService](ConfigurableConversionService/README.md) - For dynamically registering converters
- [Converter](Converter/README.md) - Interface for type converters
