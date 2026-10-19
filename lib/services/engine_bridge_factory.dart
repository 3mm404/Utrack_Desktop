import 'package:flutter/foundation.dart';
import 'demo_engine_bridge.dart';
import 'engine_bridge.dart';
import 'platform_engine_bridge.dart'
    if (dart.library.io) 'platform_engine_bridge_io.dart'
    as platform;

const isTestMode = kIsWeb || bool.fromEnvironment('UTRACK_TEST');
EngineBridge createEngineBridge() =>
    isTestMode ? DemoEngineBridge() : platform.createPlatformBridge();
