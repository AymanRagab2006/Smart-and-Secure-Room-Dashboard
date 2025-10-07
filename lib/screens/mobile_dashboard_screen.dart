// lib/screens/mobile_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../widgets/sensor_cards.dart';
import '../widgets/camera_view.dart';
import '../widgets/security_panel.dart';
import '../widgets/charts_widget.dart';
import '../providers/mqtt_provider.dart';
import '../widgets/notification_center.dart';

class MobileDashboardScreen extends StatefulWidget {
  @override
  _MobileDashboardScreenState createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MqttProvider>().connect();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set context for notifications
    NotificationService().setContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E27),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Room',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          NotificationCenter(),
          _buildConnectionIndicator(),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildSensorsView(),
          _buildCameraView(),
          _buildSecurityView(),
          _buildChartsView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Color(0xFF1A237E),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Security',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Charts',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return Consumer<MqttProvider>(
      builder: (context, mqtt, _) {
        return Container(
          margin: EdgeInsets.only(right: 16),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: mqtt.isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mqtt.isConnected ? Icons.check : Icons.error,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                mqtt.isConnected ? 'Connected' : 'Offline',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sensor Readings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          MobileSensorCards(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(child: CameraView()),
        ],
      ),
    );
  }

  Widget _buildSecurityView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: SecurityPanel(),
    );
  }

  Widget _buildChartsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ChartsWidget(),
      ),
    );
  }
}