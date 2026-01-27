import Flutter
import UIKit

public class FlutterMathPlugin: NSObject, FlutterPlugin, NativeMathApi {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let api = FlutterMathPlugin()
    // Đăng ký setup với code Pigeon đã gen
    NativeMathApiSetup.setUp(binaryMessenger: messenger, api: api)
  }

  // Implement logic toán học (Chạy dưới Native iOS)
  func add(a: Double, b: Double) -> Double { return a + b }

  func subtract(a: Double, b: Double) -> Double { return a - b }

  func multiply(a: Double, b: Double) -> Double { return a * b }

  func divide(a: Double, b: Double) throws -> Double {
      if b == 0 { return 0 }
      return a / b
  }
}