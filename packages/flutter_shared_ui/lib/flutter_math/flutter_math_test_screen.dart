import 'package:flutter/material.dart';
import 'package:flutter_math/flutter_math.dart'; 

class MathTestScreen extends StatefulWidget {
  const MathTestScreen({super.key});

  @override
  State<MathTestScreen> createState() => _MathTestScreenState();
}

class _MathTestScreenState extends State<MathTestScreen> {
  final _api = NativeMathApi();

  String _result = "Kết quả hiện ở đây";

  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  Future<void> _calculate(String operation) async {
    double? n1 = double.tryParse(_num1Controller.text);
    double? n2 = double.tryParse(_num2Controller.text);

    if (n1 == null || n2 == null) {
      setState(() {
        _result = "Vui lòng nhập số hợp lệ!";
      });
      return;
    }

    double res = 0;
    try {
      switch (operation) {
        case '+':
          res = await _api.add(n1, n2);
          break;
        case '-':
          res = await _api.subtract(n1, n2);
          break;
        case '*':
          res = await _api.multiply(n1, n2);
          break;
        case '/':
          res = await _api.divide(n1, n2);
          break;
      }
      setState(() {
        _result = "$n1 $operation $n2 = $res";
      });
    } catch (e) {
      setState(() => _result = "Lỗi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Native Math")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _num1Controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Nhập số thứ nhất (A)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _num2Controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Nhập số thứ hai (B)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _result,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => _calculate('+'),
                  child: const Text("Cộng (+)"),
                ),
                ElevatedButton(
                  onPressed: () => _calculate('-'),
                  child: const Text("Trừ (-)"),
                ),
                ElevatedButton(
                  onPressed: () => _calculate('*'),
                  child: const Text("Nhân (x)"),
                ),
                ElevatedButton(
                  onPressed: () => _calculate('/'),
                  child: const Text("Chia (/)"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
