library flutter_math;

export 'src/math_api.g.dart';

import 'flutter_math_platform_interface.dart';

class FlutterMath {
  Future<String?> getPlatformVersion() {
    return FlutterMathPlatform.instance.getPlatformVersion();
  }
}
