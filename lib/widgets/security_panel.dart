import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/security_provider.dart';
import '../providers/mqtt_provider.dart';
import '../services/settings_service.dart';
import '../services/http_service.dart';
import '../utils/responsive_helper.dart';

class SecurityPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Access Control',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _buildUnauthorizedPersonAlert(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthorizedPersonAlert(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Consumer<SecurityProvider>(
      builder: (context, security, _) {
        if (security.pendingPerson == null) {
          return Container(
            height: isMobile ? 200 : 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.white30,
                    size: isMobile ? 32 : 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Access Control Active',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                  Text(
                    'Monitoring for unauthorized access',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: isMobile ? 10 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert header
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: isMobile ? 16 : 18,
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Unauthorized Person Detected!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Image container
            Container(
              height: isMobile ? 200 : 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red, width: 2),
                color: Colors.black12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(security.pendingPerson!.imageUrl),
              ),
            ),

            SizedBox(height: 8),
            Text(
              'Time: ${DateFormat('HH:mm:ss').format(security.pendingPerson!.timestamp)}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isMobile ? 10 : 12,
              ),
            ),
            SizedBox(height: 12),

            // Three action buttons
            Column(
              children: [
                // Accept Always button
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 40 : 45,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAcceptAlways(context),
                    icon: Icon(Icons.person_add, size: isMobile ? 16 : 18),
                    label: Text(
                      'ACCEPT ALWAYS',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Accept Once button
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 40 : 45,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAcceptOnce(context),
                    icon: Icon(Icons.check_circle, size: isMobile ? 16 : 18),
                    label: Text(
                      'ACCEPT ONCE',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Deny button
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 40 : 45,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleDeny(context),
                    icon: Icon(Icons.block, size: isMobile ? 16 : 18),
                    label: Text(
                      'DENY',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Center(
        child: Text('No image URL', style: TextStyle(color: Colors.red)),
      );
    }

    return FutureBuilder<String>(
      future: SettingsService().getServerUrl(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        String fullUrl = imageUrl;
        if (!imageUrl.startsWith('http')) {
          fullUrl = '${snapshot.data}$imageUrl';
        }

        return Image.network(
          fullUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, color: Colors.red, size: 40),
                  SizedBox(height: 4),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleAcceptAlways(BuildContext context) async {
    final security = context.read<SecurityProvider>();
    final mqtt = context.read<MqttProvider>();

    if (security.pendingPerson == null) return;

    // Show dialog to get person's name
    final personName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _NameInputDialog(),
    );

    if (personName != null && personName.isNotEmpty) {
      // Register the person
      final success = await HttpService().registerPerson(
        personName,
        security.pendingPerson!.imageUrl,
      );

      if (success) {
        // Open door
        mqtt.publishCommand('room/door/open', {"allow": "true"});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Person registered: $personName'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        security.addAccessLog(security.pendingPerson!.id, true);
        security.clearPendingPerson();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to register person'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAcceptOnce(BuildContext context) {
    final security = context.read<SecurityProvider>();
    final mqtt = context.read<MqttProvider>();

    if (security.pendingPerson != null) {
      // Just open door once
      mqtt.publishCommand('room/door/open', {"allow": "true"});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Access Granted (Once)'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      security.addAccessLog(security.pendingPerson!.id, true);
      security.clearPendingPerson();
    }
  }

  void _handleDeny(BuildContext context) {
    final security = context.read<SecurityProvider>();

    if (security.pendingPerson != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Access Denied'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      security.addAccessLog(security.pendingPerson!.id, false);
      security.clearPendingPerson();
    }
  }
}

// Dialog to input person's name
class _NameInputDialog extends StatefulWidget {
  @override
  _NameInputDialogState createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<_NameInputDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF1E2749),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(Icons.person_add, color: Colors.green),
          SizedBox(width: 10),
          Text(
            'Register Person',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the person\'s name to grant permanent access',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Person Name',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'John Doe',
                hintStyle: TextStyle(color: Colors.white30),
                prefixIcon: Icon(Icons.badge, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _nameController.text.trim());
            }
          },
          child: Text('Register'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}