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

import '../exceptions.dart';
import '../core/conversion_service.dart';
import '../helpers/_commons.dart';
import '../helpers/convertible_pair.dart';

/// {@template object_to_list_converter}
/// A [Converter] that converts an [Object] to a [List].
///
/// Example:
/// ```dart
/// final converter = ObjectToListConverter();
/// print(converter.convert('1, 2, 3')); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class ObjectToListConverter extends CommonPairedConditionalConverter {
  final ConversionService _conversionService;

  ObjectToListConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {
    ConvertiblePair(Class<Object>(null, PackageNames.DART), Class<List>(null, PackageNames.DART))
  };

  @override
  bool matches(Class sourceType, Class targetType) => !sourceType.isArray() && targetType.isArray();

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final targetElementType = targetType.componentType();

    if (targetElementType != null && targetElementType.isInstance(source)) {
      return [source];
    }

    if (targetElementType != null) {
      final convertedElement = _conversionService.convertTo(source, sourceType, targetElementType);
      return [convertedElement];
    }

    return [source];
  }
}

/// {@template object_to_set_converter}
/// A [Converter] that converts an [Object] to a [Set].
///
/// Example:
/// ```dart
/// final converter = ObjectToSetConverter();
/// print(converter.convert('1, 2, 3')); // prints: {1, 2, 3}
/// ```
/// {@endtemplate}
class ObjectToSetConverter extends CommonPairedConditionalConverter {
  final ConversionService _conversionService;

  ObjectToSetConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {
    ConvertiblePair(Class<Object>(null, PackageNames.DART), Class<Set>(null, PackageNames.DART))
  };

  @override
  bool matches(Class sourceType, Class targetType) => !sourceType.isArray() && targetType.isAssignableTo(Class<Set>());

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final targetElementType = targetType.componentType();
    if (targetElementType != null) {
      final convertedElement = _conversionService.convertTo(source, sourceType, targetElementType);
      return {convertedElement};
    }

    return {source};
  }
}

/// {@template list_to_object_converter}
/// A [Converter] that converts a [List] to an [Object] (extracts single element).
///
/// Example:
/// ```dart
/// final converter = ListToObjectConverter();
/// print(converter.convert([1, 2, 3])); // prints: 1
/// ```
/// {@endtemplate}
class ListToObjectConverter extends CommonPairedConditionalConverter {
  final ConversionService _conversionService;

  ListToObjectConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {
    ConvertiblePair(Class<List>(null, PackageNames.DART), Class<Object>(null, PackageNames.DART))
  };

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.isArray() && !targetType.isArray();

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final sourceList = source as List;
    final component = sourceType.componentType();
    if (component == null) {
      throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source);
    }

    if (sourceList.isEmpty) return null;
    if (sourceList.length == 1) {
      return _conversionService.convertTo(sourceList.first, targetType, component);
    }

    if(targetType.getType() == String) {
      return sourceList.map((element) => _conversionService.convertTo<String>(element, component, targetType)).join(",");
    }

    // Check int and add all items in the list
    if(component.getType() == int) {
      return sourceList.map((element) => _conversionService.convertTo<int>(element, component, targetType)).reduce((a, b) => (a as int) + (b as int));
    }

    throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source);
  }
}

/// {@template set_to_object_converter}
/// A [Converter] that converts a [Set] to an [Object] (extracts single element).
///
/// Example:
/// ```dart
/// final converter = SetToObjectConverter();
/// print(converter.convert({1, 2, 3})); // prints: 1
/// ```
/// {@endtemplate}
class SetToObjectConverter extends CommonPairedConditionalConverter {
  final ConversionService _conversionService;

  SetToObjectConverter(this._conversionService);

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {
    ConvertiblePair(Class<Set>(null, PackageNames.DART), Class<Object>(null, PackageNames.DART))
  };

  @override
  bool matches(Class sourceType, Class targetType) => sourceType.isAssignableTo(Class<Set>()) && !targetType.isArray();

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    final sourceSet = source as Set;
    if (sourceSet.isEmpty) return null;
    if (sourceSet.length == 1) {
      return _conversionService.convertTo(sourceSet.first, targetType, sourceType.componentType());
    }

    throw ConversionFailedException(sourceType: sourceType, targetType: targetType, value: source);
  }
}

// Fallback Converters

/// {@template fallback_object_to_string_converter}
/// A [Converter] that converts any object to string using toString().
///
/// Example:
/// ```dart
/// final converter = FallbackObjectToStringConverter();
/// print(converter.convert('1, 2, 3')); // prints: '1, 2, 3'
/// ```
/// {@endtemplate}
class FallbackObjectToStringConverter extends CommonPairedConditionalConverter {
  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {
    ConvertiblePair(Class<Object>(null, PackageNames.DART), Class<String>(null, PackageNames.DART))
  };

  @override
  bool matches(Class sourceType, Class targetType) => targetType.getType() == String;

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) => source?.toString();
}

/// {@template object_to_object_converter}
/// A [Converter] that converts an [Object] to another [Object] using reflection.
///
/// Example:
/// ```dart
/// final converter = ObjectToObjectConverter();
/// print(converter.convert('1, 2, 3')); // prints: [1, 2, 3]
/// ```
/// {@endtemplate}
class ObjectToObjectConverter extends CommonPairedConditionalConverter {
  /// Cache for the latest to-method, static factory method, or factory constructor resolved on a given Class
  static final Map<Class, Executable> conversionExecutableCache = {};

  @override
  Set<ConvertiblePair>? getConvertibleTypes() => {
    ConvertiblePair(Class<Object>(null, PackageNames.DART), Class<Object>(null, PackageNames.DART))
  };

  @override
  bool matches(Class sourceType, Class targetType) {
    return sourceType.getType() != targetType.getType() && hasConversionMethodOrConstructor(targetType, sourceType);
  }

  bool hasConversionMethodOrConstructor(Class targetClass, Class sourceClass) {
		return (getValidatedExecutable(targetClass, sourceClass) != null);
	}

  Executable? getValidatedExecutable(Class targetClass, Class sourceClass) {
    Executable? executable = conversionExecutableCache.get(targetClass);
		if (executable != null && isApplicable(executable, sourceClass)) {
			return executable;
		}

    executable = determineToMethod(targetClass, sourceClass);
		if (executable == null) {
			executable = determineFactoryMethod(targetClass, sourceClass);
			if (executable == null) {
				executable = determineFactoryConstructor(targetClass, sourceClass);
				if (executable == null) {
					return null;
				}
			}
		}

		conversionExecutableCache.put(targetClass, executable);
		return executable;
  }

  bool isApplicable(Executable executable, Class sourceClass) {
    if(executable is Method) {
      if(executable.isStatic()) {
        return ClassUtils.isAssignable(executable.getDeclaringClass(), sourceClass);
      } else {
        return executable.getParameterTypes().elementAt(0).getType() == sourceClass.getType();
      }
    } else if(executable is Constructor) {
      return executable.getParameterTypes().elementAt(0).getType() == sourceClass.getType();
    }

    return false;
  }

  Method? determineToMethod(Class targetClass, Class sourceClass) {
    if(Class<String>().getType() == targetClass.getType() || Class<String>().getType() == sourceClass.getType()) {
      // Do not accept a toString() method or any to methods on String itself
			return null;
    }

    Method? method = ClassUtils.getMethodIfAvailable(sourceClass, "to${targetClass.getSimpleName()}");
		return (method != null && !method.isStatic() && ClassUtils.isAssignable(targetClass, method.getReturnClass()) ? method : null);
  }

  Method? determineFactoryMethod(Class targetClass, Class sourceClass) {
    if(Class<String>().getType() == targetClass.getType()) {
      // Do not accept the String.valueOf(Object) method
			return null;
    }

    Method? method = ClassUtils.getStaticMethod(targetClass, "valueOf");
		if (method == null) {
			method = ClassUtils.getStaticMethod(targetClass, "of");
			method ??= ClassUtils.getStaticMethod(targetClass, "from");
		}

		return (method != null && areRelatedTypes(targetClass, method.getReturnClass()) ? method : null);
  }

  bool areRelatedTypes(Class type1, Class type2) {
		return (ClassUtils.isAssignable(type1, type2) || ClassUtils.isAssignable(type2, type1));
	}

  Constructor? determineFactoryConstructor(Class targetClass, Class sourceClass) {
    return targetClass.getConstructorBySignature([sourceClass]);
  }

  @override
  Object? convert<T>(Object? source, Class sourceType, Class targetType) {
    if (source == null) return null;

    if(source == targetType.getType() || targetType.isInstance(source)) {
      return source;
    }

    Executable? executable = getValidatedExecutable(targetType, sourceType);

    if(executable != null) {
      try {
        if(executable is Method) {
          if(!executable.isStatic()) {
            return executable.invoke(source);
          } else {
            return executable.invoke(null, source as Map<String, dynamic>?);
          }
        } else if(executable is Constructor) {
          return executable.newInstance(source as Map<String, dynamic>?);
        }
      } on Throwable catch(e) {
        throw ConversionFailedException(targetType: targetType, sourceType: sourceType, value: source, point: e.getCause());
      } catch (e) {
        throw ConversionFailedException(targetType: targetType, sourceType: sourceType, value: source, point: e);
      }
    }

    throw IllegalStateException("No constructive method ${sourceType.getName()} exists on ${targetType.getName()}");
  }
}