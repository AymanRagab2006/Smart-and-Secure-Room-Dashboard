// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sensor_cards.dart';
import '../widgets/camera_view.dart';
import '../widgets/security_panel.dart';
import '../widgets/charts_widget.dart';
import '../providers/mqtt_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/settings_dialog.dart';
import 'mobile_dashboard_screen.dart';
import '../widgets/notification_center.dart';
import '../services/notification_service.dart';
import '../widgets/control_panel.dart';


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    NotificationService().setContext(context);
  }

  @override
  Widget build(BuildContext context) {
    // Use mobile layout for phones
    if (ResponsiveHelper.isMobile(context)) {
      return MobileDashboardScreen();
    }

    // Desktop/Tablet layout
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  // lib/screens/dashboard_screen.dart (continued)
                  colors: [Color(0xFF0A0E27), Color(0xFF1A237E)],
                ),
            ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: ResponsiveHelper.isTablet(context) ? 20 : 30),
                  Expanded(
                    child: ResponsiveHelper.isTablet(context)
                        ? _buildTabletLayout()
                        : _buildDesktopLayout(),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

// lib/screens/dashboard_screen.dart - Update _buildHeader() method
  Widget _buildHeader() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Room Dashboard',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveValue(
                      context,
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Real-time monitoring and security control',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveValue(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Settings button
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                tooltip: 'Settings',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SettingsDialog(),
                  );
                },
              ),
              NotificationCenter(),
              SizedBox(width: 16),
              _buildConnectionStatus(),
            ],
          ),
        ],
      );
    }

// Import the new widget

// Update the _buildDesktopLayout method
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          flex: 3,
          child: Column(
            children: [
              SensorCards(),
              SizedBox(height: 20),
              SizedBox(
                height: 80,  // Compact controls
                child: ControlPanel(horizontal: true),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ChartsWidget(),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        // Right Column - Camera gets full height
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                flex: 1,  // Camera takes 50%
                child: CameraView(),
              ),
              SizedBox(height: 20),
              Expanded(
                flex: 1,  // Security takes 50%
                child: SecurityPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }
// Update the _buildTabletLayout method
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SensorCards(),
          SizedBox(height: 20),
          Container(
            height: 400,
            child: Row(
              children: [
                Expanded(
                  child: CameraView(),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: SecurityPanel()),
                      SizedBox(height: 20),
                      ControlPanel(),  // Add this
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 300,
            child: ChartsWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Consumer<MqttProvider>(
      builder: (context, mqtt, _) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isMobile(context) ? 12 : 16,
            vertical: ResponsiveHelper.isMobile(context) ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: mqtt.isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                mqtt.isConnected ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: ResponsiveHelper.isMobile(context) ? 16 : 20,
              ),
              SizedBox(width: 8),
              Text(
                mqtt.isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.isMobile(context) ? 12 : 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}