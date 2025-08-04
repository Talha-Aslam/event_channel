import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Channel Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EventChannelDemo(),
    );
  }
}

class EventChannelDemo extends StatefulWidget {
  const EventChannelDemo({super.key});

  @override
  State<EventChannelDemo> createState() => _EventChannelDemoState();
}

class _EventChannelDemoState extends State<EventChannelDemo> {
  // 1. Create Event Channel instance
  static const EventChannel _batteryChannel =
      EventChannel('samples.flutter.dev/battery');
  static const EventChannel _accelerometerChannel =
      EventChannel('samples.flutter.dev/accelerometer');

  // State variables to hold streaming data
  String _batteryLevel = 'Unknown';
  String _accelerometerData = 'No data';
  bool _isListening = false;

  // Stream subscriptions
  StreamSubscription<dynamic>? _batterySubscription;
  StreamSubscription<dynamic>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  // 2. Start listening to event streams
  void _startListening() {
    setState(() {
      _isListening = true;
    });

    // Battery level stream
    _batterySubscription = _batteryChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        setState(() {
          _batteryLevel = event.toString();
        });
      },
      onError: (dynamic error) {
        setState(() {
          _batteryLevel = 'Error: ${error.message}';
        });
      },
    );

    // Accelerometer stream
    _accelerometerSubscription =
        _accelerometerChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        setState(() {
          _accelerometerData = event.toString();
        });
      },
      onError: (dynamic error) {
        setState(() {
          _accelerometerData = 'Error: ${error.message}';
        });
      },
    );
  }

  // 3. Stop listening to streams
  void _stopListening() {
    _batterySubscription?.cancel();
    _accelerometerSubscription?.cancel();
    setState(() {
      _isListening = false;
      _batteryLevel = 'Stopped';
      _accelerometerData = 'Stopped';
    });
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Channel Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isListening ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isListening ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isListening
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _isListening ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isListening ? 'Listening to Events' : 'Not Listening',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isListening ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Battery Level Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.battery_std,
                        size: 48, color: Colors.green),
                    const SizedBox(height: 8),
                    const Text('Battery Level',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _batteryLevel,
                      style: const TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Accelerometer Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.sensors, size: 48, color: Colors.orange),
                    const SizedBox(height: 8),
                    const Text('Accelerometer',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _accelerometerData,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.purple),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isListening ? null : _startListening,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isListening ? _stopListening : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
