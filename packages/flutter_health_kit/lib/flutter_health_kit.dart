import 'src/health_kit_api.g.dart';

export 'src/health_kit_api.g.dart';

class FlutterHealthKit {
  final NativeHealthKitApi _api = NativeHealthKitApi();

  Future<bool> requestPermissions() async {
    return _api.requestPermissions();
  }

  Future<List<HealthDataRecord>> readData(
    String type,
    DateTime from,
    DateTime to,
  ) async {
    return _api.readData(
      type,
      from.millisecondsSinceEpoch,
      to.millisecondsSinceEpoch,
    );
  }

  Future<List<HealthWorkoutRecord>> readWorkouts(
    DateTime from,
    DateTime to,
  ) async {
    return _api.readWorkouts(
      from.millisecondsSinceEpoch,
      to.millisecondsSinceEpoch,
    );
  }

  Future<List<HealthRouteLocation>> readRoute(String workoutUUID) async {
    return _api.readRoute(workoutUUID);
  }
}
