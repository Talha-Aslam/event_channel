import Flutter
import UIKit
import CoreMotion

@main
@objc class AppDelegate: FlutterAppDelegate {
    // Event Channel names (must match Dart side)
    private let BATTERY_CHANNEL = "samples.flutter.dev/battery"
    private let ACCELEROMETER_CHANNEL = "samples.flutter.dev/accelerometer"
    
    // Battery monitoring
    private var batteryEventSink: FlutterEventSink?
    private var batteryTimer: Timer?
    
    // Accelerometer monitoring
    private var accelerometerEventSink: FlutterEventSink?
    private let motionManager = CMMotionManager()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Setup Event Channels
        setupEventChannels()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupEventChannels() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }
        
        // Setup Battery Event Channel
        let batteryEventChannel = FlutterEventChannel(
            name: BATTERY_CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
        batteryEventChannel.setStreamHandler(BatteryStreamHandler(delegate: self))
        
        // Setup Accelerometer Event Channel
        let accelerometerEventChannel = FlutterEventChannel(
            name: ACCELEROMETER_CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
        accelerometerEventChannel.setStreamHandler(AccelerometerStreamHandler(delegate: self))
    }
    
    // MARK: - Battery Monitoring
    func startBatteryMonitoring(eventSink: @escaping FlutterEventSink) {
        self.batteryEventSink = eventSink
        
        // Enable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Send initial battery level
        sendBatteryLevel()
        
        // Start periodic updates (every 2 seconds for demo)
        batteryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.sendBatteryLevel()
        }
        
        // Listen for battery level changes
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.sendBatteryLevel()
        }
    }
    
    func stopBatteryMonitoring() {
        batteryTimer?.invalidate()
        batteryTimer = nil
        batteryEventSink = nil
        
        // Remove observers
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        // Disable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
    
    private func sendBatteryLevel() {
        let batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel >= 0 {
            let percentage = Int(batteryLevel * 100)
            batteryEventSink?("\(percentage)%")
        } else {
            batteryEventSink?("Unknown")
        }
    }
    
    // MARK: - Accelerometer Monitoring
    func startAccelerometerMonitoring(eventSink: @escaping FlutterEventSink) {
        self.accelerometerEventSink = eventSink
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1 // 10 Hz
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let error = error {
                    eventSink(FlutterError(code: "ACCELEROMETER_ERROR", 
                                         message: error.localizedDescription, 
                                         details: nil))
                    return
                }
                
                if let accelerometerData = data {
                    let x = accelerometerData.acceleration.x
                    let y = accelerometerData.acceleration.y
                    let z = accelerometerData.acceleration.z
                    
                    let dataString = String(format: "X: %.2f\nY: %.2f\nZ: %.2f", x, y, z)
                    eventSink(dataString)
                }
            }
        } else {
            eventSink(FlutterError(code: "NO_ACCELEROMETER", 
                                 message: "Accelerometer not available", 
                                 details: nil))
        }
    }
    
    func stopAccelerometerMonitoring() {
        motionManager.stopAccelerometerUpdates()
        accelerometerEventSink = nil
    }
}

// MARK: - Battery Stream Handler
class BatteryStreamHandler: NSObject, FlutterStreamHandler {
    weak var delegate: AppDelegate?
    
    init(delegate: AppDelegate) {
        self.delegate = delegate
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        delegate?.startBatteryMonitoring(eventSink: events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        delegate?.stopBatteryMonitoring()
        return nil
    }
}

// MARK: - Accelerometer Stream Handler
class AccelerometerStreamHandler: NSObject, FlutterStreamHandler {
    weak var delegate: AppDelegate?
    
    init(delegate: AppDelegate) {
        self.delegate = delegate
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        delegate?.startAccelerometerMonitoring(eventSink: events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        delegate?.stopAccelerometerMonitoring()
        return nil
    }
}
