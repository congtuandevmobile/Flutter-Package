library;

import 'package:flutter/material.dart';
import 'package:flutter_shared_ui/flutter_health_kit/health_kit_test_screen.dart';
import 'package:flutter_shared_ui/flutter_math/flutter_math_test_screen.dart';
import 'package:flutter_shared_ui/widgets/menu_button.dart';

class SharedScreen extends StatelessWidget {
  const SharedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared UI')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          MenuButton(
            title: "Test Flutter Math",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MathTestScreen()),
              );
            },
          ),
          MenuButton(
            title: "Test Flutter Healkit",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthKitTestScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
