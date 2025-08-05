# BatteryLevel and Accelerometer using Event Channel

A comprehensive Flutter project demonstrating real-time communication between Flutter/Dart and native Android platforms using Event Channels.

## 🚀 Project Overview

This project showcases how to implement **Event Channels** in Flutter to stream real-time data from native Android code to Dart. Unlike Method Channels which handle request-response patterns, Event Channels enable continuous data streaming for real-time updates.

## 📱 Features

- **Battery Level Monitoring**: Real-time battery percentage updates
- **Accelerometer Data Streaming**: Live sensor data (X, Y, Z coordinates)
- **System Event Integration**: Native Android broadcast receivers
- **Proper Resource Management**: Stream lifecycle management with cleanup
- **Error Handling**: Graceful error handling for platform communication

## 🏗️ Architecture

```
┌─────────────────┐    Event Channels    ┌──────────────────┐
│   Flutter/Dart  │ ←─────────────────── │  Native Android  │
│                 │                      │                  │
│ • UI Updates    │                      │ • Sensor APIs    │
│ • Stream Listen │                      │ • Battery Manager│
│ • State Mgmt    │                      │ • Broadcast Recv │
└─────────────────┘                      └──────────────────┘
```

## 🔧 Technical Implementation

### Event Channels Used

1. **Battery Channel**: `samples.flutter.dev/battery`
   - Streams battery percentage updates
   - Uses Android BroadcastReceiver for system events

2. **Accelerometer Channel**: `samples.flutter.dev/accelerometer`
   - Streams real-time sensor data
   - Uses Android SensorManager for hardware access

### Key Components

#### Dart Side (`lib/main.dart`)
- Event Channel instances
- Stream subscriptions management
- Real-time UI updates
- Proper cleanup in dispose()

#### Android Side (`android/.../MainActivity.kt`)
- Event Channel stream handlers
- Battery broadcast receiver
- Accelerometer sensor listener
- Thread-safe data transmission

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## 🛠️ Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd event_channel
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Android Setup
No additional setup required - permissions are already configured in `AndroidManifest.xml`:
```xml
<!-- Automatically granted permissions -->
<uses-permission android:name="android.permission.BATTERY_STATS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 4. Run the Project
```bash
flutter run
```

## 📱 How to Use

1. **Launch the App**: The app automatically starts listening to both event channels
2. **Battery Updates**: Real-time battery percentage is displayed and updated
3. **Accelerometer Data**: Move your device to see live sensor readings
4. **Start/Stop**: Use the control buttons to manage stream subscriptions

## 🔄 Data Flow

### Battery Monitoring
```
Android Battery Change → BroadcastReceiver → EventSink → Flutter Stream → UI Update
```

### Accelerometer Monitoring
```
Device Movement → SensorManager → SensorEventListener → EventSink → Flutter Stream → UI Update
```

## 📝 Code Structure

```
lib/
├── main.dart                 # Main app with Event Channel implementation
└── ...

android/
└── app/src/main/kotlin/
    └── MainActivity.kt       # Native Android Event Channel handlers
```

## 🎯 Key Learning Points

1. **Event Channels vs Method Channels**
   - Event Channels: Continuous streaming (native → Dart)
   - Method Channels: Request-response pattern

2. **Stream Management**
   - Proper subscription lifecycle
   - Memory leak prevention
   - Resource cleanup

3. **Native Integration**
   - Android system APIs integration
   - Thread-safe communication
   - Real-time data streaming

4. **Error Handling**
   - Platform-specific error management
   - Graceful degradation

## 🐛 Troubleshooting

### Common Issues

1. **Stream Not Receiving Data**
   - Check channel names match exactly on both sides
   - Verify EventSink is not null
   - Ensure proper thread usage (main thread for Flutter communication)

2. **Memory Leaks**
   - Always cancel subscriptions in dispose()
   - Set EventSink to null when not needed

3. **Sensor Not Working**
   - Test on physical device (emulator may not have sensors)
   - Check sensor availability before registering listeners

## 🚀 Extension Ideas

- Add GPS location streaming
- Implement network connectivity monitoring
- Add device orientation tracking
- Create custom sensor data processing
- Implement data persistence for sensor readings

## 📚 Resources

- [Flutter Platform Channels Documentation](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Android BroadcastReceiver Guide](https://developer.android.com/guide/components/broadcasts)
- [Android Sensor Framework](https://developer.android.com/guide/topics/sensors/sensors_overview)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎓 Educational Purpose

This project is designed for learning Event Channels in Flutter. It demonstrates:
- Real-time native-to-Flutter communication
- Proper resource management
- Android system integration
- Stream-based architecture patterns

---

**Happy Coding! 🎉**

Built with ❤️ using Flutter and Kotlin