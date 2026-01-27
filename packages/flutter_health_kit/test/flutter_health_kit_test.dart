import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_health_kit/flutter_health_kit.dart';
import 'package:flutter_health_kit/flutter_health_kit_platform_interface.dart';
import 'package:flutter_health_kit/flutter_health_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterHealthKitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterHealthKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterHealthKitPlatform initialPlatform = FlutterHealthKitPlatform.instance;

  test('$MethodChannelFlutterHealthKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterHealthKit>());
  });

  test('getPlatformVersion', () async {
    FlutterHealthKit flutterHealthKitPlugin = FlutterHealthKit();
    MockFlutterHealthKitPlatform fakePlatform = MockFlutterHealthKitPlatform();
    FlutterHealthKitPlatform.instance = fakePlatform;

    expect(await flutterHealthKitPlugin.getPlatformVersion(), '42');
  });
}
