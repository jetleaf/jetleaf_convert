# Exception Handling

This document describes the exception hierarchy and usage patterns for error handling in the JetLeaf Convert library.

## Exception Hierarchy

```
Exception
└── ConversionException
    ├── ConversionFailedException
    └── ConverterNotFoundException
```

## Core Exception Types

### `ConversionException`

Base exception class for all conversion-related errors.

**Properties:**
- `message`: A description of the error

**Example:**
```dart
try {
  final result = conversionService.convert('invalid', int);
} on ConversionException catch (e) {
  print('Conversion failed: ${e.message}');
}
```

### `ConversionFailedException`

Thrown when a conversion attempt fails during execution.

**Properties:**
- `sourceType`: The source type being converted from
- `targetType`: The target type being converted to
- `value`: The value that failed to convert
- `cause`: The underlying exception that caused the failure (optional)

**Example:**
```dart
try {
  final result = conversionService.convert('not_a_number', int);
} on ConversionFailedException catch (e) {
  print('''
    Failed to convert ${e.value} 
    from ${e.sourceType} to ${e.targetType}:
    ${e.cause}
  ''');
}
```

### `ConverterNotFoundException`

Thrown when no suitable converter can be found for the requested conversion.

**Properties:**
- `sourceType`: The source type that was requested
- `targetType`: The target type that was requested

**Example:**
```dart
try {
  final result = conversionService.convert(customObject, String);
} on ConverterNotFoundException catch (e) {
  print('''
    No converter found for conversion from 
    ${e.sourceType} to ${e.targetType}.
    Did you forget to register a converter?
  ''');
}
```

## Best Practices

### Error Handling Patterns

#### Basic Error Handling

```dart
try {
  final result = conversionService.convert(input, targetType);
  // Handle successful conversion
} on ConverterNotFoundException {
  // Handle missing converter
} on ConversionFailedException {
  // Handle conversion failure
} on ConversionException catch (e) {
  // Handle other conversion errors
  logger.severe('Conversion error: ${e.message}');
  rethrow; // Re-throw if needed
}
```

#### Creating Custom Exceptions

```dart
class MyCustomConversionException extends ConversionException {
  final dynamic originalValue;
  
  MyCustomConversionException(
    String message, 
    this.originalValue
  ) : super('$message (value: $originalValue)');
}
```

### Logging and Debugging

```dart
try {
  return conversionService.convert(value, targetType);
} on ConversionException catch (e, stackTrace) {
  logger.severe(
    'Failed to convert $value to $targetType',
    e,
    stackTrace,
  );
  rethrow;
}
```

## Common Scenarios

### Handling Missing Converters

```dart
T convertSafely<T>(dynamic value, {T? defaultValue}) {
  try {
    return conversionService.convert(value, T);
  } on ConverterNotFoundException {
    if (defaultValue != null) return defaultValue;
    rethrow;
  }
}
```

### Validating Input Before Conversion

```dart
T convertWithValidation<T>(dynamic value) {
  if (value == null) {
    throw ArgumentError('Value cannot be null');
  }
  
  final sourceType = Class.forObject(value);
  final targetType = Class<T>();
  
  if (!conversionService.canConvert(sourceType, targetType)) {
    throw StateError('No converter available from $sourceType to $targetType');
  }
  
  return conversionService.convert(value, targetType);
}
```

## Error Recovery Strategies

### Fallback Values

```dart
T convertWithFallback<T>(dynamic value, T fallback) {
  try {
    return conversionService.convert(value, T) ?? fallback;
  } on ConversionException {
    return fallback;
  }
}
```

### Retry Logic

```dart
Future<T> convertWithRetry<T>(
  dynamic value, {
  int maxAttempts = 3,
  Duration delay = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    try {
      return conversionService.convert(value, T);
    } on ConversionException {
      if (i == maxAttempts - 1) rethrow;
      await Future.delayed(delay * (i + 1));
    }
  }
  throw StateError('Unreachable');
}
```

## Testing Exception Cases

```dart
test('conversion throws on invalid input', () {
  expect(
    () => conversionService.convert('invalid', int),
    throwsA(isA<ConversionFailedException>()),
  );
});

test('conversion throws when no converter available', () {
  expect(
    () => conversionService.convert(CustomObject(), String),
    throwsA(isA<ConverterNotFoundException>()),
  );
});
```

## See Also

- [ConversionService](ConversionService/README.md) - Main conversion interface
- [Converter](Converter/README.md) - Base converter interface
- [GenericConverter](GenericConverter/README.md) - Advanced converter interface
