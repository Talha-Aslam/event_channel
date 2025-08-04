package com.example.event_channel

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import java.util.*

class MainActivity: FlutterActivity() {
    // Event Channel names (must match Dart side)
    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"
    private val ACCELEROMETER_CHANNEL = "samples.flutter.dev/accelerometer"
    
    // Battery monitoring
    private var batteryEventSink: EventChannel.EventSink? = null
    private var batteryReceiver: BroadcastReceiver? = null
    
    // Accelerometer monitoring
    private var accelerometerEventSink: EventChannel.EventSink? = null
    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var sensorListener: SensorEventListener? = null

    //Flutter Engine Configuration (Birdge is established here)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup Battery Event Channel
        setupBatteryEventChannel(flutterEngine)
        
        // Setup Accelerometer Event Channel
        setupAccelerometerEventChannel(flutterEngine)
    }

    private fun setupBatteryEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    batteryEventSink = events
                    startBatteryMonitoring()
                }

                override fun onCancel(arguments: Any?) {
                    stopBatteryMonitoring()
                    batteryEventSink = null
                }
            }
        )
    }

    private fun setupAccelerometerEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, ACCELEROMETER_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    accelerometerEventSink = events
                    startAccelerometerMonitoring()
                }

                override fun onCancel(arguments: Any?) {
                    stopAccelerometerMonitoring()
                    accelerometerEventSink = null
                }
            }
        )
    }

    private fun startBatteryMonitoring() {
        // Create broadcast receiver for battery changes
        batteryReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_BATTERY_CHANGED) {
                    val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                    val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                    val batteryPct = level * 100 / scale.toFloat()
                    
                    // Send battery level to Flutter
                    Handler(Looper.getMainLooper()).post {
                        batteryEventSink?.success("${batteryPct.toInt()}%")
                    }
                }
            }
        }
        
        // Register receiver
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        registerReceiver(batteryReceiver, filter)
        
        // Send initial battery level
        sendInitialBatteryLevel()
        
        // Start periodic battery updates (every 2 seconds for demo)
        startPeriodicBatteryUpdates()
    }

    private fun sendInitialBatteryLevel() {
        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        batteryIntent?.let {
            val level = it.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = it.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            val batteryPct = level * 100 / scale.toFloat()
            batteryEventSink?.success("${batteryPct.toInt()}%")
        }
    }

    private fun startPeriodicBatteryUpdates() {
        val handler = Handler(Looper.getMainLooper())
        val runnable = object : Runnable {
            override fun run() {
                if (batteryEventSink != null) {
                    sendInitialBatteryLevel()
                    handler.postDelayed(this, 2000) // Update every 2 seconds
                }
            }
        }
        handler.postDelayed(runnable, 2000)
    }

    private fun stopBatteryMonitoring() {
        batteryReceiver?.let {
            unregisterReceiver(it)
            batteryReceiver = null
        }
    }

    private fun startAccelerometerMonitoring() {
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        
        sensorListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                event?.let {
                    val x = it.values[0]
                    val y = it.values[1]
                    val z = it.values[2]
                    
                    val data = "X: ${"%.2f".format(x)}\nY: ${"%.2f".format(y)}\nZ: ${"%.2f".format(z)}"
                    
                    Handler(Looper.getMainLooper()).post {
                        accelerometerEventSink?.success(data)
                    }
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                // Not needed for this demo
            }
        }
        
        accelerometer?.let {
            sensorManager?.registerListener(sensorListener, it, SensorManager.SENSOR_DELAY_NORMAL)
        } ?: run {
            accelerometerEventSink?.error("NO_SENSOR", "Accelerometer not available", null)
        }
    }

    private fun stopAccelerometerMonitoring() {
        sensorListener?.let {
            sensorManager?.unregisterListener(it)
            sensorListener = null
        }
    }

    override fun onDestroy() {
        stopBatteryMonitoring()
        stopAccelerometerMonitoring()
        super.onDestroy()
    }
}
