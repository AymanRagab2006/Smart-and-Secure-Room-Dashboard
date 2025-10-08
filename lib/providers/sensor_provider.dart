import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/notification_service.dart';

class SensorProvider extends ChangeNotifier {
  // Separate data storage for each sensor type
  double? _temperature;
  double? _humidity;
  int _smokeDetected = 0;
  int _motionDetected = 0;
  DateTime? _lastUpdate;

  // History for data
  List<Map<String, dynamic>> _dataHistory = [];

  // Getters for current data
  SensorData? get currentData {
    if (_temperature == null || _humidity == null) return null;

    return SensorData(
      temperature: _temperature!,
      humidity: _humidity!,
      smokeDetected: _smokeDetected,
      motionDetected: _motionDetected,
      timestamp: _lastUpdate ?? DateTime.now(),
    );
  }

  double? get temperature => _temperature;
  double? get humidity => _humidity;
  int get smokeDetected => _smokeDetected;
  int get motionDetected => _motionDetected;

  List<Map<String, dynamic>> get dataHistory => _dataHistory;

  void updateMonitorData(Map<String, dynamic> data) {
    print('SensorProvider: Updating monitor data: $data');

    try {
      _temperature = (data['temperature'] ?? _temperature ?? 0).toDouble();
      _humidity = (data['humidity'] ?? _humidity ?? 0).toDouble();
      _smokeDetected = data['smoke'] ?? _smokeDetected;
      _motionDetected = data['motion'] ?? _motionDetected;
      _lastUpdate = DateTime.now();

      // Add to history
      _dataHistory.add({
        'temperature': _temperature,
        'humidity': _humidity,
        'smoke': _smokeDetected,
        'motion': _motionDetected,
        'timestamp': _lastUpdate!.toIso8601String(),
      });

      // Keep only last 50 records
      if (_dataHistory.length > 50) {
        _dataHistory.removeAt(0);
      }

      // Check conditions
      _checkConditions();

      notifyListeners();
    } catch (e) {
      print('Error updating monitor data: $e');
    }
  }

  void _checkConditions() {
    if (_temperature == null || _humidity == null) return;

    // Temperature alerts
    if (_temperature! > 35) {
      NotificationService().showNotification(
        '🌡️ High Temperature Alert',
        'Room temperature is ${_temperature}°C',
      );
    } else if (_temperature! < 15) {
      NotificationService().showNotification(
        '❄️ Low Temperature Alert',
        'Room temperature is ${_temperature}°C',
      );
    }

    // Humidity alerts
    if (_humidity! > 70) {
      NotificationService().showNotification(
        '💧 High Humidity Alert',
        'Room humidity is ${_humidity}%',
      );
    } else if (_humidity! < 20) {
      NotificationService().showNotification(
        '🏜️ Low Humidity Alert',
        'Room humidity is ${_humidity}%',
      );
    }

    // Smoke alert
    if (_smokeDetected > 115) {
      NotificationService().showNotification(
        '🔥 Smoke Detected!',
        'Smoke has been detected in the room. Immediate action required!',
      );
    }
  }

  // For backward compatibility
  void updateSensorData(Map<String, dynamic> data) {
    updateMonitorData(data);
  }
}