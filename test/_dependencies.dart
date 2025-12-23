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

import 'dart:io';

import 'package:jetleaf_convert/convert.dart';
import 'package:jetleaf_lang/jetleaf_lang.dart';

ConfigurableConversionService getConversionService() => DefaultConversionService();

Future<void> setupRuntime({List<String> packagesToExclude = const [], List<String> filesToLoad = const []}) async {
  await MockRuntimeScanner(
    onInfo: (msg, updated) => print('[MOCK INFO] $msg'),
    onWarning: (msg, updated) => print('[MOCK WARNING] $msg'),
    onError: (msg, updated) => print('[MOCK ERROR] $msg'),
    forceLoadFiles: filesToLoad.map((file) => File(file).absolute).toList(),
    libraryGeneratorFactory: (params) => InternalMockLibraryGenerator(
      mirrorSystem: params.mirrorSystem,
      forceLoadedMirrors: params.forceLoadedMirrors,
      configuration: params.configuration,
      packages: params.packages
    )
  ).scan(RuntimeScannerConfiguration(
    skipTests: true,
    packagesToExclude: [
      "test",
      "lints",
      "args",
      "path",
      "source_span",
      "stack_trace",
      "stream_channel",
      "pool",
      "test_api",
      "test_core",
      "boolean_selector",
      "term_glyph",
      "string_scanner",
      "package:collection/src/list_extensions.dart",
      ...packagesToExclude
    ]
  ), []);
}