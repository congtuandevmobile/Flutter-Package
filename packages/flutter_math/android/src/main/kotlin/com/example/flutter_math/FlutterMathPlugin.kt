package com.example.flutter_math

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterMathPlugin */
class FlutterMathPlugin :
    FlutterPlugin,
    MethodCallHandler, 
    NativeMathApi
    {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_math")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun add(a: Double, b: Double): Double = a + b
  
    override fun subtract(a: Double, b: Double): Double = a - b
  
    override fun multiply(a: Double, b: Double): Double = a * b
  
    override fun divide(a: Double, b: Double): Double {
      if (b == 0.0) return 0.0
      return a / b
  }
}
