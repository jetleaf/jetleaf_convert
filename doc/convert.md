# JetLeaf Convert Library

## Overview
The `convert` library is the core of the JetLeaf Convert package, providing a comprehensive type conversion system for Dart applications. It offers a flexible and extensible way to convert between different data types with support for custom converters and formatting.

## Key Features

- **Type Conversion**: Convert between various Dart and custom types
- **Extensible Architecture**: Easily add custom converters for specific type conversions
- **Service-Oriented**: Built around the `ConversionService` interface
- **Dependency Injection Ready**: Designed to work well with DI containers
- **Comprehensive Exception Handling**: Detailed error reporting for conversion failures

## Core Components

### Conversion Services
- `ConversionService` - The main interface for type conversion operations
- `DefaultConversionService` - Standard implementation of the conversion service
- `GenericConversionService` - Base implementation for custom conversion services

### Converters
- `Converter` - Base interface for type converters
- `ConverterRegistry` - Manages registration and lookup of converters
- `ConverterFactory` - Factory for creating converter instances

### Utilities
- `ConversionUtils` - Helper methods for common conversion tasks
- `ConvertiblePair` - Represents a source and target type pair
- `ConvertingComparator` - Comparator that converts elements before comparison

## Basic Usage

```dart
import 'package:jetleaf_convert/jetleaf_convert.dart';

void main() {
  // Create a conversion service with default converters
  final conversionService = DefaultConversionService();
  
  // Basic type conversion
  final int number = conversionService.convert('42', int);
  print(number); // 42
  
  // Collection conversion
  final List<String> stringList = conversionService.convert(
    [1, 2, 3], 
    List<String>
  );
  print(stringList); // ['1', '2', '3']
}
```

## Extending with Custom Converters

You can create custom converters by implementing the `Converter` interface:

```dart
class StringToDateTimeConverter implements Converter<String, DateTime> {
  @override
  DateTime convert(String source) => DateTime.parse(source);
}

// Register the converter
conversionService.addConverter(StringToDateTimeConverter());

// Use the converter
final date = conversionService.convert('2023-01-01', DateTime);
```

## Error Handling

The library provides detailed exceptions for conversion failures:

- `ConversionException`: Base class for all conversion-related exceptions
- `ConverterNotFoundException`: Thrown when no suitable converter is found
- `ConversionFailedException`: Thrown when a conversion fails

## Best Practices

1. **Reuse ConversionService**: Create and reuse a single `ConversionService` instance
2. **Register Converters Early**: Set up all required converters before performing conversions
3. **Handle Exceptions**: Always handle potential conversion exceptions
4. **Use Strong Typing**: Leverage Dart's type system for safer conversions

## See Also

- [API Reference](api/README.md) for detailed class documentation
- [Formatting Guide](format.md) for information on value formatting
- [Migration Guide](migration.md) for upgrading between versions
