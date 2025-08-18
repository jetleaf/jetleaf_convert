// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'package:jetleaf_lang/lang.dart';

import '../converter/converter_registry.dart';

/// {@template format_printer}
/// An interface for converting an object of type `T` into a localized string representation.
///
/// Implementations of [FormatPrinter] define how a given object should be formatted
/// according to a specific [Locale]. This is useful for presenting numbers, dates,
/// currency values, or other locale-sensitive data in a human-readable form.
///
/// ### Type Parameters:
/// - `T`: The type of object this printer formats.
///
/// ### Example
/// ```dart
/// class CurrencyPrinter implements FormatPrinter<double> {
///   @override
///   String print(double amount, Locale locale) {
///     final symbol = locale.languageCode == 'en' ? '\$' : '€';
///     return '$symbol${amount.toStringAsFixed(2)}';
///   }
/// }
///
/// final printer = CurrencyPrinter();
/// print(printer.print(1234.56, Locale('en'))); // $1234.56
/// print(printer.print(1234.56, Locale('fr'))); // €1234.56
/// ```
/// {@endtemplate}
@Generic(FormatPrinter)
abstract interface class FormatPrinter<T> {
  /// {@template format_printer_print}
  /// Formats an instance of type `T` into a localized string for display.
  ///
  /// Parameters:
  /// - [object]: The value to format.
  /// - [locale]: The target [Locale] that influences things like decimal separators,
  ///   currency symbols, date/time patterns, etc.
  ///
  /// Returns:
  /// - A human-readable, locale-aware `String` representation of [object].
  ///
  /// ## Example
  /// ```dart
  /// class CurrencyPrinter implements FormatPrinter<double> {
  ///   @override
  ///   String print(double amount, Locale locale) {
  ///     final symbol = locale.languageCode == 'en' ? '\$' : '€';
  ///     return '$symbol${amount.toStringAsFixed(2)}';
  ///   }
  /// }
  ///
  /// final printer = CurrencyPrinter();
  /// final textEn = printer.print(1234.5, Locale('en')); // $1234.50
  /// final textFr = printer.print(1234.5, Locale('fr')); // €1234.50
  /// ```
  /// {@endtemplate}
  String print(T object, Locale locale);
}

/// {@template format_parser}
/// An interface for parsing a localized string into an object of type `T`.
///
/// Implementations of [FormatParser] define how text, typically provided by a user
/// or an external source, is converted back into a strongly typed object. Parsing
/// should be sensitive to the given [Locale] for correct interpretation.
///
/// ### Type Parameters:
/// - `T`: The type of object to parse from the string.
///
/// ### Example
/// ```dart
/// class CurrencyParser implements FormatParser<double> {
///   @override
///   double parse(String text, Locale locale) {
///     final cleaned = text.replaceAll(RegExp(r'[^\d.,-]'), '');
///     return double.parse(cleaned);
///   }
/// }
///
/// final parser = CurrencyParser();
/// print(parser.parse("\$1234.56", Locale('en'))); // 1234.56
/// ```
/// {@endtemplate}
@Generic(FormatParser)
abstract interface class FormatParser<T> {
  /// {@template format_parser_parse}
  /// Parses a localized string into an instance of type `T`.
  ///
  /// Parameters:
  /// - [text]: The user-supplied or external string to parse.
  /// - [locale]: The [Locale] to interpret [text] under (e.g., decimal separators).
  ///
  /// Returns:
  /// - A strongly typed value of type `T` parsed from [text].
  ///
  /// Throws:
  /// - [FormatException] (or a domain-specific exception) if parsing fails.
  ///
  /// ## Example
  /// ```dart
  /// class CurrencyParser implements FormatParser<double> {
  ///   @override
  ///   double parse(String text, Locale locale) {
  ///     // Remove currency symbols and non-numeric characters except separators/sign.
  ///     final cleaned = text.replaceAll(RegExp(r'[^\d.,+-]'), '');
  ///     // Normalize comma to dot if needed, then parse.
  ///     final canonical = locale.languageCode == 'fr'
  ///       ? cleaned.replaceAll(',', '.')
  ///       : cleaned;
  ///     return double.parse(canonical);
  ///   }
  /// }
  ///
  /// final parser = CurrencyParser();
  /// final value = parser.parse('\$1,234.50', Locale('en')); // 1234.5
  /// ```
  /// {@endtemplate}
  T parse(String text, Locale locale);
}

/// {@template formatter}
/// A composite interface that combines both [FormatPrinter] and [FormatParser].
///
/// A [Formatter] is capable of both producing a localized string from an object
/// and parsing that string back into an object of the same type. This makes it
/// ideal for scenarios where two-way data transformation is needed, such as
/// form inputs, serialization, and user-facing displays.
///
/// ### Type Parameters:
/// - `T`: The type of object to format and parse.
///
/// ### Example
/// ```dart
/// class CurrencyFormatter implements Formatter<double> {
///   @override
///   String print(double amount, Locale locale) {
///     final symbol = locale.languageCode == 'en' ? '\$' : '€';
///     return '$symbol${amount.toStringAsFixed(2)}';
///   }
///
///   @override
///   double parse(String text, Locale locale) {
///     final cleaned = text.replaceAll(RegExp(r'[^\d.,-]'), '');
///     return double.parse(cleaned);
///   }
/// }
///
/// final formatter = CurrencyFormatter();
/// final text = formatter.print(1234.56, Locale('en')); // $1234.56
/// final value = formatter.parse(text, Locale('en'));   // 1234.56
/// ```
/// {@endtemplate}
@Generic(Formatter)
abstract interface class Formatter<T> implements FormatPrinter<T>, FormatParser<T> {}

/// {@template annotation_formatter_factory}
/// A factory for creating formatters based on a specific annotation.
///
/// Implementations of this abstract class produce [FormatPrinter] and [FormatParser]
/// instances for fields annotated with a given annotation type `A`. This allows
/// developers to declaratively control formatting behavior through annotations.
///
/// ### Type Parameters:
/// - `A`: The annotation type that controls formatting, extending [ReflectableAnnotation].
///
/// ### Example
/// ```dart
/// @CurrencyFormat(symbol: '\$')
/// double price;
///
/// class CurrencyAnnotationFormatterFactory
///     extends AnnotationFormatterFactory<CurrencyFormat> {
///   @override
///   Set<Class> getFieldTypes() => {Class.forType(double)};
///
///   @override
///   FormatPrinter getPrinter(CurrencyFormat annotation, Class fieldType) {
///     return CurrencyPrinter(annotation.symbol);
///   }
///
///   @override
///   FormatParser getParser(CurrencyFormat annotation, Class fieldType) {
///     return CurrencyParser();
///   }
/// }
/// ```
/// {@endtemplate}
@Generic(AnnotationFormatterFactory)
abstract class AnnotationFormatterFactory<A extends ReflectableAnnotation> {
  /// {@template annotation_formatter_factory_get_field_types}
  /// Returns the set of field types this factory can handle for the annotation `A`.
  ///
  /// The returned [Class] entries indicate which **field value types** (e.g., `int`,
  /// `double`, `DateTime`) may be paired with the annotation `A` to obtain printers
  /// and parsers from this factory.
  ///
  /// Returns:
  /// - A `Set<Class>` describing the supported field value types.
  ///
  /// ## Example
  /// ```dart
  /// class DateAnnotationFactory extends AnnotationFormatterFactory<DateFormatAnn> {
  ///   @override
  ///   Set<Class> getFieldTypes() => { Class.forType(DateTime) };
  /// }
  /// ```
  /// {@endtemplate}
  Set<Class> getFieldTypes();

  /// {@template annotation_formatter_factory_get_printer}
  /// Provides a [FormatPrinter] for a field annotated with [annotation].
  ///
  /// Parameters:
  /// - [annotation]: The concrete annotation of type `A` present on the field.
  /// - [fieldType]: The value type of the field (as [Class]).
  ///
  /// Returns:
  /// - A [FormatPrinter] configured according to [annotation] and [fieldType].
  ///
  /// ## Example
  /// ```dart
  /// class DateAnnotationFactory extends AnnotationFormatterFactory<DateFormatAnn> {
  ///   @override
  ///   FormatPrinter getPrinter(DateFormatAnn ann, Class fieldType) {
  ///     return _DatePrinter(pattern: ann.pattern);
  ///   }
  /// }
  ///
  /// // Later, given a field annotated with @DateFormatAnn('yyyy-MM-dd')
  /// final printer = factory.getPrinter(ann, Class.forType(DateTime));
  /// final text = printer.print(DateTime(2025, 8, 15), Locale('en')); // "2025-08-15"
  /// ```
  /// {@endtemplate}
  FormatPrinter getPrinter(A annotation, Class fieldType);

  /// {@template annotation_formatter_factory_get_parser}
  /// Provides a [FormatParser] for a field annotated with [annotation].
  ///
  /// Parameters:
  /// - [annotation]: The concrete annotation of type `A` present on the field.
  /// - [fieldType]: The value type of the field (as [Class]).
  ///
  /// Returns:
  /// - A [FormatParser] configured according to [annotation] and [fieldType].
  ///
  /// ## Example
  /// ```dart
  /// class DateAnnotationFactory extends AnnotationFormatterFactory<DateFormatAnn> {
  ///   @override
  ///   FormatParser getParser(DateFormatAnn ann, Class fieldType) {
  ///     return _DateParser(pattern: ann.pattern);
  ///   }
  /// }
  ///
  /// final parser = factory.getParser(ann, Class.forType(DateTime));
  /// final value = parser.parse('2025-08-15', Locale('en')); // DateTime(...)
  /// ```
  /// {@endtemplate}
  FormatParser getParser(A annotation, Class fieldType);
}

/// {@template formatter_registry}
/// A registry for managing formatters, printers, and parsers.
///
/// [FormatterRegistry] stores and organizes different [FormatPrinter], [FormatParser],
/// and [Formatter] instances. It supports registration by field type or by annotation,
/// enabling both explicit and declarative formatting configurations.
///
/// ### Usage
/// You can register:
/// - A standalone printer
/// - A standalone parser
/// - A combined formatter
/// - A formatter for a specific field type
/// - A formatter based on an annotation
///
/// ### Example
/// ```dart
/// final registry = MyFormatterRegistry();
///
/// registry.addPrinter(CurrencyPrinter());
/// registry.addParser(CurrencyParser());
/// registry.addFormatter(CurrencyFormatter());
/// registry.addFormatterForFieldType(Class.forType(double), CurrencyFormatter());
/// registry.addFormatterForFieldAnnotation(CurrencyAnnotationFormatterFactory());
/// ```
/// {@endtemplate}
abstract class FormatterRegistry extends ConverterRegistry {
  /// {@template formatter_registry_add_printer}
  /// Registers a standalone [FormatPrinter] in the registry.
  ///
  /// Use this when you only need one-way formatting (object → string) for a type.
  ///
  /// Parameters:
  /// - [printer]: The printer to register.
  ///
  /// ## Example
  /// ```dart
  /// registry.addPrinter(CurrencyPrinter());
  /// final text = registry
  ///   .findPrinter<double>() // hypothetical lookup
  ///   ?.print(42, Locale('en'));
  /// ```
  /// {@endtemplate}
  void addPrinter(FormatPrinter printer);

  /// {@template formatter_registry_add_parser}
  /// Registers a standalone [FormatParser] in the registry.
  ///
  /// Use this for one-way parsing (string → object) scenarios.
  ///
  /// Parameters:
  /// - [parser]: The parser to register.
  ///
  /// ## Example
  /// ```dart
  /// registry.addParser(CurrencyParser());
  /// final value = registry
  ///   .findParser<double>() // hypothetical lookup
  ///   ?.parse('\$42.00', Locale('en'));
  /// ```
  /// {@endtemplate}
  void addParser(FormatParser parser);

  /// {@template formatter_registry_add_formatter}
  /// Registers a combined two-way [Formatter] (printer + parser) for type `T`.
  ///
  /// Parameters:
  /// - [formatter]: The formatter to register.
  ///
  /// ## Example
  /// ```dart
  /// registry.addFormatter(CurrencyFormatter());
  /// final f = registry.findFormatter<double>(); // hypothetical lookup
  /// final text = f?.print(99.95, Locale('en'));
  /// final val  = f?.parse('\$99.95', Locale('en'));
  /// ```
  /// {@endtemplate}
  void addFormatter(Formatter formatter);

  /// {@template formatter_registry_add_formatter_for_field_type}
  /// Registers a [Formatter] explicitly for a specific field [fieldType].
  ///
  /// Use this to disambiguate when multiple formatters exist for the same `T`
  /// but different contexts or field roles.
  ///
  /// Parameters:
  /// - [fieldType]: The field’s value type (as [Class]).
  /// - [formatter]: The two-way formatter to use for this field type.
  ///
  /// ## Example
  /// ```dart
  /// registry.addFormatterForFieldType(
  ///   Class.forType(double),
  ///   CurrencyFormatter(),
  /// );
  /// ```
  /// {@endtemplate}
  void addFormatterForFieldType(Class fieldType, Formatter formatter);

  /// {@template formatter_registry_add_formatter_for_field_type_with_parser}
  /// Registers a split configuration for a specific field [fieldType]:
  /// a [FormatPrinter] and a [FormatParser].
  ///
  /// This is useful when printing and parsing strategies differ or come from
  /// different components.
  ///
  /// Parameters:
  /// - [fieldType]: The field’s value type (as [Class]).
  /// - [printer]: The printer to use for this field type.
  /// - [parser]: The parser to use for this field type.
  ///
  /// ## Example
  /// ```dart
  /// registry.addFormatterForFieldTypeWithParser(
  ///   Class.forType(DateTime),
  ///   IsoDatePrinter(),     // prints ISO 8601
  ///   FlexibleDateParser(), // parses multiple patterns
  /// );
  /// ```
  /// {@endtemplate}
  void addFormatterForFieldTypeWithParser(Class fieldType, FormatPrinter printer, FormatParser parser);

  /// {@template formatter_registry_add_formatter_for_field_annotation}
  /// Registers an [AnnotationFormatterFactory] so that fields annotated with `A`
  /// can automatically obtain printers and/or parsers.
  ///
  /// Parameters:
  /// - [annotationFormatterFactory]: The factory that creates printers/parsers
  ///   for fields carrying its supported annotation.
  ///
  /// ## Example
  /// ```dart
  /// registry.addFormatterForFieldAnnotation(
  ///   DateAnnotationFactory(), // handles @DateFormatAnn
  /// );
  ///
  /// // Later, when resolving a field annotated with @DateFormatAnn,
  /// // the registry can ask the factory for the right printer/parser.
  /// ```
  /// {@endtemplate}
  void addFormatterForFieldAnnotation(AnnotationFormatterFactory annotationFormatterFactory);
}

/// {@template formatter_registrar}
/// An abstract interface class that defines a contract for registering
/// formatters and converters in a formatting system.
///
/// This interface should be implemented by classes that want to provide
/// custom formatters and converters for use with a
/// [FormatterRegistry]. Implementations typically register various
/// formatters for different types to ensure consistent parsing and
/// printing of objects.
///
/// Example usage:
/// ```dart
/// class MyFormatterRegistrar implements FormatterRegistrar {
///   @override
///   void registerFormatters(FormatterRegistry registry) {
///     registry.addFormatter(DateTimeFormatter());
///     registry.addConverter(StringToIntConverter());
///   }
/// }
///
/// final registrar = MyFormatterRegistrar();
/// final registry = FormatterRegistry();
/// registrar.registerFormatters(registry);
/// ```
/// {@endtemplate}
abstract interface class FormatterRegistrar {
  /// {@macro formatter_registrar}
  ///
  /// Registers formatters and converters with the given [registry].
  ///
  /// The [registry] parameter is the instance of [FormatterRegistry] where
  /// the formatters and converters should be registered.
  void registerFormatters(FormatterRegistry registry);
}