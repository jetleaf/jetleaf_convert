# JetLeaf Convert API Reference

Welcome to the API documentation for the JetLeaf Convert library. This documentation provides detailed information about the classes, methods, and types available in the package.

## Core Components

### Conversion Services
- [ConversionService](convert/ConversionService/README.md) - The core interface for type conversion operations
- [DefaultConversionService](convert/DefaultConversionService/README.md) - Default implementation of ConversionService
- [GenericConversionService](convert/GenericConversionService/README.md) - Base implementation of the conversion service

### Converters
- [Converter](convert/Converter/README.md) - Base interface for type converters
- [GenericConverter](convert/GenericConverter/README.md) - Generic type converter interface
- [ConverterRegistry](convert/ConverterRegistry/README.md) - For registering and managing converters

### Formatting
- [FormatPrinter](format/FormatPrinter/README.md) - Interface for printing formatted values
- [FormatParser](format/FormatParser/README.md) - Interface for parsing formatted values
- [FormatterRegistry](format/FormatterRegistry/README.md) - For registering formatters

## Utility Classes
- [ConversionUtils](convert/ConversionUtils/README.md) - Utility methods for type conversion
- [ConvertiblePair](convert/ConvertiblePair/README.md) - Represents a source and target type pair
- [ConvertingComparator](convert/ConvertingComparator/README.md) - Comparator that converts elements before comparison

## Getting Started

```dart
import 'package:jetleaf_convert/jetleaf_convert.dart';

void main() {
  final conversionService = DefaultConversionService();
  // Use the conversion service for type conversions
}
```

For more detailed information about specific components, please refer to their respective documentation pages.
