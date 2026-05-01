import 'package:flutter/material.dart';

class MathTestScreen extends StatefulWidget {
  const MathTestScreen({super.key});

  @override
  State<MathTestScreen> createState() => _MathTestScreenState();
}

class _MathTestScreenState extends State<MathTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Native Math")),
      body: Center(
        // child: Container(
        //   width: 200,
        //   height: 200,
        //   color: Colors.blue,
        //   child: Baseline(
        //     baseline: 100,
        //     baselineType: TextBaseline.alphabetic,
        //     child: Text(
        //       "Hello World",
        //       style: TextStyle(
        //         color: Colors.orange,
        //         fontSize: 16,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        // ),
        child: Container(
          height: 200,
          color: Colors.red,
          child: Baseline(
            baseline: 200,
            baselineType: TextBaseline.alphabetic,
            child: Text('Flutter', style: TextStyle(fontSize: 30)),
          ),
        ),
      ),
    );
  }
}
