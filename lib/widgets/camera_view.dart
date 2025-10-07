// lib/widgets/camera_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/responsive_helper.dart';
import '../services/settings_service.dart';
import '../widgets/settings_dialog.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  bool isStreaming = false;
  String? baseUrl;
  String? streamUrl;
  bool _isLoadingUrl = true;
  Key _streamKey = UniqueKey(); // Add key to force MJPEG widget rebuild

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    await _loadStreamUrl();
    // Auto-start streaming
    if (mounted) {
      _startStream();
    }
  }

  Future<void> _loadStreamUrl() async {
    baseUrl = await SettingsService().getServerUrl();
    setState(() {
      _isLoadingUrl = false;
    });
  }

  Future<void> _startStream() async {
    try {
      // Send POST request to start the camera stream
      final response = await http.post(
        Uri.parse('$baseUrl/stream/start'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          // Add timestamp to prevent caching
          streamUrl = '$baseUrl/video_feed?t=${DateTime.now().millisecondsSinceEpoch}';
          _streamKey = UniqueKey(); // Force widget rebuild
          isStreaming = true;
        });
        print('Stream started successfully: $streamUrl');
      } else {
        print('Failed to start stream: ${response.statusCode}');
      }
    } catch (e) {
      print('Error starting stream: $e');
    }
  }

  Future<void> _stopStream() async {
    try {
      // Send POST request to stop the camera stream
      await http.post(
        Uri.parse('$baseUrl/stream/stop'),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() {
        isStreaming = false;
        streamUrl = null;
      });
      print('Stream stopped');
    } catch (e) {
      print('Error stopping stream: $e');
    }
  }

  void _showSettings() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SettingsDialog(),
    );

    if (result == true) {
      // Stop current stream
      await _stopStream();

      // Reload settings and restart
      setState(() {
        _isLoadingUrl = true;
      });
      await _initializeStream();
    }
  }

  @override
  void dispose() {
    // Stop streaming when widget is disposed
    _stopStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (_isLoadingUrl) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Camera Feed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isStreaming)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _showSettings,
                      icon: Icon(Icons.settings, color: Colors.white70),
                      tooltip: 'Server Settings',
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isStreaming) {
                          await _stopStream();
                        } else {
                          await _startStream();
                        }
                      },
                      icon: Icon(
                        isStreaming ? Icons.stop : Icons.play_arrow,
                        color: isStreaming ? Colors.red : Colors.green,
                        size: isMobile ? 24 : 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isStreaming && streamUrl != null
                    ? // lib/widgets/camera_view.dart - Update the Mjpeg widget part
                Mjpeg(
                  key: _streamKey,
                  isLive: true,  // Add this line - tells MJPEG it's a live stream
                  stream: streamUrl!,
                  fit: BoxFit.contain,
                  timeout: Duration(seconds: 10),
                  loading: (context) => Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Connecting to camera...',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (context, error, stack) {
                    print('Stream error: $error');
                    return _buildErrorWidget(isMobile);
                  },
                )
                    : _buildOfflineWidget(isMobile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isMobile) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.red, size: isMobile ? 40 : 48),
              SizedBox(height: 16),
              Text(
                'Camera Connection Failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Server: $baseUrl',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Make sure Flask server is running',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showSettings,
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 20,
                        vertical: isMobile ? 8 : 10,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _startStream();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 20,
                        vertical: isMobile ? 8 : 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineWidget(bool isMobile) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              color: Colors.white30,
              size: isMobile ? 48 : 64,
            ),
            SizedBox(height: 16),
            Text(
              'Camera is Off',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the play button to start streaming',
              style: TextStyle(
                color: Colors.white54,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}