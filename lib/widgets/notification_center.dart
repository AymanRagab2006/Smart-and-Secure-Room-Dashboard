// lib/widgets/notification_center.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class NotificationCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService().notifications;

    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.notifications, color: Colors.white),
          if (notifications.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  '${notifications.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF1E2749),
            title: Text('Notifications', style: TextStyle(color: Colors.white)),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: notifications.isEmpty
                  ? Center(
                child: Text(
                  'No notifications',
                  style: TextStyle(color: Colors.white54),
                ),
              )
                  : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[notifications.length - 1 - index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        _getIconForNotification(notification.title),
                        color: _getColorForNotification(notification.title),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.body,
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            DateFormat('HH:mm:ss').format(notification.timestamp),
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  NotificationService().clearNotifications();
                  Navigator.pop(context);
                },
                child: Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForNotification(String title) {
    if (title.contains('Smoke')) return Icons.warning;
    if (title.contains('Temperature')) return Icons.thermostat;
    if (title.contains('Unauthorized')) return Icons.security;
    return Icons.info;
  }

  Color _getColorForNotification(String title) {
    if (title.contains('Smoke') || title.contains('Unauthorized')) return Colors.red;
    if (title.contains('Temperature')) return Colors.orange;
    return Colors.blue;
  }
}