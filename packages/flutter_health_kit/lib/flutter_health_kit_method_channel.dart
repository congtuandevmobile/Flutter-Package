import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_health_kit_platform_interface.dart';

/// An implementation of [FlutterHealthKitPlatform] that uses method channels.
class MethodChannelFlutterHealthKit extends FlutterHealthKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_health_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
