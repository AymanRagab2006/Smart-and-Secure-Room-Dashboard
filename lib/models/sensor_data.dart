class SensorData {
  final double temperature;
  final double humidity;
  final int smokeDetected;
  final int motionDetected;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.smokeDetected,
    required this.motionDetected,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      smokeDetected: json['smoke'] ?? 0,
      motionDetected: json['motion'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}