import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'flutter_math',
    dartOut: 'lib/src/math_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/src/main/kotlin/com/example/flutter_math/MathApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.flutter_math'),
    swiftOut: 'ios/Classes/MathApi.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
@HostApi()
abstract class NativeMathApi {
  double add(double a, double b);
  double subtract(double a, double b);
  double multiply(double a, double b);
  double divide(double a, double b);
}
