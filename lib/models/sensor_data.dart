class SensorData {
  final double temperature;
  final double humidity;
  final bool smokeDetected;
  final int motionDetected;
  final int peopleCount;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.smokeDetected,
    required this.motionDetected,
    required this.peopleCount,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      smokeDetected: json['smoke'] ?? false,
      motionDetected: json['motion'] ?? 0,
      peopleCount: json['people_count'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}