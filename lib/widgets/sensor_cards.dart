import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';

class SensorCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, _) {
        final data = provider.currentData;
        bool smoke = false;
        if(data?.smokeDetected != null && data!.smokeDetected > 115){
          smoke = true;
        }

        return Container(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  icon: Icons.thermostat,
                  title: 'Temperature',
                  value: '${data?.temperature ?? 0}°C',
                  color: Colors.orange,
                  isAlert: (data?.temperature ?? 0) > 35,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSensorCard(
                  icon: Icons.water_drop,
                  title: 'Humidity',
                  value: '${data?.humidity ?? 0}%',
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSensorCard(
                  icon: Icons.warning_amber,
                  title: 'Smoke',
                  value: smoke == true ? 'DETECTED' : 'Clear',
                  color: smoke == true
                      ? Colors.red
                      : Colors.green,
                  isAlert: smoke == true,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSensorCard(
                  title: 'Motion',
                  icon: Icons.sensors,
                  value: data?.motionDetected == 1 ? 'Detected' : 'No Motion',
                  color: data?.motionDetected == 1 ? Colors.amber : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isAlert ? color.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAlert ? color : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(height: 16),
            Text(title, style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mobile version
class MobileSensorCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, _) {
        final data = provider.currentData;
        bool smoke = false;
        if(data?.smokeDetected != null && data!.smokeDetected > 115){
          smoke = true;
        }

        return Column(
          children: [
            // Temperature & Humidity Row
            Row(
              children: [
                Expanded(
                  child: _buildMobileSensorCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    value: '${data?.temperature ?? 0}°C',
                    color: Colors.orange,
                    isAlert: (data?.temperature ?? 0) > 35,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildMobileSensorCard(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '${data?.humidity ?? 0}%',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Smoke & Motion Row
            Row(
              children: [
                Expanded(
                  child: _buildMobileSensorCard(
                    icon: Icons.warning_amber,
                    title: 'Smoke',
                    value: smoke == true ? 'DETECTED' : 'Clear',
                    color: smoke == true
                        ? Colors.red
                        : Colors.green,
                    isAlert: smoke == true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildMobileSensorCard(
                    title: 'Motion',
                    icon: Icons.sensors,
                    value: data?.motionDetected == 1 ? 'Detected' : 'No Motion',
                    color: data?.motionDetected == 1
                        ? Colors.amber
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? color.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? color : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
