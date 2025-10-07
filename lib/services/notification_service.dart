// lib/services/notification_service.dart
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Store context for showing notifications
  BuildContext? _context;
  final List<NotificationItem> _notifications = [];

  // Initialize with context
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> initialize() async {
    // No initialization needed for in-app notifications
    print('NotificationService initialized');
  }

  Future<void> showNotification(String title, String body) async {
    // Add to notifications list
    _notifications.add(NotificationItem(
      title: title,
      body: body,
      timestamp: DateTime.now(),
    ));

    // Show in-app notification if context is available
    if (_context != null) {
      _showInAppNotification(_context!, title, body);
    }

    // Also print to console for debugging
    print('Notification: $title - $body');
  }

  void _showInAppNotification(BuildContext context, String title, String body) {
    // Determine notification type based on title
    Color backgroundColor = Colors.blue.shade700;
    IconData icon = Icons.info;

    if (title.contains('Smoke') || title.contains('🔥')) {
      backgroundColor = Colors.red.shade700;
      icon = Icons.warning;
    } else if (title.contains('Temperature') || title.contains('Humidity')) {
      backgroundColor = Colors.orange.shade700;
      icon = Icons.thermostat;
    } else if (title.contains('Unauthorized') || title.contains('⚠️')) {
      backgroundColor = Colors.red.shade700;
      icon = Icons.security;
    }

    // Show snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    body,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Get all notifications
  List<NotificationItem> get notifications => _notifications;

  // Clear all notifications
  void clearNotifications() {
    _notifications.clear();
  }
}

class NotificationItem {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationItem({
    required this.title,
    required this.body,
    required this.timestamp,
  });
}