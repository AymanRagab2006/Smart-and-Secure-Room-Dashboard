import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mqtt_provider.dart';
import '../utils/responsive_helper.dart';

class ControlPanel extends StatefulWidget {
  final bool horizontal;

  const ControlPanel({Key? key, this.horizontal = false}) : super(key: key);

  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  bool _isLightOn = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.horizontal ? 16 : 20),
        child: widget.horizontal
            ? _buildHorizontalLayout(context, isMobile)
            : _buildVerticalLayout(context, isMobile),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Text(
          'Room Controls',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Door Control
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.door_front_door, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Consumer<MqttProvider>(
                      builder: (context, mqtt, _) {
                        return ElevatedButton.icon(
                          onPressed: mqtt.isConnected
                              ? () {
                            mqtt.publishCommand('room/door/open', {"allow": "true"});
                            _showFeedback(context, 'Door opening...', Colors.blue);
                          }
                              : null,
                          icon: Icon(Icons.lock_open, size: 16),
                          label: Text('OPEN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              // Light Control
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                      color: _isLightOn ? Colors.yellow : Colors.grey,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Light',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Consumer<MqttProvider>(
                      builder: (context, mqtt, _) {
                        return Switch(
                          value: _isLightOn,
                          onChanged: mqtt.isConnected
                              ? (value) {
                            setState(() => _isLightOn = value);
                            mqtt.controlLight(value);
                            _showFeedback(
                              context,
                              value ? 'Light ON' : 'Light OFF',
                              value ? Colors.yellow : Colors.grey,
                            );
                          }
                              : null,
                          activeColor: Colors.yellow,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context, bool isMobile) {
    // Keep your existing vertical layout code here
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Controls',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        _buildDoorControl(context, isMobile),
        SizedBox(height: 16),
        _buildLightControl(context, isMobile),
      ],
    );
  }

  Widget _buildDoorControl(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.door_front_door,
              color: Colors.blue,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Door Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Open door remotely',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          Consumer<MqttProvider>(
            builder: (context, mqtt, _) {
              return ElevatedButton.icon(
                onPressed: mqtt.isConnected
                    ? () {
                  mqtt.publishCommand('room/door/open', {"allow": "true"});
                  _showFeedback(context, 'Door opening...', Colors.blue);
                }
                    : null,
                icon: Icon(Icons.lock_open, size: isMobile ? 16 : 18),
                label: Text(
                  'OPEN',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 8 : 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLightControl(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_isLightOn ? Colors.yellow : Colors.grey).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
              color: _isLightOn ? Colors.yellow : Colors.grey,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Light Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isLightOn ? 'Light is ON' : 'Light is OFF',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          Consumer<MqttProvider>(
            builder: (context, mqtt, _) {
              return Switch(
                value: _isLightOn,
                onChanged: mqtt.isConnected
                    ? (value) {
                  setState(() {
                    _isLightOn = value;
                  });
                  mqtt.controlLight(value);
                  _showFeedback(
                    context,
                    value ? 'Light turned ON' : 'Light turned OFF',
                    value ? Colors.yellow : Colors.grey,
                  );
                }
                    : null,
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}