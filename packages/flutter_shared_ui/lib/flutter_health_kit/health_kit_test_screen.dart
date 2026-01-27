import 'package:flutter/material.dart';
import 'package:flutter_health_kit/flutter_health_kit.dart';

class HealthKitTestScreen extends StatefulWidget {
  const HealthKitTestScreen({super.key});

  @override
  State<HealthKitTestScreen> createState() => _HealthKitTestScreenState();
}

class _HealthKitTestScreenState extends State<HealthKitTestScreen> {
  final _healthKit = FlutterHealthKit();
  List<HealthWorkoutRecord> _workouts = [];
  List<HealthDataRecord> _data = [];
  bool _showingWorkouts = true;
  String _selectedType = 'steps';

  static const _healthTypes = [
    'steps',
    'distance_walking_running',
    'distance_cycling',
    'distance_swimming',
    'flights_climbed',
    'active_energy',
    'basal_energy',
    'heart_rate',
    'oxygen_saturation',
    'blood_pressure_systolic',
    'body_temperature',
    'vo2_max',
    'running_speed',
    'running_power',
  ];
  bool _isLoading = false;
  String? _status;

  Future<void> _authorize() async {
    setState(() => _status = "Requesting permissions...");
    try {
      final authorized = await _healthKit.requestPermissions();
      setState(() => _status = authorized ? "Authorized" : "Denied");
    } catch (error) {
      setState(() => _status = "Error: $error");
    }
  }

  Future<void> _fetchWorkouts() async {
    setState(() {
      _isLoading = true;
      _showingWorkouts = true;
      _status = "Fetching workouts...";
    });

    try {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));

      final workouts = await _healthKit.readWorkouts(start, end);
      setState(() {
        _workouts = workouts;
        _status = "Found ${workouts.length} workouts";
      });
    } catch (e) {
      setState(() => _status = "Fetch Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _readData() async {
    setState(() {
      _isLoading = true;
      _showingWorkouts = false;
      _status = "Reading $_selectedType...";
    });

    try {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 7));

      final data = await _healthKit.readData(_selectedType, start, end);
      setState(() {
        _data = data;
        _status = "Found ${data.length} records for $_selectedType";
      });
    } catch (e) {
      setState(() => _status = "Read Data Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showRoute(String uuid) async {
    try {
      final route = await _healthKit.readRoute(uuid);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Route Data"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: route.length,
              itemBuilder: (context, index) {
                final point = route[index];
                return ListTile(
                  title: Text(
                    "Lat: ${point.latitude?.toStringAsFixed(5)}, Lng: ${point.longitude?.toStringAsFixed(5)}",
                  ),
                  subtitle: Text(
                    "Alt: ${point.altitude?.toStringAsFixed(1)}m, Speed: ${point.speed?.toStringAsFixed(1)} m/s",
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading route: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HealthKit Test")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_status != null) ...[
                  Text(
                    _status!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _authorize,
                      child: const Text("Authorize"),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _fetchWorkouts,
                      child: const Text("Load Workouts"),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Select ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: const <TextSpan>[
                          TextSpan(
                            text: 'Healthy Types ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: 'to see data for '),
                          TextSpan(
                            text: 'Read Data',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isDense: true,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: Colors.orange.shade100,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _healthTypes.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() {
                            if (value != null) _selectedType = value;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _readData,
                      child: const Text("Read Data"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showingWorkouts
                ? ListView.separated(
                    itemCount: _workouts.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final w = _workouts[index];
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        w.startTime ?? 0,
                      );

                      return ListTile(
                        leading: Icon(_getActivityIcon(w.activityType)),
                        title: Text(
                          "${w.activityType?.toUpperCase() ?? 'UNKNOWN'} - ${w.totalDistance?.toStringAsFixed(0)}m",
                        ),
                        subtitle: Text(
                          "$date\nDuration: ${(w.duration ?? 0) / 60} mins | ${w.totalEnergyBurned?.toStringAsFixed(0)} kcal",
                        ),
                        trailing: const Icon(Icons.map),
                        onTap: () {
                          if (w.uuid != null) _showRoute(w.uuid!);
                        },
                      );
                    },
                  )
                : ListView.separated(
                    itemCount: _data.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final d = _data[index];
                      final start = DateTime.fromMillisecondsSinceEpoch(
                        d.startTime ?? 0,
                      );
                      return ListTile(
                        title: Text(
                          "${d.type}: ${d.value?.toStringAsFixed(2)} ${d.unit}",
                        ),
                        subtitle: Text("$start"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'walking':
        return Icons.directions_walk;
      case 'swimming':
        return Icons.pool;
      default:
        return Icons.fitness_center;
    }
  }
}
