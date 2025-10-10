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

import 'conversion_service.dart';
import 'simple_conversion_service.dart';
import 'converter_registry.dart';

import '../types/time_converters.dart';
import '../types/map_converters.dart';
import '../types/jl_converters.dart';
import '../types/collection_converters.dart';
import '../types/object_converters.dart';
import '../types/dart_converters.dart';

/// A specialization of [SimpleConversionService] configured by default
/// with converters appropriate for most environments.
/// 
/// Designed for direct instantiation but also exposes the static
/// [addDefaultConverters] utility method for ad-hoc use against any
/// [ConverterRegistry] instance.
/// 
/// Example:
/// ```dart
/// final service = DefaultConversionService();
/// final result = service.convert('123', Class.forType(int));
/// print(result); // 123
/// ```
class DefaultConversionService extends SimpleConversionService {
  static DefaultConversionService? _sharedInstance;
  static ZoneId defaultZone = ZoneId.systemDefault();
  
  /// Create a new [DefaultConversionService] with the set of default converters.
  DefaultConversionService([super.protectionDomain]) {
    addDefaultConverters(this);
  }
  
  /// Return a shared default [ConversionService] instance, lazily building it once needed.
  /// 
  /// **NOTE:** We highly recommend constructing individual [ConversionService] instances
  /// for customization purposes. This accessor is only meant as a fallback for code paths
  /// which need simple type coercion but cannot access a longer-lived [ConversionService]
  /// instance any other way.
  static ConversionService getSharedInstance() {
    DefaultConversionService? cs = _sharedInstance;
    if (cs == null) {
      return synchronized(DefaultConversionService, () {
        cs = _sharedInstance;
        if (cs == null) {
          cs = DefaultConversionService();
          _sharedInstance = cs;
        }

        return cs!;
      });
    }
    return cs;
  }
  
  /// Add converters appropriate for most environments.
  static void addDefaultConverters(ConverterRegistry registry) {
    addScalarConverters(registry);
    addTimeConverters(registry);
    addMapConverters(registry);
    addJetLeafConverters(registry);
    addOtherDartConverters(registry);
    
    // Core object converters
    registry.addPairedConverter(ObjectToObjectConverter());
    registry.addPairedConverter(FallbackObjectToStringConverter());

    addCollectionConverters(registry);
  }
  
  /// Add time-related converters.
  static void addTimeConverters(ConverterRegistry registry) {
    // String to time object converters
    registry.addConverter(StringToDateTimeConverter());
    registry.addConverter(StringToLocalDateTimeConverter());
    registry.addConverter(StringToLocalDateConverter());
    registry.addConverter(StringToLocalTimeConverter());
    registry.addConverter(StringToZoneIdConverter());
    registry.addConverter(StringToDurationConverter());
    
    // Time object to string converters
    registry.addConverter(DateTimeToStringConverter());
    registry.addConverter(LocalDateTimeToStringConverter());
    registry.addConverter(LocalDateToStringConverter());
    registry.addConverter(LocalTimeToStringConverter());
    registry.addConverter(LocalTimeToStringConverter());
    registry.addConverter(ZonedDateTimeToStringConverter());
    registry.addConverter(DurationToStringConverter());
    
    // DateTime cross-conversions
    registry.addConverter(DateTimeToLocalDateTimeConverter());
    registry.addConverter(LocalDateTimeToDateTimeConverter());
    registry.addConverter(DateTimeToLocalDateConverter());
    registry.addConverter(LocalDateToDateTimeConverter());
    registry.addConverter(DateTimeToLocalTimeConverter());
    registry.addConverter(DateTimeToZonedDateTimeConverter());
    registry.addConverter(ZonedDateTimeToDateTimeConverter());
    
    // Epoch milliseconds converters
    registry.addConverter(IntToDateTimeConverter());
    registry.addConverter(DateTimeToIntConverter());
    registry.addConverter(IntToZonedDateTimeConverter(defaultZone));
    registry.addConverter(ZonedDateTimeToIntConverter());
    registry.addConverter(IntToDurationConverter());
    registry.addConverter(DurationToIntConverter());
    
    // Cross-type converters
    registry.addConverter(LocalDateTimeToLocalDateConverter());
    registry.addConverter(LocalDateTimeToLocalTimeConverter());
    registry.addConverter(LocalDateAndLocalTimeToLocalDateTimeConverter());
    registry.addConverter(LocalDateTimeToZonedDateTimeConverter(defaultZone));
    registry.addConverter(ZonedDateTimeToLocalDateTimeConverter());
    registry.addConverter(ZonedDateTimeToLocalDateConverter());
    registry.addConverter(ZonedDateTimeToLocalTimeConverter());
    registry.addConverter(ZonedDateTimeToZoneIdConverter());
  }
  
  /// Add map-related converters.
  static void addMapConverters(ConverterRegistry registry) {
    final conversionService = registry as ConversionService;
    
    registry.addPairedConverter(StringToMapGenericConverter(conversionService));
    registry.addPairedConverter(MapToStringGenericConverter(conversionService));
    registry.addPairedConverter(MapToMapGenericConverter(conversionService));
  }
  
  /// Add JetLeaf-specific converters.
  static void addJetLeafConverters(ConverterRegistry registry) {
    registry.addConverter(StringToUuidConverter());
    registry.addConverter(UuidToStringConverter());
    registry.addConverter(StringToCurrencyConverter());
    registry.addConverter(CurrencyToStringConverter());
    registry.addConverter(StringToLocaleConverter());
    registry.addConverter(LocaleToStringConverter());
    registry.addPairedConverter(ByteMultiConverter());
  }
  
  /// Add other Dart built-in type converters.
  static void addOtherDartConverters(ConverterRegistry registry) {
    // Runes converters
    registry.addConverter(StringToRunesConverter());
    registry.addConverter(RunesToStringConverter());
    
    // Symbol converters
    registry.addConverter(StringToSymbolConverter());
    registry.addConverter(SymbolToStringConverter());
    
    // URI converters
    if(registry is ListableConverterRegistry) {
      registry.addConverter(StringToUriConverter(registry.getUriValidators()));
    }

    registry.addConverter(UriToStringConverter());
    
    // RegExp converters
    registry.addConverter(StringToRegExpConverter());
    registry.addConverter(RegExpToStringConverter());
    registry.addConverter(StringToPatternConverter());
    registry.addConverter(PatternToStringConverter());
  }

  /// Add common collection converters.
  static void addCollectionConverters(ConverterRegistry registry) {
    final conversionService = registry as ConversionService;

    registry.addPairedConverter(StringGenericConverter());
    registry.addPairedConverter(DoubleGenericConverter());
    registry.addPairedConverter(IntGenericConverter());

    // Object converters
    registry.addPairedConverter(ObjectToListConverter(conversionService));
    registry.addPairedConverter(ObjectToSetConverter(conversionService));
    registry.addPairedConverter(ListToObjectConverter(conversionService));
    registry.addPairedConverter(SetToObjectConverter(conversionService));

    registry.addPairedConverter(SetToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(QueueToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(IterableToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(ArrayListToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(SetBaseToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(ListBaseToCollectionConverter(conversionService));
    registry.addPairedConverter(LinkedQueueToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(LinkedListToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(LinkedHashSetToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(HashSetToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(StackToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(LinkedStackToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(IterableToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(ArrayListToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(SetBaseToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(ListBaseToCollectionConverter(conversionService));
    registry.addPairedConverter(LinkedQueueToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(LinkedListToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(LinkedHashSetToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(HashSetToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(StackToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(LinkedStackToCollectionGenericConverter(conversionService));
    registry.addPairedConverter(ListToCollectionConverter(conversionService));
  }
  
  static void addScalarConverters(ConverterRegistry registry) {
    registry.addPairedConverter(NumberGenericConverter());
    registry.addPairedConverter(BoolGenericConverter());
    registry.addPairedConverter(BigIntGenericConverter());
    registry.addPairedConverter(IntegerGenericConverter());
    registry.addPairedConverter(LongGenericConverter());
    registry.addPairedConverter(FloatGenericConverter());
    registry.addPairedConverter(BigIntegerGenericConverter());
    registry.addPairedConverter(BigDecimalGenericConverter());
    registry.addPairedConverter(ShortGenericConverter());
    registry.addPairedConverter(DoubledGenericConverter());
    registry.addPairedConverter(BooleanGenericConverter());
    registry.addPairedConverter(CharacterGenericConverter());
    
    // String/Character converters
    registry.addConverter(StringToRunesConverter());
    registry.addConverter(RunesToStringConverter());
    
    // Enum converters
    registry.addConverterFactory(StringToEnumConverterFactory());
    registry.addConverter(EnumToStringConverter());
    registry.addConverterFactory(IntToEnumConverterFactory());
    registry.addConverter(EnumToIntConverter());
    
    // Symbol converters
    registry.addConverter(StringToSymbolConverter());
    registry.addConverter(SymbolToStringConverter());
  }
}