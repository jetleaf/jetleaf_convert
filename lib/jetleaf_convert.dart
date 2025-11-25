/// 🔄 **JetLeaf Convert**
///
/// This is the umbrella library for JetLeaf’s type conversion framework. 
/// It provides access to all conversion utilities, services, and 
/// preconfigured converters for transforming data between types.
///
/// By importing this library, developers can perform conversions 
/// for primitives, collections, objects, time types, and custom types 
/// in a consistent and type-safe manner across JetLeaf applications.
///
/// ## 🔑 Features
///
/// - Core conversion service for runtime type conversion.
/// - Predefined converters for Dart types, collections, maps, and objects.
/// - Utilities for managing conversion adapters and type pairs.
/// - Exception handling for conversion errors.
///
///
/// ## 🎯 Intended Usage
///
/// ```dart
/// import 'package:jetleaf_convert/jetleaf_convert.dart';
///
/// final result = DefaultConversionService().convert<String>(123);
/// print(result); // "123"
/// ```
///
/// Provides a centralized entry point to all JetLeaf conversion features.
///
/// {@category Conversion}
library;

export 'convert.dart';