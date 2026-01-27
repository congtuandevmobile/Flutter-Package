import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_math_platform_interface.dart';

/// An implementation of [FlutterMathPlatform] that uses method channels.
class MethodChannelFlutterMath extends FlutterMathPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_math');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
