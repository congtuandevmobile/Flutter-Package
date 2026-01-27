import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_math_method_channel.dart';

abstract class FlutterMathPlatform extends PlatformInterface {
  /// Constructs a FlutterMathPlatform.
  FlutterMathPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMathPlatform _instance = MethodChannelFlutterMath();

  /// The default instance of [FlutterMathPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMath].
  static FlutterMathPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMathPlatform] when
  /// they register themselves.
  static set instance(FlutterMathPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
