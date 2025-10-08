// In http_service.dart - Replace the server code with this client code

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shields/services/settings_service.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  // Remove all the server-related code and add:

  Future<String?> fetchUnauthorizedPersonImage() async {
    try {
      final serverUrl = await SettingsService().getServerUrl();
      final response = await http.get(
        Uri.parse('$serverUrl/unauthorized'),
        headers: {'Accept': 'image/jpeg, image/png, application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Check if response is JSON with base64 image
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          final data = json.decode(response.body);
          return data['image']; // Assuming backend sends {"image": "base64string"}
        }
        // If response is direct binary image data
        else if (response.headers['content-type']?.contains('image') ?? false) {
          // Convert binary to base64
          final bytes = response.bodyBytes;
          final base64String = base64Encode(bytes);
          return 'data:image/jpeg;base64,$base64String';
        }
      }

      print('Failed to fetch unauthorized image: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching unauthorized person image: $e');
      return null;
    }
  }

  Future<bool> registerPerson(String personName, String imageData) async {
    try {
      final serverUrl = await SettingsService().getServerUrl();

      // Extract base64 if it's a data URL
      String base64Image = imageData;
      if (imageData.startsWith('data:')) {
        base64Image = imageData.split(',')[1];
      }

      final response = await http.post(
        Uri.parse('$serverUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': personName,
          'image': base64Image, // Send base64 image data
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error registering person: $e');
      return false;
    }
  }
}