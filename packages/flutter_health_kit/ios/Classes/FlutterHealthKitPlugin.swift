import Flutter
import UIKit

public class FlutterHealthKitPlugin: NSObject, FlutterPlugin, NativeHealthKitApi {
  private let permissionMgr = HealthPermissionMgr()
  private let reader = HealthReader()
  private let workoutReader = WorkoutReader()
  private let routeReader = RouteReader()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let api = FlutterHealthKitPlugin()
    NativeHealthKitApiSetup.setUp(binaryMessenger: messenger, api: api)
  }

  func requestPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    permissionMgr.requestPermissions(completion: completion)
  }

  func readData(
    type: String, startTime: Int64, endTime: Int64,
    completion: @escaping (Result<[HealthDataRecord], Error>) -> Void
  ) {
    reader.readData(typeKey: type, startTime: startTime, endTime: endTime, completion: completion)
  }

  func readWorkouts(startTime: Int64, endTime: Int64, completion: @escaping (Result<[HealthWorkoutRecord], Error>) -> Void) {
      workoutReader.readRunningWorkouts(startTime: startTime, endTime: endTime, completion: completion)
  }

  func readRoute(workoutUUID: String, completion: @escaping (Result<[HealthRouteLocation], Error>) -> Void) {
      routeReader.getRouteLocations(from: workoutUUID, completion: completion)
  }
}
