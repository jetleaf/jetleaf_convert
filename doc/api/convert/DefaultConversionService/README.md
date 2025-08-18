# DefaultConversionService

## Overview
`DefaultConversionService` is the standard implementation of the [ConversionService](ConversionService/README.md) interface, pre-configured with a comprehensive set of converters for common type conversions. It extends [GenericConversionService](GenericConversionService/README.md) and adds default converters during construction.

## Features

- **Pre-configured Converters**: Comes with built-in converters for common types
- **Thread-safe**: Can be safely shared across multiple threads
- **Extensible**: Additional converters can be registered at runtime
- **Singleton Support**: Provides a shared instance through `shared` getter

## Default Converters

The following converters are registered by default:

- **Primitive Types**: `String`, `num`, `int`, `double`, `bool`
- **Temporal Types**: `DateTime`, `Duration`
- **Collections**: `List`, `Set`, `Map`
- **Miscellaneous**: `Uri`, `BigInt`, `Symbol`

## Usage

### Basic Usage

```dart
import 'package:jetleaf_convert/jetleaf_convert.dart';
import 'package:jetleaf_lang/lang.dart';

void main() {
  // Create a new instance
  final service = DefaultConversionService();
  
  // Convert between basic types
  final number = service.convert('42', Class<int>());
  print(number); // 42
  
  // Convert collections
  final list = service.convert(
    {'one': 1, 'two': 2, 'three': 3}.entries.toList(),
    Class<Map<String, int>>()
  );
  print(list); // {'one': 1, 'two': 2, 'three': 3}
}
```

### Using the Shared Instance

```dart
// Get the shared instance (lazily initialized)
final service = DefaultConversionService.shared;

// Use it for conversions
final date = service.convert('2023-01-01', Class<DateTime>());
print(date); // 2023-01-01 00:00:00.000
```

### Adding Custom Converters

```dart
class StringToUriConverter implements Converter<String, Uri> {
  @override
  Uri convert(String source) => Uri.parse(source);
}

void main() {
  final service = DefaultConversionService();
  
  // Add a custom converter
  service.addConverter(StringToUriConverter());
  
  // Use the custom converter
  final uri = service.convert('https://example.com', Class<Uri>());
  print(uri); // https://example.com
}
```

## Methods

### `addDefaultConverters(ConfigurableConversionService service)`

Static method that adds all default converters to the specified conversion service.

**Parameters:**
- `service`: The conversion service to configure with default converters

### `shared`

Static getter that returns a shared instance of `DefaultConversionService`.
The instance is lazily initialized on first access.

## Best Practices

1. **Reuse Instances**: Prefer using the shared instance when possible to avoid redundant converter registration.
2. **Register Early**: Add all custom converters before performing any conversions.
3. **Thread Safety**: The service is thread-safe, but be aware of potential race conditions during converter registration.
4. **Error Handling**: Always handle potential `ConversionException`s when performing conversions.

## Performance Considerations

- The first conversion between two types may be slower due to converter lookup caching.
- The service maintains a cache of converter lookups for better performance.
- Consider using `canConvert()` before attempting conversion if the operation is expensive.

## See Also

- [ConversionService](ConversionService/README.md) - The base interface
- [GenericConversionService](GenericConversionService/README.md) - The parent class
- [Converter](Converter/README.md) - For creating custom converters
