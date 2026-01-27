import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'flutter_health_kit',
    dartOut: 'lib/src/health_kit_api.g.dart',
    swiftOut: 'ios/Classes/HealthKitApi.g.swift',
  ),
)
class HealthDataRecord {
  String? type;
  double? value;
  String? unit;
  int? startTime;
  int? endTime;
}

class HealthWorkoutRecord {
  String? uuid;
  String? activityType; // "running", "cycling", "swimming", "walking", etc.
  int? startTime;
  int? endTime;
  double? duration;
  double? totalDistance;
  double? totalEnergyBurned;
  String? sourceName;
  String? sourceId;
  bool? isIndoor;
}

class HealthRouteLocation {
  double? latitude;
  double? longitude;
  double? altitude;
  double? speed;
  double? course;
  double? horizontalAccuracy;
  double? verticalAccuracy;
  int? timestamp;
}

@HostApi()
abstract class NativeHealthKitApi {
  @async
  bool requestPermissions();

  @async
  List<HealthDataRecord> readData(String type, int startTime, int endTime);

  @async
  List<HealthWorkoutRecord> readWorkouts(int startTime, int endTime);

  @async
  List<HealthRouteLocation> readRoute(String workoutUUID);
}
