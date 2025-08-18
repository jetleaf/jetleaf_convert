# ConversionUtils

## Overview
`ConversionUtils` is a utility class that provides helper methods for type conversion operations within the JetLeaf Convert library. It contains static methods that simplify common conversion tasks and handle error cases consistently.

## Key Features

- **Safe Converter Invocation**: Safely invoke converters with proper error handling
- **Type Checking**: Check if types can be converted
- **Collection Conversion**: Determine if element-wise conversion is possible
- **Enum Handling**: Resolve enum types and values

## Core Methods

### `invokeConverter(GenericConverter converter, Object? source, Class sourceType, Class targetType)`

Invokes a generic converter with proper error handling.

**Parameters:**
- `converter`: The converter to invoke
- `source`: The source object to convert
- `sourceType`: The source type descriptor
- `targetType`: The target type descriptor

**Returns:** `Object?` - The converted object

**Throws:**
- `ConversionFailedException` if conversion fails

**Example:**
```dart
final result = ConversionUtils.invokeConverter(
  myConverter,
  '123',
  Class<String>(),
  Class<int>()
);
```

### `canConvertElements(Class? sourceElementType, Class? targetElementType, ConversionService conversionService)`

Checks if elements of a collection can be converted from one type to another.

**Parameters:**
- `sourceElementType`: The type of elements in the source collection
- `targetElementType`: The desired type of elements in the target collection
- `conversionService`: The conversion service to use

**Returns:** `bool` - True if element conversion is possible

**Example:**
```dart
final canConvert = ConversionUtils.canConvertElements(
  Class<String>(),
  Class<int>(),
  conversionService
);
```

### `resolveEnumType(Class<?> enumType)`

Resolves the enum type from a class that might be an enum or an array of enums.

**Parameters:**
- `enumType`: The type to check

**Returns:** `Class<? extends Enum>?` - The enum type, or null if not an enum

**Example:**
```dart
final enumType = ConversionUtils.resolveEnumType(MyEnum.values.runtimeType);
```

## Usage Examples

### Safe Converter Invocation

```dart
import 'package:jetleaf_convert/conversion_utils.dart';
import 'package:jetleaf_lang/lang.dart';

void main() {
  final converter = MyCustomConverter();
  
  try {
    final result = ConversionUtils.invokeConverter(
      converter,
      '42',
      Class<String>(),
      Class<int>()
    );
    print('Conversion result: $result');
  } on ConversionFailedException catch (e) {
    print('Conversion failed: ${e.message}');
  }
}
```

### Checking Element Conversion

```dart
bool canConvertList(List<String> stringList, Class targetElementType) {
  return ConversionUtils.canConvertElements(
    Class<String>(),
    targetElementType,
    DefaultConversionService.shared
  );
}

void main() {
  final strings = ['1', '2', '3'];
  final canConvertToInts = canConvertList(strings, Class<int>());
  print('Can convert to ints: $canConvertToInts');
}
```

### Working with Enums

```dart
enum Status { active, inactive, pending }

void main() {
  final enumType = ConversionUtils.resolveEnumType(Status.values.runtimeType);
  if (enumType != null) {
    print('Found enum type: $enumType');
    
    // Convert string to enum
    final status = enumType.enumValues
        .firstWhere((e) => e.name == 'active', orElse: () => null);
    print('Status: $status');
  }
}
```

## Best Practices

1. **Error Handling**: Always handle `ConversionFailedException` when using `invokeConverter`
2. **Null Safety**: Be aware that source values and results can be null
3. **Type Safety**: Use proper type descriptors when specifying source and target types
4. **Performance**: Cache type descriptors when used repeatedly

## Performance Considerations

- Type resolution and conversion checks have minimal overhead
- For performance-critical code, consider caching the results of type checks
- Element conversion checks are relatively inexpensive but involve type system operations

## See Also

- [ConversionService](ConversionService/README.md) - The main conversion service interface
- [GenericConverter](GenericConverter/README.md) - Interface for type converters
- [ConvertiblePair](ConvertiblePair/README.md) - Represents a source and target type pair
