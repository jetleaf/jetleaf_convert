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

import '../conversion_service/conversion_service.dart';
import 'generic_conversion_service.dart';
import '../converter/converter_registry.dart';

import '../types/map_converter.dart';
import '../types/time_converter.dart';
import '../types/jl_converter.dart';
import '../types/collection_converter.dart';
import '../types/object_converter.dart';
import '../types/dart_converter.dart';

/// A specialization of [GenericConversionService] configured by default
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
class DefaultConversionService extends GenericConversionService {
  static DefaultConversionService? _sharedInstance;
  
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
  static void addDefaultConverters(ConverterRegistry converterRegistry) {
    addScalarConverters(converterRegistry);
    addCollectionConverters(converterRegistry);
    addTimeConverters(converterRegistry);
    addMapConverters(converterRegistry);
    addOptionalConverters(converterRegistry);
    addJetLeafConverters(converterRegistry);
    addOtherDartConverters(converterRegistry);
    
    // Core object converters
    converterRegistry.addGenericConverter(ObjectToObjectConverter());
    converterRegistry.addGenericConverter(FallbackObjectToStringConverter());
  }
  
  /// Add time-related converters.
  static void addTimeConverters(ConverterRegistry converterRegistry) {
    // String to time object converters
    converterRegistry.addConverter(StringToDateTimeConverter());
    converterRegistry.addConverter(StringToLocalDateTimeConverter());
    converterRegistry.addConverter(StringToLocalDateConverter());
    converterRegistry.addConverter(StringToLocalTimeConverter());
    converterRegistry.addConverter(StringToZoneIdConverter());
    converterRegistry.addConverter(StringToZonedDateTimeConverter());
    converterRegistry.addConverter(StringToDurationConverter());
    
    // Time object to string converters
    converterRegistry.addConverter(DateTimeToStringConverter());
    converterRegistry.addConverter(LocalDateTimeToStringConverter());
    converterRegistry.addConverter(LocalDateToStringConverter());
    converterRegistry.addConverter(LocalTimeToStringConverter());
    converterRegistry.addConverter(ZoneIdToStringConverter());
    converterRegistry.addConverter(ZonedDateTimeToStringConverter());
    converterRegistry.addConverter(DurationToStringConverter());
    
    // DateTime cross-conversions
    converterRegistry.addConverter(DateTimeToLocalDateTimeConverter());
    converterRegistry.addConverter(LocalDateTimeToDateTimeConverter());
    converterRegistry.addConverter(DateTimeToLocalDateConverter());
    converterRegistry.addConverter(LocalDateToDateTimeConverter());
    converterRegistry.addConverter(DateTimeToLocalTimeConverter());
    converterRegistry.addConverter(DateTimeToZonedDateTimeConverter());
    converterRegistry.addConverter(ZonedDateTimeToDateTimeConverter());
    
    // Epoch milliseconds converters
    converterRegistry.addConverter(IntToDateTimeConverter());
    converterRegistry.addConverter(DateTimeToIntConverter());
    converterRegistry.addConverter(IntToZonedDateTimeConverter());
    converterRegistry.addConverter(ZonedDateTimeToIntConverter());
    converterRegistry.addConverter(IntToDurationConverter());
    converterRegistry.addConverter(DurationToIntConverter());
    
    // Cross-type converters
    converterRegistry.addConverter(LocalDateTimeToLocalDateConverter());
    converterRegistry.addConverter(LocalDateTimeToLocalTimeConverter());
    converterRegistry.addConverter(LocalDateAndLocalTimeToLocalDateTimeConverter());
    converterRegistry.addConverter(LocalDateTimeToZonedDateTimeConverter(ZoneId.UTC));
    converterRegistry.addConverter(ZonedDateTimeToLocalDateTimeConverter());
    converterRegistry.addConverter(ZonedDateTimeToLocalDateConverter());
    converterRegistry.addConverter(ZonedDateTimeToLocalTimeConverter());
    converterRegistry.addConverter(ZonedDateTimeToZoneIdConverter());
    
    // List converters
    converterRegistry.addConverter(ListStringToListDateTimeConverter());
    converterRegistry.addConverter(ListDateTimeToListStringConverter());
    converterRegistry.addConverter(ListStringToListLocalDateTimeConverter());
    converterRegistry.addConverter(ListLocalDateTimeToListStringConverter());
    converterRegistry.addConverter(ListStringToListZoneIdConverter());
    converterRegistry.addConverter(ListZoneIdToListStringConverter());
  }
  
  /// Add map-related converters.
  static void addMapConverters(ConverterRegistry converterRegistry) {
    final conversionService = converterRegistry as ConversionService;
    
    converterRegistry.addGenericConverter(StringToMapGenericConverter(conversionService));
    converterRegistry.addGenericConverter(MapToStringGenericConverter(conversionService));
    converterRegistry.addGenericConverter(MapToMapGenericConverter(conversionService));
  }
  
  /// Add optional-related converters.
  static void addOptionalConverters(ConverterRegistry converterRegistry) {
    final conversionService = converterRegistry as ConversionService;
    
    converterRegistry.addGenericConverter(ObjectToOptionalConverter(conversionService));
    converterRegistry.addGenericConverter(OptionalToObjectConverter(conversionService));
  }
  
  /// Add JetLeaf-specific converters.
  static void addJetLeafConverters(ConverterRegistry converterRegistry) {
    final conversionService = converterRegistry as ConversionService;
    
    converterRegistry.addGenericConverter(StreamConverter(conversionService));
    converterRegistry.addConverter(StringToUuidConverter());
    converterRegistry.addConverter(UuidToStringConverter());
    converterRegistry.addConverter(StringToCurrencyConverter());
    converterRegistry.addConverter(CurrencyToStringConverter());
    converterRegistry.addConverter(StringToLocaleConverter());
    converterRegistry.addConverter(LocaleToStringConverter());
    converterRegistry.addGenericConverter(ByteMultiConverter());
  }
  
  /// Add other Dart built-in type converters.
  static void addOtherDartConverters(ConverterRegistry converterRegistry) {
    final conversionService = converterRegistry as ConversionService;
    
    // Runes converters
    converterRegistry.addConverter(StringToRunesConverter());
    converterRegistry.addConverter(RunesToStringConverter());
    
    // Symbol converters
    converterRegistry.addConverter(StringToSymbolConverter());
    converterRegistry.addConverter(SymbolToStringConverter());
    
    // URI converters
    converterRegistry.addConverter(StringToUriConverter(conversionService.getUriValidators()));
    converterRegistry.addConverter(UriToStringConverter());
    
    // RegExp converters
    converterRegistry.addConverter(StringToRegExpConverter());
    converterRegistry.addConverter(RegExpToStringConverter());
    converterRegistry.addConverter(StringToPatternConverter());
    converterRegistry.addConverter(PatternToStringConverter());
    
    // Stream converters
    converterRegistry.addGenericConverter(DartStreamConverter(conversionService));
  }

  /// Add common collection converters.
  static void addCollectionConverters(ConverterRegistry converterRegistry) {
    final conversionService = converterRegistry as ConversionService;
    
    converterRegistry.addGenericConverter(StringGenericConverter());
    converterRegistry.addGenericConverter(DoubleGenericConverter());
    converterRegistry.addGenericConverter(IntGenericConverter());

    converterRegistry.addGenericConverter(ListToCollectionConverter(conversionService));
    converterRegistry.addGenericConverter(SetToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(QueueToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(IterableToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(ArrayListToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(SetBaseToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(ListBaseToCollectionConverter(conversionService));
    converterRegistry.addGenericConverter(LinkedQueueToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(LinkedListToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(LinkedHashSetToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(HashSetToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(StackToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(LinkedStackToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(StringToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(CollectionToStringGenericConverter(conversionService));
    converterRegistry.addGenericConverter(IntToCollectionGenericConverter(conversionService));
    converterRegistry.addGenericConverter(CollectionToIntGenericConverter(conversionService));
    
    // Object converters
    converterRegistry.addGenericConverter(ObjectToListConverter(conversionService));
    converterRegistry.addGenericConverter(ObjectToSetConverter(conversionService));
    converterRegistry.addGenericConverter(ListToObjectConverter(conversionService));
    converterRegistry.addGenericConverter(SetToObjectConverter(conversionService));
  }
  
  static void addScalarConverters(ConverterRegistry converterRegistry) {
    converterRegistry.addGenericConverter(NumberGenericConverter());
    converterRegistry.addGenericConverter(BoolGenericConverter());
    converterRegistry.addGenericConverter(BigIntGenericConverter());
    converterRegistry.addGenericConverter(IntegerGenericConverter());
    converterRegistry.addGenericConverter(LongGenericConverter());
    converterRegistry.addGenericConverter(FloatGenericConverter());
    converterRegistry.addGenericConverter(BigIntegerGenericConverter());
    converterRegistry.addGenericConverter(BigDecimalGenericConverter());
    converterRegistry.addGenericConverter(ShortGenericConverter());
    converterRegistry.addGenericConverter(DoubledGenericConverter());
    converterRegistry.addGenericConverter(BooleanGenericConverter());
    converterRegistry.addGenericConverter(CharacterGenericConverter());
    
    // String/Character converters
    converterRegistry.addConverter(StringToRunesConverter());
    converterRegistry.addConverter(RunesToStringConverter());
    
    // Enum converters
    converterRegistry.addConverterFactory(StringToEnumConverterFactory());
    converterRegistry.addConverter(EnumToStringConverter());
    converterRegistry.addConverterFactory(IntToEnumConverterFactory());
    converterRegistry.addConverter(EnumToIntConverter());
    
    // Symbol converters
    converterRegistry.addConverter(StringToSymbolConverter());
    converterRegistry.addConverter(SymbolToStringConverter());
  }
}